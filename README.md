# facebook_app_events

[![pub package](https://img.shields.io/pub/v/facebook_app_events.svg)](https://pub.dartlang.org/packages/facebook_app_events)

Flutter plugin for [Facebook App Events](https://developers.facebook.com/docs/app-events) and analytics.

> An app event is an action that takes place in your app or on your web page such as a person installing your app or completing a purchase. Facebook App Events allows you to track these events to view analytics, measure ad performance, and build audiences for ad targeting.

Flutter plugin for Facebook App Events, an app measurement solution that provides insight on app usage and user engagement in [Facebook Analytics](https://developers.facebook.com/apps/).

## Setting things up

You must first create an app at Facebook for developers: https://developers.facebook.com/

Get your app id (referred to as `[APP_ID]` below)

### Configure Android

Read through the "[Getting Started with App Events for Android](https://developers.facebook.com/docs/app-events/getting-started-app-events-android)" tutuorial and in particular, follow [step 2](https://developers.facebook.com/docs/app-events/getting-started-app-events-android#2--add-your-facebook-app-id) by adding the following into `/app/res/values/strings.xml` (or into respective `debug` or `release` build flavor)

```xml
<string name="facebook_app_id">[APP_ID]</string>
```

After that, add that string resource reference to your main `AndroidManifest.xml` file, directly under the `<application>` tag.

```xml
<meta-data
  android:name="com.facebook.sdk.ApplicationId"
  android:value="@string/facebook_app_id" />
```

### Configure iOS

Read through the "[Getting Started with App Events for iOS](https://developers.facebook.com/docs/app-events/getting-started-app-events-ios)" tutuorial and in particular, follow [step 4](https://developers.facebook.com/docs/app-events/getting-started-app-events-ios#plist-config) by opening `info.plist` "As Source Code" and add the following

- If your code does not have `CFBundleURLTypes`, add the following just before the final `</dict>` element:

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

- If your code already contains `CFBundleURLTypes`, insert the following:

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

## About Facebook App Events and Facebook Analytics

Please refer to the official SDK documentation for
[iOS](https://developers.facebook.com/docs/reference/iossdk/current/FBSDKCoreKit/classes/fbsdkappevents.html)
and
[Android](https://developers.facebook.com/docs/reference/androidsdk/current/facebook/com/facebook/appevents/appeventslogger.html) respectively for the correct and expected behavior. Please
[report an issue](https://github.com/oddbit/flutter_facebook_app_events/issues)
if you find anything that is not working according to official documentation.

## Getting involved
First of all, thank you for even considering to get involved. You are a real super :star:  and we :heart:  you!

### Reporting bugs and issues
Use the configured [Github issue report template](https://github.com/oddbit/flutter_facebook_app_events/issues/new?assignees=&labels=&template=bug_report.md&title=) when reporting an issue. Make sure to state your observations and expectations
as objectively and informative as possible so that we can understand your need and be able to troubleshoot. 

### Discussions and ideas
We're happy to discuss and talk about ideas in the 
[repository discussions](https://github.com/oddbit/flutter_facebook_app_events/discussions) and/or post your 
question to [StackOverflow](https://stackoverflow.com/search?q=facebook+app+events+flutter).

Feel free to open a thread if you are having any questions on how to use either the Facebook App Events as a reporting tool 
itself or even on how to use this plugin. 


## Facebook Analytics

The events that your app is reporting will appear in Facebook Analytics for apps. You can read more about how to configure your dashboard and best
practices on how to report data in Facebook help resources:
https://www.facebook.com/help/analytics/319598688400448
