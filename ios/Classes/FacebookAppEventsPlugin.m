#import "FacebookAppEventsPlugin.h"
#if __has_include(<facebook_app_events/facebook_app_events-Swift.h>)
#import <facebook_app_events/facebook_app_events-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "facebook_app_events-Swift.h"
#endif

@implementation FacebookAppEventsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFacebookAppEventsPlugin registerWithRegistrar:registrar];
}
@end
