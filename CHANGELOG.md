## 0.7.0

- Merging [PR #44](https://github.com/oddbit/flutter_facebook_app_events/pull/44) - Adding setDataProcessingOptions for CCPA compliance
- Merging [PR #49](https://github.com/oddbit/flutter_facebook_app_events/pull/49) - Fixing return type and docs for `getApplicationId`
- Merging [PR #50](https://github.com/oddbit/flutter_facebook_app_events/pull/50) - Implementing `logPurchase` and closing [#16](https://github.com/oddbit/flutter_facebook_app_events/issues/16)

## 0.6.0

- Merging [PR #29](https://github.com/oddbit/flutter_facebook_app_events/pull/29) - Add `setAutoLogAppEventsEnabled` for GDPR compliance.

## 0.5.2

- Fixing issue [#18](https://github.com/oddbit/flutter_facebook_app_events/issues/18) - `updateUserProperties` Future is not being resolved.

## 0.5.1

- Updating documentation from issue [#15](https://github.com/oddbit/flutter_facebook_app_events/issues/15)

## 0.5.0

- Fixing issues (
  [#2](https://github.com/oddbit/flutter_facebook_app_events/issues/2),
  [#4](https://github.com/oddbit/flutter_facebook_app_events/issues/4) and
  [#8](https://github.com/oddbit/flutter_facebook_app_events/issues/8): breaking configuration change for Android. See the README with information on what to add in `AndroidManifest.xml`

## 0.4.0

- Breaking name change of `logActivateApp` to `logActivatedApp`
- Adding shorthand log methods
  - logDeactivatedApp
  - logCompletedRegistration
  - logRated
  - logViewContent

## 0.3.0

- Add sample of shorthand log methods for app events.
  - logActivateApp

## 0.2.1

- Bug fixing.

## 0.2.0

- Adding app events
  - `logPushNotificationOpen`
  - `flush`
  - `getApplicationId`

## 0.1.0

- First initial release supporting some basic functionality
  - `clearUserData`
  - `clearUserID`
  - `logEvent`
  - `setUserData`
  - `setUserID`
  - `updateUserProperties`
