import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'adv_image_cache_method_channel.dart';

abstract class AdvImageCachePlatform extends PlatformInterface {
  /// Constructs a AdvImageCachePlatform.
  AdvImageCachePlatform() : super(token: _token);

  static final Object _token = Object();

  static AdvImageCachePlatform _instance = MethodChannelAdvImageCache();

  /// The default instance of [AdvImageCachePlatform] to use.
  ///
  /// Defaults to [MethodChannelAdvImageCache].
  static AdvImageCachePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AdvImageCachePlatform] when
  /// they register themselves.
  static set instance(AdvImageCachePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
