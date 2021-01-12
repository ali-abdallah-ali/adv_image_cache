import 'dart:typed_data';
import 'dart:ui';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'adv_image_cache_mgr.dart';

/*
 *  ImageCache for Flutter
 *
 *  Copyright (c) 2021 Ali ABDALLAH
 *  Released under MIT License.
 */

class AdvImageCache extends ImageProvider<AdvImageCache> {
  AdvImageCache(
    this.url, {
    this.scale = 1.0,
    this.downloadRetry = 2,
    this.useMemCache = true,
    this.diskCacheDirName = "AdvImageCache",
    this.diskCacheExpire = const Duration(days: 7),
    this.fallbackAssetImage,
  }) : assert(url != null);

  String url;

  /// The scale to place in the [ImageInfo] object of the image.
  final double scale;

  /// Enable or disable image caching.
  final bool useMemCache;

  /// Retry if download fails.
  final int downloadRetry;

  //// name for cache dir
  final String diskCacheDirName;

  /// disk cache expire
  final Duration diskCacheExpire;

  ///fail image
  final String fallbackAssetImage;

  Future<Codec> _downloadImage(AdvImageCache key) async {
    Uint8List data = await AdvImageCacheMgr().getFileData(key);

    if (data.length > 0) {
      return await PaintingBinding.instance.instantiateImageCodec(data);
    }

    if (fallbackAssetImage != null) {
      ByteData imageData = await rootBundle.load(key.fallbackAssetImage);
      data = imageData.buffer.asUint8List();

      return await PaintingBinding.instance.instantiateImageCodec(data);
    }

    return null;
  }

  @override
  Future<AdvImageCache> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<AdvImageCache>(this);
  }

  @override
  ImageStreamCompleter load(AdvImageCache key, DecoderCallback decode) {
    String uid = key.url.hashCode.toString();

    if (key.useMemCache && PaintingBinding.instance.imageCache.containsKey(uid)) {
      AdvImageCacheMgr().cacheAutoUpdate(key);
      return PaintingBinding.instance.imageCache.putIfAbsent(uid, () {
        return null;
      });
    } else {
      return MultiFrameImageStreamCompleter(
          codec: _downloadImage(key),
          scale: key.scale,
          informationCollector: () sync* {
            yield DiagnosticsProperty<ImageProvider>('Image provider', this);
            yield DiagnosticsProperty<AdvImageCache>('Image key', key);
          });
    }
  }
}
