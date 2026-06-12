# facebook_app_events

[![pub package](https://img.shields.io/pub/v/facebook_app_events.svg)](https://oddb.it/mtw)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202%2E0-lightgrey.svg)](https://oddb.it/qpy)
[![pub likes](https://img.shields.io/pub/likes/facebook_app_events)](https://oddb.it/wur)
[![pub points](https://img.shields.io/pub/points/facebook_app_events)](https://oddb.it/wur)


Flutter plugin for [Facebook App Events](https://oddb.it/rhg).

> An app event is an action that takes place in your app or on your web page such as a person installing your app or completing a purchase. Facebook App Events allows you to track these events to measure ad performance, and build audiences for ad targeting.

Flutter plugin for Facebook App Events, an app measurement solution that provides insight on app usage and user engagement.

## Documentation

- Plugin API reference (auto-generated): [pub.dev/documentation/facebook_app_events/latest](https://oddb.it/gie)
- Meta App Events overview: [developers.facebook.com/docs/app-events](https://oddb.it/rhg)

## Setting things up

You must first create an app at Facebook for developers: [developers.facebook.com](https://oddb.it/sbp)

1. Get your app id (referred to as `[APP_ID]` below)
2. Get your client token (referred to as `[CLIENT_TOKEN]` below).
   See "[Facebook Doc: Client Tokens](https://oddb.it/jex)" for more information and how to obtain it.


### Configure Android

Read through the "[Get Started with App Events (Android)](https://oddb.it/e2i)" and "[Getting Started with the Facebook SDK for Android](https://oddb.it/j5p)" tutorial. In particular, follow [Update Your Manifest](https://oddb.it/3si) step by adding the following into `android/app/src/main/res/values/strings.xml` (or into respective `debug` or `release` build flavor)  

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

Read through the "[Getting Started with App Events for iOS](https://oddb.it/77p)" and "[Getting Started with the Facebook SDK for iOS](https://oddb.it/hei)" guides. In particular, follow [step 5](https://oddb.it/279) by opening `Info.plist` "As Source Code" and add the following

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
- Swift Package Manager: the plugin includes a Swift package manifest at [ios/facebook_app_events/Package.swift](ios/facebook_app_events/Package.swift). Facebook's official iOS SDK also documents SPM support (see [Swift Package Manager](https://oddb.it/s73)).

#### iOS UIScene lifecycle

This plugin supports both the legacy `UIApplicationDelegate` lifecycle and the newer **`UIScene`** lifecycle (the default for apps built with Flutter 3.38+). It registers as both an application delegate and a scene delegate, so Facebook URL callbacks (deep links and deferred app links) reach the SDK regardless of which lifecycle your app uses. No extra host-app configuration is required beyond the standard Facebook setup above.

Because this plugin uses Flutter's scene-delegate plugin APIs (`FlutterSceneLifeCycleDelegate` / `addSceneDelegate`), added in Flutter 3.38, it requires **Flutter 3.38.0 or newer**.

## About Facebook App Events

Please refer to the official SDK documentation for correct and expected behavior (see documentation [iOS](https://oddb.it/wks) and [Android](https://oddb.it/yu2)). Please
[report an issue](https://oddb.it/3wd)
if you find anything that is not working according to official documentation.

### API scope

The plugin mirrors the App Events surface of the native SDKs 1:1 — if a method exists on `AppEvents` (iOS) / `AppEventsLogger` or the related `Settings` / `FacebookSdk` toggles (Android), you should find it here under the same name. A few native APIs are intentionally **not** exposed because they don't translate to Flutter: the access-token overloads of `logEvent`/`logPurchase`, hybrid-webview augmentation (`augmentWebView` / `augmentHybridWebView`), the Unity integration hooks, and iOS-only `logFailedStoreKit2Purchase`. If you need one of these, please [open an issue](https://oddb.it/3wd).

## Dependencies on Facebook SDK
Every now and then it is necessary for this plugin to update the Facebook SDK dependency. We follow the major
version of the current Facebook SDK in order to be as compatible as possible with other dependencies in your
project. 

For Facebook SDK release notes, see [iOS](https://oddb.it/ikt) and [Android](https://oddb.it/un7).

Please do note that it means that you get "the latest version" up until next major release, and it might
be a source of unexpected behavior for you if you are not aware of this. It is a preferred option to the
alternative of locking into a specific MINOR version of the SDK, which might be causing incompatibilities 
with your other plugins or dependencies.

## Known Limitations

### Graph API Version

The Facebook SDK v18.x ships with an outdated default Graph API version that Meta has already removed:

| Platform | SDK default | Removed by Meta |
|---|---|---|
| iOS SDK v18.x | `v17.0` | September 12, 2025 |
| Android SDK v18.x | `v16.0` | May 14, 2025 |

This plugin works around the issue by overriding the Graph API version to `v24.0` during plugin initialization. This requires no extra configuration for the vast majority of apps.

If you need to target a specific Graph API version (e.g. to pin to the same version as your backend), call `setGraphApiVersion` as early as possible in app startup before using features that may trigger Graph API requests:

```dart
final facebookAppEvents = FacebookAppEvents();

// Override the Graph API version (optional — plugin defaults to v24.0)
await facebookAppEvents.setGraphApiVersion('v24.0');

// Then activate the app as usual
await facebookAppEvents.activateApp();
```

Refer to Meta's [Graph API changelog](https://oddb.it/ku2) for currently active versions.

This is a plugin-specific workaround for a [known upstream issue in the iOS SDK](https://oddb.it/y8r) and [Android SDK](https://oddb.it/gmy). When Meta releases SDK v19.x with a corrected default, this override will become a no-op and the method can safely be removed from your code.

### Event parameter values

The native Facebook SDKs only accept `String` and numeric event parameter values — an event carrying any other value type is **silently dropped** by the SDK. To protect against that, `logEvent` (and the helpers that route through it) accepts `String`, `num`, and `bool` values: booleans are converted to `"1"`/`"0"` (Meta's yes/no convention) so events are recorded identically on both platforms, and any other value type throws an `ArgumentError`. Encode structured values (lists, maps) as a JSON string first, as Meta prescribes for parameters like `fb_content`.

### `clearUserDataForType` on Android

`clearUserDataForType` is **functional on iOS** but is a **no-op on Android** (a warning is logged). The Android `AppEventsLogger` exposes no per-field clear; call `clearUserData()` to clear all previously-set user data fields at once.

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
  - For codeless event debugging, enable codeless debug logging (see documentation [iOS](https://oddb.it/m28) and [Android](https://oddb.it/ji7))

4. Test codeless events on a physical device by:
   - Shaking the device to open the codeless event setup tool
   - If the tool doesn't appear, check your app configuration and Facebook console logs

**Note:** This is a cosmetic UI issue in Facebook's Event Manager tool. Your app is using the correct, up-to-date SDK version. The codeless events feature will function correctly with proper configuration, regardless of the warning message.

For more details, see:
- [GitHub Issue #402](https://oddb.it/7eq)
- [Facebook iOS SDK Issue #2513](https://oddb.it/hrz)

## Discussions and ideas
We're happy to discuss and talk about ideas in the
[repository discussions](https://oddb.it/z42) and/or post your
question to [StackOverflow](https://oddb.it/ywj).

Feel free to open a thread if you are having any questions on how to use either the Facebook App Events as a reporting tool
itself or even on how to use this plugin. 

## Need help shipping it?

This plugin is free and open source. But wiring up Meta attribution end to end —
consent flows, iOS ATT and SKAdNetwork, and getting events to actually land in
Events Manager — can get fiddly. If your team is integrating App Events and hits a
wall, or you'd just like an experienced pair of hands, [Oddbit](https://oddb.it/website)
is happy to help.

We're a senior-led studio (based in Indonesia, with roots in Sweden) shipping Flutter,
Firebase, and analytics integrations. `facebook_app_events` is one of the open-source
tools we maintain and use ourselves.

[Talk to us at oddbit.id →](https://oddb.it/website)

## Getting involved
First of all, thank you for even considering to get involved. You are a real super :star: and we :heart: you! 

Please read our [contribution guideline](CONTRIBUTING.md) for more info.

## Attribution

`facebook_app_events` is developed and maintained by **[Oddbit](https://oddb.it/website)**.

- Source repository: [github.com/oddbit/flutter_facebook_app_events](https://oddb.it/vrc)
- License: [Apache License 2.0](LICENSE)
- Attribution notices: [NOTICE](NOTICE)
- Name and logo usage: [Trademark Policy](TRADEMARK_POLICY.md)

If you publish a fork or derivative work, retain the license and notice files,
preserve applicable copyright and attribution notices, and clearly indicate
that your version has been modified.
