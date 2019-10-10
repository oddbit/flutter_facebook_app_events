#import "FacebookAppEventsPlugin.h"


@implementation FacebookAppEventsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFacebookAppEventsPlugin registerWithRegistrar:registrar];
}
@end
