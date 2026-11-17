# facebook_app_events

[![pub package](https://img.shields.io/pub/v/facebook_app_events.svg)](https://oddb.it/mtw)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202%2E0-lightgrey.svg)](https://oddb.it/qpy)
[![pub likes](https://img.shields.io/pub/likes/facebook_app_events)](https://oddb.it/wur)
[![pub points](https://img.shields.io/pub/points/facebook_app_events)](https://oddb.it/wur)
[![commercial support](https://img.shields.io/badge/commercial%20support-Oddbit-0a7ea4.svg)](https://oddb.it/fbae-audit)

Flutter plugin for [Facebook App Events](https://oddb.it/rhg), Meta's app measurement and ad attribution SDK.

> An app event is an action that takes place in your app or on your web page such as a person installing your app or completing a purchase. Facebook App Events allows you to track these events to measure ad performance, and build audiences for ad targeting.

## Documentation

- Plugin API reference (auto-generated): [pub.dev/documentation/facebook_app_events/latest](https://oddb.it/gie)
- Guides, troubleshooting and background: [oddbit.id guides for this plugin](https://oddb.it/fbae-guides)
- Meta App Events overview: [developers.facebook.com/docs/app-events](https://oddb.it/rhg). What that surface maps to in Flutter, and what it leaves to your app: [what Facebook App Events covers in Flutter](https://oddb.it/fbae-guide-app-events)

This README is the quick start. The reasoning behind each setting, platform differences in depth, and what to do when something does not work are in the [guides](https://oddb.it/fbae-guides).

## Requirements

| | Minimum |
| --- | --- |
| Flutter | 3.41.0 |
| iOS deployment target | 15.0 |
| Xcode | 26.4 |

On an older Xcode the build fails inside the Facebook SDK with errors that do not mention Xcode: [Facebook SDK `.swiftinterface` build errors](https://oddb.it/fbae-guide-xcode).

## Setting things up

You must first create an app at Facebook for developers: [developers.facebook.com](https://oddb.it/sbp)

1. Get your app id (referred to as `[APP_ID]` below)
2. Get your client token (referred to as `[CLIENT_TOKEN]` below).
   See "[Facebook Doc: Client Tokens](https://oddb.it/jex)" for how to obtain it.
   It is not the app id, and it goes in a different file on each platform: [where the Facebook client token goes](https://oddb.it/fbae-guide-client-token).

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

Follow [step 5 of Meta's iOS guide](https://oddb.it/279): open `Info.plist` "As Source Code" and add the following just before the final `</dict>` element. If the file already has a `CFBundleURLTypes` array, add the `<dict>` to it instead of adding a second array.

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

If your app targets an iOS version below 15.0, raise `IPHONEOS_DEPLOYMENT_TARGET` to `15.0` in `ios/Runner.xcodeproj` and, if your `ios/Podfile` has an uncommented `platform :ios, ...` line, set it to `'15.0'` as well.

The plugin works with both **Swift Package Manager** (the Flutter default since 3.44) and **CocoaPods**, and with both the `UIScene` and the legacy app-delegate lifecycle, without extra configuration. Which integration your build uses, and how to switch: [Swift Package Manager setup for this plugin](https://oddb.it/fbae-guide-spm).

**Upgrading with CocoaPods across a Facebook SDK major** (for example from plugin 0.31.x): run `cd ios && pod update FBSDKCoreKit` once. Otherwise the build stops with "changed the constraints of dependency `FBSDKCoreKit`".

## Usage

```dart
final facebookAppEvents = FacebookAppEvents();

await facebookAppEvents.logEvent(
  name: 'button_clicked',
  parameters: {'button_id': 'the_clickme_button'},
);

await facebookAppEvents.logPurchase(amount: 9.99, currency: 'USD');
```

Event parameter values must be `String`, `num` or `bool`. Anything else throws an `ArgumentError`, because the native SDKs silently drop an event that carries another type. Encode lists and maps as a JSON string first.

The plugin mirrors the App Events API of the native SDKs 1:1. What it leaves out on purpose: [what Facebook App Events covers in Flutter](https://oddb.it/fbae-guide-app-events). Missing something? [Open an issue](https://oddb.it/3wd).

## Consent: deferring SDK initialization

By default the Facebook SDK initializes before your Dart code runs, and initializing contacts Meta. The auto-log flags do not prevent that. To hold the SDK back until the user has consented, turn automatic initialization off:

```xml
<!-- ios/Runner/Info.plist -->
<key>FacebookAutoInitEnabled</key>
<false/>
```

```xml
<!-- android/app/src/main/AndroidManifest.xml, under <application> -->
<meta-data android:name="com.facebook.sdk.AutoInitEnabled" android:value="false"/>
```

```dart
// After the user has consented, and on every later launch where consent is
// already stored. The plugin does not remember the decision for you.
await facebookAppEvents.initializeSdk();
await facebookAppEvents.activateApp(); // only if auto-logging is also off
```

**On iOS, call `initializeSdk()` before anything else.** Until then every other call (except `setGraphApiVersion`) fails with `sdkNotInitialized`. Android does not enforce that order, so a flow that works on Android can still be wrong for iOS.

The full picture, including what Android still does before consent: [holding the Facebook SDK back until consent](https://oddb.it/fbae-guide-consent).

## Event metadata (Facebook SDK v19)

**Since SDK v19, every event carries the screen title and the last URL that opened your app, query string included.** That covers OAuth and magic-link callbacks, and on Android the URL is stored from process start, even when initialization is deferred. It is on by default. To opt out:

```xml
<!-- ios/Runner/Info.plist -->
<key>FBSDKAutoLogMetaDataEnabled</key>
<false/>
```

```xml
<!-- android/app/src/main/AndroidManifest.xml, under <application> -->
<meta-data android:name="com.facebook.sdk.AutoLogMetaDataEnabled" android:value="false"/>
```

To turn it on after consent, call `setAutoLogMetaDataEnabled(true)` (on iOS after `initializeSdk()`). What exactly is collected, where it is stored and when it leaves the device: [what Facebook SDK v19 attaches to your events](https://oddb.it/fbae-guide-event-metadata).

## Handling errors

When a native handler reports an error, the plugin method throws a `FacebookAppEventsException`. Its `errorCode` is a `FacebookAppEventsErrorCode`:

| `errorCode` | Wire code | Meaning |
| --- | --- | --- |
| `invalidArgument` | `INVALID_ARGUMENT` | An argument was missing or malformed. The message says which one. |
| `sdkNotInitialized` | `sdk_not_initialized` | The native SDK is not initialized. Call `initializeSdk()` first. |
| `sdkInitializationFailed` | `sdk_initialization_failed` | `initializeSdk()` could not start the SDK (Android). The message is the SDK's reason. |
| `missingContext` | `missing_context` | The plugin has no Android `Context`. |
| `missingApplication` | `missing_application` | The plugin has no Android `Application`. |
| `unknown` | anything else | An error the plugin does not classify, typically thrown by the native SDK. The raw code is in `code`. |

```dart
try {
  await facebookAppEvents.initializeSdk();
} on FacebookAppEventsException catch (e) {
  if (e.errorCode == FacebookAppEventsErrorCode.sdkInitializationFailed) {
    debugPrint('Facebook SDK could not start: ${e.message}');
  }
}
```

Compare `errorCode`, not `code`: `code` is the wire string from the table, not the enum name. New values can be added to the enum in later releases, so keep a wildcard branch when you `switch` over it.

`FacebookAppEventsException` extends Flutter's `PlatformException`, and `code` still holds the wire code. Code that catches `PlatformException` and compares `e.code` strings keeps working. Invalid arguments caught in Dart before the call reaches the native side, such as an unsupported event parameter type, throw `ArgumentError` as before.

## Platform notes

- **Graph API version.** The plugin pins the Graph API version to `v24.0` on both platforms, because the Android SDK still defaults to a version Meta has removed. Override it with `setGraphApiVersion('vXX.0')` early in startup if you need a specific one. Background: [which Facebook SDK version you actually get](https://oddb.it/fbae-guide-sdk-versions).
- **Facebook SDK version.** The plugin follows the SDK's major version (currently v19) and does not pin a minor, so two builds can resolve different SDK releases. The same guide explains how to read what you got. Release notes: [iOS](https://oddb.it/ikt), [Android](https://oddb.it/un7).
- **`clearUserDataForType`** works on iOS and is a no-op on Android, which has no per-field clear. Use `clearUserData()` there.
- **`setUserData`** merges on both platforms: only the fields you pass are updated.

## Troubleshooting

| Symptom | Guide |
| --- | --- |
| Events do not show up in Events Manager, or counts disagree with yours | [Events not showing in Events Manager](https://oddb.it/fbae-guide-not-landing) |
| iOS build fails with "Consecutive statements on a line must be separated by ';'" in a `.swiftinterface` file | [Facebook SDK `.swiftinterface` build errors](https://oddb.it/fbae-guide-xcode) |
| A call fails with `sdk_not_initialized`, or `lateinit property appEventsLogger has not been initialized` | [Holding the Facebook SDK back until consent](https://oddb.it/fbae-guide-consent) |
| Events Manager says "Please Upgrade SDK" to version 4.34.0 | [The "Please Upgrade SDK" warning explained](https://oddb.it/fbae-guide-codeless) |
| Not sure where the client token goes, or events fail silently after setup | [Where the Facebook client token goes](https://oddb.it/fbae-guide-client-token) |
| Swift Package Manager will not resolve the Facebook SDK | [Swift Package Manager setup](https://oddb.it/fbae-guide-spm) |

All guides: [oddbit.id guides for this plugin](https://oddb.it/fbae-guides).

## Compatibility alerts

When Meta ships something that breaks Flutter apps, we email what changed and what to do about it. A few times a year, only when something real happened. Not a newsletter.

[Subscribe to compatibility alerts](https://oddb.it/fbae-alerts)

## Getting help

**Plugin defects are fixed for free, always.** If this plugin does not behave the way the native SDK documents, [open an issue](https://oddb.it/3wd).

**Questions about using or configuring App Events:** start with the [guides](https://oddb.it/fbae-guides), then the [repository discussions](https://oddb.it/z42) or [StackOverflow](https://oddb.it/ywj).

**Attribution debugging where ad spend is on the line:** if installs and purchases do not match up between your app, Events Manager and Ads Manager, that is usually not a plugin bug and not a quick answer. We offer a [Meta attribution audit](https://oddb.it/fbae-audit): a one hour diagnostic call at $300, credited in full against the audit fee if you go ahead. If the cause turns out to be a defect in this plugin, we fix it free and you keep the diagnostic.

`facebook_app_events` is built and maintained by Oddbit, a senior-led studio shipping Flutter, Firebase and analytics integrations. If your team would like an experienced pair of hands on Meta attribution, consent flows or the app around them, [talk to us at oddbit.id](https://oddb.it/website).

## Getting involved
First of all, thank you for even considering to get involved. You are a real super :star: and we :heart: you! 

Please read our [contribution guideline](https://oddb.it/fbae-contributing) for more info.

## Attribution

`facebook_app_events` is developed and maintained by **[Oddbit](https://oddb.it/website)**.

- Source repository: [github.com/oddbit/flutter_facebook_app_events](https://oddb.it/vrc)
- License: [Apache License 2.0](https://oddb.it/fbae-license)
- Attribution notices: [NOTICE](https://oddb.it/fbae-notice)
- Name and logo usage: [Trademark Policy](https://oddb.it/fbae-trademark)
