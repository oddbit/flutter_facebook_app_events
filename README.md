# facebook_app_events

[![pub package](https://img.shields.io/pub/v/facebook_app_events.svg)](https://pub.dartlang.org/packages/facebook_app_events)

Flutter plugin for [Facebook App Events](https://developers.facebook.com/docs/app-events).

> An app event is an action that takes place in your app or on your web page such as a person installing your app or completing a purchase. Facebook App Events allows you to track these events to measure ad performance, and build audiences for ad targeting.

Flutter plugin for Facebook App Events, an app measurement solution that provides insight on app usage and user engagement.

## Setting things up

You must first create an app at Facebook for developers: https://developers.facebook.com/

1. Get your app id (referred to as `[APP_ID]` below)
2. Get your client token (referred to as `[CLIENT_TOKEN]` below).
   See "[Facebook Doc: Client Tokens](https://developers.facebook.com/docs/facebook-login/guides/access-tokens#clienttokens)" for more information and how to obtain it.


### Configure Android

Read through the "[Getting Started with App Events for Android](https://developers.facebook.com/docs/app-events/getting-started-app-events-android)" tutorial and in particular, follow [step 3](https://developers.facebook.com/docs/app-events/getting-started-app-events-android#step-3--integrate-the-facebook-sdk-in-your-android-app) by adding the following into `android/app/src/main/res/values/strings.xml` (or into respective `debug` or `release` build flavor)

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
  <string name="facebook_app_id">[APP_ID]</string>
  <string name="facebook_client_token">[CLIENT_TOKEN]</string>
</resources>
```

After that, add that string resource reference to your main `AndroidManifest.xml` file, directly under the `<application>` tag.

```xml
<application android:label="@string/app_name" ...>
    ...
   	<meta-data android:name="com.facebook.sdk.ApplicationId" android:value="@string/facebook_app_id"/>
   	<meta-data android:name="com.facebook.sdk.ClientToken" android:value="@string/facebook_client_token"/>
    ...
</application>
```

### Configure iOS

Read through the "[Getting Started with App Events for iOS](https://developers.facebook.com/docs/app-events/getting-started-app-events-ios)" tutorial and in particular, follow [step 5](https://developers.facebook.com/docs/app-events/getting-started-app-events-ios#step-5--configure-your-project) by opening `info.plist` "As Source Code" and add the following

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
<key>FacebookClientToken</key>
<string>[CLIENT_TOKEN]</string>
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
<key>FacebookClientToken</key>
<string>[CLIENT_TOKEN]</string>
<key>FacebookDisplayName</key>
<string>[APP_NAME]</string>
```

## About Facebook App Events

Please refer to the official SDK documentation for
[iOS](https://developers.facebook.com/docs/reference/iossdk/current/FBSDKCoreKit/classes/fbsdkappevents.html)
and
[Android](https://developers.facebook.com/docs/reference/androidsdk/current/facebook/com/facebook/appevents/appeventslogger.html) respectively for the correct and expected behavior. Please
[report an issue](https://github.com/oddbit/flutter_facebook_app_events/issues)
if you find anything that is not working according to official documentation.

## Dependencies on Facebook SDK
Every now and then it is necessary for this plugin to update the Facebook SDK dependency. We follow the major
version of the current Facebook SDK in order to be as compatible as possible with other dependencies in your
project. 

Please do note that it means that you get "the latest version" up until next major release, and it might
be a source of unexpected behavior for you if you are not aware of this. It is a preferred option to the
alternative of locking into a specific MINOR version of the SDK, which might be causing incompatibilities 
with your other plugins or dependencies.


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
