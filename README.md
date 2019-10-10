# facebook_app_events
[![pub package](https://img.shields.io/pub/v/facebook_app_events.svg)](https://pub.dartlang.org/packages/facebook_app_events)

Flutter plugin for [Facebook App Events](https://developers.facebook.com/docs/app-events)

> An app event is an action that takes place in your app or on your web page such as a person installing your app or completing a purchase. Facebook App Events allows you to track these events to view analytics, measure ad performance, and build audiences for ad targeting.

This plugin is using the implementing support for logging events and user data from your app and to you Facebook project.

## Setting things up
You must first create an app at Facebook for developers: https://developers.facebook.com/

Get your app id (referred to as `[APP_ID]` below)

### Configure Android
Read through the "[Getting Started with App Events for Android](https://developers.facebook.com/docs/app-events/getting-started-app-events-android)" tutuorial and in particular, follow [step 2](https://developers.facebook.com/docs/app-events/getting-started-app-events-android#2--add-your-facebook-app-id) by adding the following into `/app/res/values/strings.xml`

```xml
<string name="facebook_app_id">[APP_ID]</string>
<string name="fb_login_protocol_scheme">fb[APP_ID]</string>
```

### Configure iOS
Read through the "[Getting Started with App Events for iOS](https://developers.facebook.com/docs/app-events/getting-started-app-events-ios)" tutuorial and in particular, follow [step 4](https://developers.facebook.com/docs/app-events/getting-started-app-events-ios#plist-config) by opening `info.plist` "As Source Code" and add the following


 * If your code does not have `CFBundleURLTypes`, add the following just before the final `</dict>` element:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
  <key>CFBundleURLSchemes</key>
  <array>
    <string>fb[APP_ID]</string>
  </array>
  </dict>
</array>
<key>FacebookAppID</key>
<string>[APP_ID]</string>
<key>FacebookDisplayName</key>
<string>[APP_NAME]</string>
```

 * If your code already contains `CFBundleURLTypes`, insert the following:

 ```xml
<array>
  <dict>
  <key>CFBundleURLSchemes</key>
  <array>
    <string>fb[APP_ID]</string>
  </array>
  </dict>
</array>
<key>FacebookAppID</key>
<string>[APP_ID]</string>
<key>FacebookDisplayName</key>
<string>[APP_NAME]</string>
 ```