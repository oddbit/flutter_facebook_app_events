#import "FacebookAppEventsPlugin.h"
#import <facebook_app_events/facebook_app_events-Swift.h>

@implementation FacebookAppEventsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFacebookAppEventsPlugin registerWithRegistrar:registrar];
}
@end
