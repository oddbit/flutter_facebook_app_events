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
- Flutter integration guides: [oddbit.id guides for this plugin](https://oddb.it/fbae-guides)
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
- Swift Package Manager: the plugin includes a Swift package manifest at [ios/facebook_app_events/Package.swift](https://oddb.it/fbae-package-swift). Facebook's official iOS SDK also documents SPM support (see [Swift Package Manager](https://oddb.it/s73)).

#### iOS UIScene lifecycle

This plugin supports both the legacy `UIApplicationDelegate` lifecycle and the newer **`UIScene`** lifecycle (the default for apps built with Flutter 3.38+). It registers as both an application delegate and a scene delegate, so Facebook URL callbacks (deep links and deferred app links) reach the SDK regardless of which lifecycle your app uses. No extra host-app configuration is required beyond the standard Facebook setup above.

Because this plugin uses Flutter's scene-delegate plugin APIs (`FlutterSceneLifeCycleDelegate` / `addSceneDelegate`), added in Flutter 3.38, it requires **Flutter 3.38.0 or newer**.

#### Deferring SDK initialization (consent gating)

The plugin initializes the Facebook SDK when it registers, which happens before your
Dart code runs. Apps that must not contact Meta until the user has consented can defer
that by adding the following to `Info.plist`:

```xml
<key>FacebookAutoInitEnabled</key>
<false/>
```

The key mirrors the `com.facebook.sdk.AutoInitEnabled` meta-data that the Facebook
Android SDK reads from `AndroidManifest.xml`, so both platforms can be configured the
same way. If the key is absent it defaults to `true` and initialization happens at
registration as before; only an explicit `false` defers it.

The collection flags do not cover this case on their own. With both
`FacebookAutoLogAppEventsEnabled` and `FacebookAdvertiserIDCollectionEnabled` set to
`false` no app events are logged, but initialization still issues its own configuration
requests (gatekeepers, server and domain configuration) and writes to `UserDefaults`.

With initialization deferred, nothing will be sent until your app initializes the SDK
itself. There is currently no Dart API for this, so do it from your own `AppDelegate`
once consent exists, for example over a method channel of your own:

```swift
import FBSDKCoreKit

ApplicationDelegate.shared.initializeSDK()
```

`Settings.shared.graphAPIVersion` is still set at registration time, so the Graph API
version the plugin pins applies either way.

## About Facebook App Events

Please refer to the official SDK documentation for correct and expected behavior (see documentation [iOS](https://oddb.it/wks) and [Android](https://oddb.it/yu2)). Please
[report an issue](https://oddb.it/3wd)
if you find anything that is not working according to official documentation.

### API scope

The plugin mirrors the App Events surface of the native SDKs 1:1. If a method exists on `AppEvents` (iOS) / `AppEventsLogger` or the related `Settings` / `FacebookSdk` toggles (Android), you should find it here under the same name. A few native APIs are intentionally **not** exposed because they don't translate to Flutter: the access-token overloads of `logEvent`/`logPurchase`, hybrid-webview augmentation (`augmentWebView` / `augmentHybridWebView`), the Unity integration hooks, and iOS-only `logFailedStoreKit2Purchase`. If you need one of these, please [open an issue](https://oddb.it/3wd).

## Dependencies on Facebook SDK
Every now and then it is necessary for this plugin to update the Facebook SDK dependency. We follow the major
version of the current Facebook SDK in order to be as compatible as possible with other dependencies in your
project. 

For Facebook SDK release notes, see [iOS](https://oddb.it/ikt) and [Android](https://oddb.it/un7).

Please do note that it means that you get "the latest version" up until next major release, and it might
be a source of unexpected behavior for you if you are not aware of this. It is a preferred option to the
alternative of locking into a specific MINOR version of the SDK, which might be causing incompatibilities 
with your other plugins or dependencies.

## Troubleshooting

### Events are not showing up in Events Manager

**Symptom:** you call `logEvent` and nothing appears in Events Manager, or the counts disagree with your own database.

**First check:** use **Test Events** in Events Manager rather than the aggregate dashboards, which are delayed and deduplicated. Call `flush()` to send immediately instead of waiting for the SDK's batching. If nothing arrives at all, the cause is almost always configuration rather than the plugin: a missing or wrong app id or client token, or a value type the SDK refuses (see [Event parameter values](#event-parameter-values) below).

Full diagnosis, split by layer (configuration, transport, attribution), with per-platform verification steps: [events not showing in Events Manager](https://oddb.it/fbae-guide-not-landing).

### Facebook Event Manager "Please Upgrade SDK" warning

When setting up codeless events in Facebook Event Manager, you may encounter a warning message stating:
> "To use the codeless event setup tool, you will need to update to Facebook SDK Version 4.34.0 or higher."

**This is a defect in the Events Manager UI and does not indicate an actual problem with your SDK version.** Version 4.34.0 is from the 4.x line, years older than the plugin's Facebook SDK 18.x, and the version it asks for is not the version it checks for.

**Do not downgrade your SDK, and do not add the deprecated `FacebookSDK` umbrella pod** (Meta stopped publishing it after 11.2.1 in September 2021). Instead:

1. Ignore the warning. Your SDK is already current.
2. Codeless events should still work despite the warning message.
3. Verify your configuration: `FacebookAppID`, `FacebookClientToken` and `FacebookDisplayName` in `Info.plist` on iOS; `facebook_app_id` and `facebook_client_token` in `strings.xml`, referenced as meta-data in `AndroidManifest.xml`, on Android.
4. Test on a physical device by shaking it to open the codeless event setup tool.
5. To confirm the SDK is logging at all, call `setDebugLoggingEnabled(true)` and watch for app event and network request logs.

**Codeless setup is gated by Meta server-side, not by an app-side flag.** Meta's docs for codeless debug logging ([iOS](https://oddb.it/m28), [Android](https://oddb.it/ji7)) describe the `FacebookCodelessDebugLogEnabled` (`Info.plist`) and `com.facebook.sdk.CodelessDebugLogEnabled` (Android manifest) flags, but in Facebook SDK 18.x neither flag has a consumer left in the SDK, so setting either changes nothing. On Android the codeless path is armed by `CodelessManager.onActivityResumed` from Meta's fetched app settings; on iOS by `FBSDKCodelessIndexer` from the `auto_event_setup_enabled` field Meta returns.

Why the warning appears, what the SDK actually checks, and how to tell a UI defect from a real misconfiguration: [the "Please Upgrade SDK" warning explained](https://oddb.it/fbae-guide-codeless).

Related reports, for what they actually show rather than as explanations of this warning:

- [GitHub Issue #402](https://oddb.it/7eq): Events Manager telling a developer on a current SDK to remove `FBSDKCoreKit`, `FBSDKLoginKit`, `FBSDKShareKit`, `FBSDKPlacesKit` and `FBSDKMessengerShareKit` from their Podfile, including the pod that logs app events. A different Events Manager message from the one above, closed as stale in March 2025 with no diagnosis.
- [Facebook iOS SDK Issue #2513](https://oddb.it/hrz): the same family of false "upgrade your SDK" report, on SDK 17.1.0, where Events Manager claimed the app needed updating in order to serve ads to users on iOS 14.5 or higher. Closed as a duplicate.

## Known Limitations

### Graph API Version

The Facebook SDK v18.x ships with an outdated default Graph API version that Meta has already removed:

| Platform | SDK default | Removed by Meta |
|---|---|---|
| iOS SDK v18.x | `v17.0` | September 12, 2025 |
| Android SDK v18.x | `v16.0` | May 14, 2025 |

This plugin works around the issue by overriding the Graph API version to `v24.0` during plugin initialization. This requires no extra configuration for the vast majority of apps.

Calls to a removed version are not rejected. Meta routes them to the oldest version that is still usable, so the app keeps working while silently using a version nobody chose. What reaches you instead is a deprecation notice from Meta with a removal deadline, on a version you did not knowingly pick. That is what [#474](https://oddb.it/fbae-issue-474) in this repository was.

If you need to target a specific Graph API version (e.g. to pin to the same version as your backend), call `setGraphApiVersion` as early as possible in app startup before using features that may trigger Graph API requests:

```dart
final facebookAppEvents = FacebookAppEvents();

// Override the Graph API version (optional, the plugin sets a current default)
await facebookAppEvents.setGraphApiVersion('v24.0');

// Then activate the app as usual
await facebookAppEvents.activateApp();
```

Refer to Meta's [Graph API changelog](https://oddb.it/ku2) for currently active versions.

This is a plugin-specific workaround for a [known upstream issue in the iOS SDK](https://oddb.it/y8r) and [Android SDK](https://oddb.it/gmy). When Meta releases SDK v19.x with a corrected default, this override will become a no-op and the method can safely be removed from your code.

### Event parameter values

The native Facebook SDKs only accept `String` and numeric event parameter values. An event carrying any other value type is **silently dropped** by the SDK. To protect against that, `logEvent` (and the helpers that route through it) accepts `String`, `num`, and `bool` values: booleans are converted to `"1"`/`"0"` (Meta's yes/no convention) so events are recorded identically on both platforms, and any other value type throws an `ArgumentError`. Encode structured values (lists, maps) as a JSON string first, as Meta prescribes for parameters like `fb_content`.

### `clearUserDataForType` on Android

`clearUserDataForType` is **functional on iOS** but is a **no-op on Android** (a warning is logged). The Android `AppEventsLogger` exposes no per-field clear; call `clearUserData()` to clear all previously-set user data fields at once.

## Compatibility alerts

When Meta ships something that breaks Flutter apps, we email what changed and what to do about it. Facebook SDK v18 defaulting to Graph API versions Meta had already removed was one of those. A few times a year, only when something real happened. Not a newsletter.

[Subscribe to compatibility alerts](https://oddb.it/fbae-alerts)

## Getting help

**Plugin defects are fixed for free, always.** If this plugin does not behave the way the native SDK documents, [open an issue](https://oddb.it/3wd). No conditions attached.

**Questions about using or configuring App Events:** start with the [guides](https://oddb.it/fbae-guides), then the [repository discussions](https://oddb.it/z42) or [StackOverflow](https://oddb.it/ywj).

**Attribution debugging where ad spend is on the line:** if installs and purchases are not matching up between your app, Events Manager and Ads Manager, that is usually not a plugin bug and not a quick answer. We offer a [Meta attribution audit](https://oddb.it/fbae-audit): a one hour diagnostic call at $300, credited in full against the audit fee if you go ahead, booked first and invoiced after we have read your intake answers. If the cause turns out to be a defect in this plugin, we fix it free and you keep the diagnostic.

### Who maintains this

Oddbit is a senior-led studio, based in Indonesia with roots in Sweden, shipping Flutter, Firebase and analytics integrations. `facebook_app_events` is one of the open source tools we maintain and use ourselves. Wiring up Meta attribution end to end, including consent flows, iOS App Tracking Transparency and SKAdNetwork, and getting events to actually land in Events Manager, gets fiddly. If your team hits a wall, or you would like an experienced pair of hands, [talk to us at oddbit.id](https://oddb.it/website).

## Getting involved
First of all, thank you for even considering to get involved. You are a real super :star: and we :heart: you! 

Please read our [contribution guideline](https://oddb.it/fbae-contributing) for more info.

## Attribution

`facebook_app_events` is developed and maintained by **[Oddbit](https://oddb.it/website)**.

- Source repository: [github.com/oddbit/flutter_facebook_app_events](https://oddb.it/vrc)
- License: [Apache License 2.0](https://oddb.it/fbae-license)
- Attribution notices: [NOTICE](https://oddb.it/fbae-notice)
- Name and logo usage: [Trademark Policy](https://oddb.it/fbae-trademark)
