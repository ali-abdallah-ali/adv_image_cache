import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:ui';
import 'adv_image_cache.dart';

class AdvImageCacheMgr {
  static final AdvImageCacheMgr _instance = AdvImageCacheMgr._internal();
  factory AdvImageCacheMgr() => _instance;
  AdvImageCacheMgr._internal();

  Future<Uint8List> getFileData(AdvImageCache key) async {
    String uid = key.url.hashCode.toString();
    Uint8List data;

    //search local copy
    final File file = await _getLocalFile(key.diskCacheDirName, uid);
    if (file.existsSync() && file.lengthSync() > 0) {
      data = file.readAsBytesSync();
      //background update
      _cacheAutoUpdate(file, key);
    } else {
      data = await _load(file, key);
    }

    if (data.length > 0) {
      //test valid image
      try {
        await PaintingBinding.instance.instantiateImageCodecWithSize(await ImmutableBuffer.fromUint8List(data));
        _updateMemCache(key, data);
      } catch (_) {
        clearItem(key.url, diskCacheDirName: key.diskCacheDirName);
        data = Uint8List(0);
      }
    }

    return data;
  }

  Future<Uint8List> _load(File file, AdvImageCache key) async {
    try {
      file = await File(file.path).create(recursive: true);

      // Download file with retry
      for (int i = 0; i < key.downloadRetry; i++) {
        HttpClient httpClient = HttpClient();
        if (key.allowUserCert) {
          httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        }

        final HttpClientRequest request = await httpClient.getUrl(Uri.parse(key.url));
        if (key.header != null) {
          key.header!.forEach((k, v) => request.headers.add(k, v));
        }

        final HttpClientResponse response = await request.close();
        final Uint8List bytes = await consolidateHttpClientResponseBytes(response, autoUncompress: false);
        if (bytes.length > 0) {
          file = await file.writeAsBytes(bytes);
          break;
        }
      }
    } catch (e) {
      print(e.toString());
    }

    return file.readAsBytesSync();
  }

  Future<Directory> _getLocalDir(String dirName) async {
    Directory localDir = Directory(join((await getTemporaryDirectory()).path, dirName));
    return localDir;
  }

  Future<File> _getLocalFile(String dirName, String uid) async {
    File localFile = File(join((await _getLocalDir(dirName)).path, uid));
    return localFile;
  }

  ImageStreamCompleter _loadImageCache(AdvImageCache key, Uint8List data) {
    return MultiFrameImageStreamCompleter(
      codec: _loadCodec(data),
      scale: key.scale,
      informationCollector: () sync* {
        yield DiagnosticsProperty<ImageProvider>('Image provider', key);
        yield DiagnosticsProperty<AdvImageCache>('Image key', key);
      },
    );
  }

  Future<Codec> _loadCodec(Uint8List data) async {
    if (data.isEmpty) {
      throw StateError("Missing Data");
    }

    return PaintingBinding.instance.instantiateImageCodecWithSize(await ImmutableBuffer.fromUint8List(data));
  }

  void _updateMemCache(AdvImageCache key, Uint8List bytes) {
    //if we are using mem cache
    if (key.useMemCache) {
      String uid = key.url.hashCode.toString();
      PaintingBinding.instance.imageCache.evict(uid);
      PaintingBinding.instance.imageCache.putIfAbsent(uid, () => _loadImageCache(key, bytes));
    }
  }

//background update image in cache
  Future<void> cacheAutoUpdate(AdvImageCache key) async {
    try {
      String uid = key.url.hashCode.toString();
      final File file = await _getLocalFile(key.diskCacheDirName, uid);
      if (file.existsSync() && file.lengthSync() > 0) {
        await _cacheAutoUpdate(file, key);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _cacheAutoUpdate(File file, AdvImageCache key) async {
    try {
      DateTime dt = file.lastModifiedSync();
      DateTime dtMax = dt.add(key.diskCacheExpire);
      if (dtMax.isBefore(DateTime.now())) {
        await _load(file, key);
      }
    } catch (e) {
      print(e.toString());
    }
  }

//delete an image from cache
  Future<bool> clearItem(String url, {String diskCacheDirName = "AdvImageCache"}) async {
    try {
      String uid = url.hashCode.toString();

      PaintingBinding.instance.imageCache.evict(uid);
      final File file = await _getLocalFile(diskCacheDirName, uid);
      if (file.existsSync() && file.lengthSync() > 0) {
        file.deleteSync();

        return true;
      }
    } catch (e) {
      print(e);
    }

    return false;
  }

//delete all images from cache
  Future<bool> clearAllItems({String diskCacheDirName = "AdvImageCache"}) async {
    try {
      PaintingBinding.instance.imageCache.clear();
      Directory localDir = await _getLocalDir(diskCacheDirName);
      if (localDir.existsSync()) await localDir.delete(recursive: true);

      return true;
    } catch (e) {
      print(e);
    }

    return false;
  }

//get image cache total size
  Future<int> cacheSize(String diskCacheDirName) async {
    int size = 0;
    try {
      Directory localDir = await _getLocalDir(diskCacheDirName);
      if (localDir.existsSync())
        localDir.listSync().forEach((var file) {
          size += file.statSync().size;
        });

      return size;
    } catch (e) {
      print(e);
    }

    return -1;
  }
}
