# facebook_app_events

[![pub package](https://img.shields.io/pub/v/facebook_app_events.svg)](https://pub.dev/packages/facebook_app_events)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202%2E0-lightgrey.svg)](https://github.com/oddbit/flutter_facebook_app_events/blob/main/LICENSE)
[![pub likes](https://img.shields.io/pub/likes/facebook_app_events)](https://pub.dev/packages/facebook_app_events/score)
[![pub points](https://img.shields.io/pub/points/facebook_app_events)](https://pub.dev/packages/facebook_app_events/score)

![Dart](https://img.shields.io/badge/Dart-%3E%3D2.12%20%3C4.0-blue)
![Flutter](https://img.shields.io/badge/Flutter-%3E%3D2.0-blue)

Flutter plugin for [Facebook App Events](https://developers.facebook.com/docs/app-events).

> An app event is an action that takes place in your app or on your web page such as a person installing your app or completing a purchase. Facebook App Events allows you to track these events to measure ad performance, and build audiences for ad targeting.

Flutter plugin for Facebook App Events, an app measurement solution that provides insight on app usage and user engagement.

## Documentation

- Plugin API reference (auto-generated): https://pub.dev/documentation/facebook_app_events/latest/
- Meta App Events overview: https://developers.facebook.com/docs/app-events

## Setting things up

You must first create an app at Facebook for developers: <https://developers.facebook.com/>

1. Get your app id (referred to as `[APP_ID]` below)
2. Get your client token (referred to as `[CLIENT_TOKEN]` below).
   See "[Facebook Doc: Client Tokens](https://developers.facebook.com/docs/facebook-login/guides/access-tokens#clienttokens)" for more information and how to obtain it.


### Configure Android

Read through the "[Get Started with App Events (Android)](https://developers.facebook.com/docs/app-events/getting-started-app-events-android)" and "[Getting Started with the Facebook SDK for Android](https://developers.facebook.com/docs/android/getting-started)" tutorial. In particular, follow [Update Your Manifest](https://developers.facebook.com/docs/android/getting-started#add-app_id) step by adding the following into `android/app/src/main/res/values/strings.xml` (or into respective `debug` or `release` build flavor)  

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
  <string name="facebook_app_id">[APP_ID]</string>
  <string name="facebook_client_token">[CLIENT_TOKEN]</string>
  <string name="fb_login_protocol_scheme">fb[APP_ID]</string>
  <string name="app_name">[APP_NAME]</string>
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

Read through the "[Getting Started with App Events for iOS](https://developers.facebook.com/docs/app-events/getting-started-app-events-ios)" and "[Getting Started with the Facebook SDK for iOS](https://developers.facebook.com/docs/ios/getting-started)" guides. In particular, follow [step 5](https://developers.facebook.com/docs/app-events/getting-started-app-events-ios#step-5--configure-your-project) by opening `Info.plist` "As Source Code" and add the following

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

#### Swift Package Manager (SPM)

This plugin supports iOS integration via both **CocoaPods** (Flutter default) and **Swift Package Manager**.

- CocoaPods (default): no additional steps beyond the configuration above.
- Swift Package Manager: the plugin includes a Swift package manifest at [ios/facebook_app_events/Package.swift](ios/facebook_app_events/Package.swift). Facebook's official iOS SDK also documents SPM support (see [Swift Package Manager](https://github.com/facebook/facebook-ios-sdk#swift-package-manager)).

## About Facebook App Events

Please refer to the official SDK documentation for correct and expected behavior (see documentation [iOS](https://developers.facebook.com/docs/reference/iossdk/current/FBSDKCoreKit/classes/fbsdkappevents.html) and [Android](https://developers.facebook.com/docs/reference/androidsdk/current/facebook/com/facebook/appevents/appeventslogger.html)). Please
[report an issue](https://github.com/oddbit/flutter_facebook_app_events/issues)
if you find anything that is not working according to official documentation.

## Dependencies on Facebook SDK
Every now and then it is necessary for this plugin to update the Facebook SDK dependency. We follow the major
version of the current Facebook SDK in order to be as compatible as possible with other dependencies in your
project. 

For Facebook SDK release notes, see [iOS](https://github.com/facebook/facebook-ios-sdk/releases) and [Android](https://github.com/facebook/facebook-android-sdk/releases).

Please do note that it means that you get "the latest version" up until next major release, and it might
be a source of unexpected behavior for you if you are not aware of this. It is a preferred option to the
alternative of locking into a specific MINOR version of the SDK, which might be causing incompatibilities 
with your other plugins or dependencies.

## Known Limitations

### Facebook Event Manager "Please Upgrade SDK" Warning

When setting up codeless events in Facebook Event Manager, you may encounter a warning message stating:
> "To use the codeless event setup tool, you will need to update to Facebook SDK Version 4.34.0 or higher."

**This is a known limitation of the Facebook Event Manager UI and does not indicate an actual problem with your SDK version.**

#### Why This Happens

- This plugin uses **Facebook SDK version 18.x** (the latest available version)
- Facebook deprecated the umbrella pod `FacebookSDK` after version 11.2.1
- Modern Facebook SDK uses individual component pods: `FBSDKCoreKit`, `FBSDKLoginKit`, `FBSDKShareKit`, etc.
- The Facebook Event Manager UI was never updated to recognize this new pod structure
- The warning message incorrectly suggests using the deprecated `FacebookSDK` umbrella pod

#### What You Should Do

**Do not downgrade your SDK version or try to use the deprecated `FacebookSDK` umbrella pod.** Instead:

1. **Ignore the warning** - Your SDK is already up-to-date (version 18.x)
2. **Codeless events should still work** despite the warning message
3. Ensure your app is properly configured:
   - iOS: Verify `FacebookAppID`, `FacebookClientToken`, and `FacebookDisplayName` are set in your `Info.plist`
   - Android: Verify `facebook_app_id` and `facebook_client_token` are set in `strings.xml` and referenced in `AndroidManifest.xml`
  - For codeless event debugging, enable codeless debug logging (see documentation [iOS](https://developers.facebook.com/docs/reference/iossdk/current/FBSDKCoreKit/classes/settings.html) and [Android](https://developers.facebook.com/docs/reference/androidsdk/current/facebook/com/facebook/FacebookSdk.html))

4. Test codeless events on a physical device by:
   - Shaking the device to open the codeless event setup tool
   - If the tool doesn't appear, check your app configuration and Facebook console logs

**Note:** This is a cosmetic UI issue in Facebook's Event Manager tool. Your app is using the correct, up-to-date SDK version. The codeless events feature will function correctly with proper configuration, regardless of the warning message.

For more details, see:
- [GitHub Issue #402](https://github.com/oddbit/flutter_facebook_app_events/issues/402)
- [Facebook iOS SDK Issue #2513](https://github.com/facebook/facebook-ios-sdk/issues/2513)


## Getting involved
First of all, thank you for even considering to get involved. You are a real super :star: and we :heart: you! 

Please read our [contribution guideline](CONTRIBUTING.md) for more info.

### Discussions and ideas
We're happy to discuss and talk about ideas in the
[repository discussions](https://github.com/oddbit/flutter_facebook_app_events/discussions) and/or post your
question to [StackOverflow](https://stackoverflow.com/search?q=facebook+app+events+flutter).

Feel free to open a thread if you are having any questions on how to use either the Facebook App Events as a reporting tool
itself or even on how to use this plugin. 
