# CLAUDE.md

Guidance for Claude Code when working in this repo.

## Before making changes

Read [`CONTRIBUTING.md`](CONTRIBUTING.md) and follow the guidelines in it. In particular, the **Release Process** section lists files that must stay in sync (e.g. `pubspec.yaml` and `ios/facebook_app_events.podspec` versions) — consult it before preparing a release or bumping the version.

## Plugin architecture

This plugin exposes Meta's Facebook App Events SDK to Flutter with an explicit 1:1 mapping between the Dart API and the native handlers. When adding, renaming, or modifying a method, keep the three layers in sync:

- `lib/facebook_app_events.dart` — Dart API + MethodChannel invocation
- `android/src/main/kotlin/.../FacebookAppEventsPlugin.kt` — Android handler
- `ios/facebook_app_events/Sources/facebook_app_events/FacebookAppEventsPlugin.swift` — iOS handler

The MethodChannel name is `flutter.oddbit.id/facebook_app_events`.

## Facebook SDK version policy

The plugin follows the **major** version of the Facebook SDK (currently v18.x). Dependency ranges should stay major-only:

- Android (`android/build.gradle`): `com.facebook.android:facebook-android-sdk:[18.0,19.0)`
- iOS CocoaPods (`ios/facebook_app_events.podspec`): `FBSDKCoreKit`, `~> 18.0`
- iOS SPM (`ios/facebook_app_events/Package.swift`): `"18.0.0"..<"19.0.0"`

## Known platform divergence

- `clearUserDataForType`: functional on iOS; no-op on Android (the Android `AppEventsLogger` has no per-field clear). Documented in the Dart dartdoc and README "Known Limitations".
- Deferred SDK initialization (`FacebookAutoInitEnabled` on iOS, `com.facebook.sdk.AutoInitEnabled` on Android, `initializeSdk()` in Dart): on iOS the SDK is fully unconfigured until `initializeSdk()`, so the Swift handler gates every method call except `initializeSdk`/`setGraphApiVersion` (and the URL forwarders) behind a `isSdkInitialized` flag and returns `FlutterError(sdk_not_initialized)`; adding a new handler must keep it behind that gate unless its SDK call is verified safe pre-configuration. On Android `AutoInitEnabled=false` still runs `sdkInitialize`, so there is no gate and `initializeSdk` maps to `FacebookSdk.fullyInitialize()` — never `setAutoInitEnabled(true)`, which persists and overrides the manifest.
- `setUserData` uses merge semantics on both platforms: only fields present in the call are updated. The iOS handler deliberately skips absent keys because passing nil to the native setter would *clear* the field on iOS (Android ignores nulls).
- Graph API version override: plugin forces `v24.0` at init on both platforms to work around outdated SDK defaults. Revisit when FBSDK v19 lands.
- Event parameters are validated in the Dart layer (`String`/`num`/`bool` only, bool sent as `"1"`/`"0"`) because the native SDKs silently drop events with other value types.
