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
    this.header,
    this.scale = 1.0,
    this.downloadRetry = 2,
    this.useMemCache = true,
    this.diskCacheDirName = "AdvImageCache",
    this.diskCacheExpire = const Duration(days: 7),
    this.fallbackAssetImage,
  });

  String url;

  ///http header
  final Map<String, String>? header;

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
  final String? fallbackAssetImage;

  Future<Codec> _downloadImage(AdvImageCache key) async {
    //get image form cache or download
    Uint8List data = await AdvImageCacheMgr().getFileData(key);

    //if download image success
    if (data.isNotEmpty) {
      return await PaintingBinding.instance!.instantiateImageCodec(data);
    } else {
      //if fallback image is set
      if (fallbackAssetImage == null) {
        throw StateError("Missing Image");
      }

      ByteData imageData = await rootBundle.load(key.fallbackAssetImage!);
      data = imageData.buffer.asUint8List();
      return await PaintingBinding.instance!.instantiateImageCodec(data);
    }
  }

  @override
  Future<AdvImageCache> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<AdvImageCache>(this);
  }

  @override
  ImageStreamCompleter load(AdvImageCache key, DecoderCallback decode) {
    String uid = key.url.hashCode.toString();

    //in mem Cache
    if (key.useMemCache && PaintingBinding.instance!.imageCache!.containsKey(uid)) {
      // we know it is there , so return dummy func to add
      return PaintingBinding.instance!.imageCache!.putIfAbsent(
        uid,
        () {
          return MultiFrameImageStreamCompleter(
            codec: _downloadImage(key),
            scale: key.scale,
          );
        },
      )!;
    } else {
      //not in mem , download and return
      return MultiFrameImageStreamCompleter(
        codec: _downloadImage(key),
        scale: key.scale,
      );
    }
  }
}
