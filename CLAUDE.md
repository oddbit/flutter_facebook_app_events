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

- `setDataProcessingOptions`: functional on Android; no-op on iOS (Meta removed the API in FBSDK 18.x). Documented in the Dart dartdoc and README "Known Limitations".
- Graph API version override: plugin forces `v24.0` at init on both platforms to work around outdated SDK defaults. Revisit when FBSDK v19 lands.
