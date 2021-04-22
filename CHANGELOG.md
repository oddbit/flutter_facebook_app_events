## 0.12.0
**Breaking changes:** Starting from this release, the plugin require Flutter 2.0 with support for 
[null safety](https://flutter.dev/docs/null-safety)

- Updating to Flutter 2.0 and null safety in [PR #90](https://github.com/oddbit/flutter_facebook_app_events/pull/90)
- Updating Facebook SDK to v9.1.0 in [PR #102](https://github.com/oddbit/flutter_facebook_app_events/pull/102)

## 0.11.2
- Auto initializing Facebook SDK on iOS (fixed in [PR #99](https://github.com/oddbit/flutter_facebook_app_events/pull/99)) and reported in issues [#86](https://github.com/oddbit/flutter_facebook_app_events/issues/86) and [#89](https://github.com/oddbit/flutter_facebook_app_events/issues/89)
## 0.11.1
- Adding `logAddToCart` event log
- Adding `logAddToWishlist` event log

## 0.11.0

- Fixing `logViewContent` as described in [issue #73](https://github.com/oddbit/flutter_facebook_app_events/issues/73)
- Bumping Facebook SDK core kit to 9.0.0 in [PR #85](https://github.com/oddbit/flutter_facebook_app_events/pull/85)

## 0.10.0

- Adding support for setAdvertiserTrackingEnabled solved in [PR #82](https://github.com/oddbit/flutter_facebook_app_events/pull/82)

## 0.9.0

- Updating iOS deployment target to `9.0` as described in [issue #74](https://github.com/oddbit/flutter_facebook_app_events/issues/74)

## 0.8.2

- Upgrading FBSDKCoreKit to 8.2.0 as described in [issue #56](https://github.com/oddbit/flutter_facebook_app_events/issues/56) 
and closed in [PR #65](https://github.com/oddbit/flutter_facebook_app_events/issues/56)

## 0.8.1

- Fixing missing Android imports

## 0.8.0

- Updating Facebook SDK version to 8.1.0
- Adding `logInitiatedCheckout` event per request in [issue #55](https://github.com/oddbit/flutter_facebook_app_events/issues/55)
- Adding anonymous id getter `getAnonymousId()`
  - Android SDK: [`getAnonymousAppDeviceGUID`](https://developers.facebook.com/docs/reference/androidsdk/current/facebook/com/facebook/appevents/appeventslogger.html/)
  - iOS SDK: [`anonymousID`](https://developers.facebook.com/docs/reference/iossdk/8.1.0/FBSDKCoreKit/classes/fbsdkappevents.html/)

## 0.7.2

Updating Android and iOS integration native code

## 0.7.1

Refining documentation and code formatting.

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
