#import "AdvImageCachePlugin.h"
#if __has_include(<adv_image_cache/adv_image_cache-Swift.h>)
#import <adv_image_cache/adv_image_cache-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "adv_image_cache-Swift.h"
#endif

@implementation AdvImageCachePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAdvImageCachePlugin registerWithRegistrar:registrar];
}
@end
