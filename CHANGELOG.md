## 0.19.2
- Updating `FBSDKCoreKit` to `17.0` that include Privacy Manifest
- Updating `FBAudienceNetwork` to `6.15`
- Update iOS deployment target to `12.0`

## 0.19.1
- Updating `FBSDKCoreKit` to `16.1` (PR [#309](https://github.com/oddbit/flutter_facebook_app_events/pull/309))
- Bump up android gradle version (PR [#310](https://github.com/oddbit/flutter_facebook_app_events/pull/310))
- Handle open push notification issue (PR [#334](https://github.com/oddbit/flutter_facebook_app_events/pull/334))
- Add compileOption and kotlinOption (PR [#321](https://github.com/oddbit/flutter_facebook_app_events/pull/321))

## 0.19.0
- Updating `FBSDKCoreKit` to `16` (PR [#296](https://github.com/oddbit/flutter_facebook_app_events/pull/296))

## 0.18.3
- Fixing issues [#270](https://github.com/oddbit/flutter_facebook_app_events/issues/270) and [#272](https://github.com/oddbit/flutter_facebook_app_events/issues/272)
- Updating `FBSDKCoreKit` to `15.1`
- Updating `FBAudienceNetwork` to `6.12` 

## 0.18.2
- Changing iOS version dependency to follow all `15.x` versions.

## 0.18.1
- Fixing version syntax in gradle.

## 0.18.0
- Updating Facebook SDK  dependency to follow all `15.x` versions.

## 0.17.1
- Implementing [Aggregated Event Measurement for Facebook App Events](https://developers.facebook.com/docs/app-events/guides/aggregated-event-measurement/) in [PR #236](https://github.com/oddbit/flutter_facebook_app_events/pull/236)

## 0.17.0
- Updating Facebook SDK  dependency to follow all `14.x` versions.
- Updating documentation to add client token in [project README](https://github.com/oddbit/flutter_facebook_app_events/blob/master/README.md#setting-things-up)

## 0.16.0
See [PR 224](https://github.com/oddbit/flutter_facebook_app_events/pull/224)

- Updating Facebook SDK  dependency to follow all `13.x` versions.
- Updating deprecated ios methods and propeties according https://github.com/facebook/facebook-ios-sdk/blob/main/CHANGELOG.md

## 0.15.0
- Adding back `setUserData()` which was removed by mistake. It's not completely deprecated.
- Bumping iOS FBSDK version to `12.3`

## 0.14.8
- Making parameters to `logPurchase()` mandatory ([issue #182](https://github.com/oddbit/flutter_facebook_app_events/issues/159))
- Updating gradle config for [`jcenter` deprecation](https://blog.gradle.org/jcenter-shutdown#:~:text=The%20jcenter()%20method%20will,may%20only%20publish%20new%20versions.).

## 0.14.7
Narrowing down the Facebook SDK version for iOS due to the trouble it seems to cause with different developer
environments and setups. See discussion in issue [#159](https://github.com/oddbit/flutter_facebook_app_events/issues/159) 
and [#171](https://github.com/oddbit/flutter_facebook_app_events/issues/171).

## 0.14.6
Fixing [issue 159](https://github.com/oddbit/flutter_facebook_app_events/issues/159) - iOS compilation error

## 0.14.5
Fixing [issue 165](https://github.com/oddbit/flutter_facebook_app_events/issues/165) - Pod install Error

## 0.14.4
Fixing [issue 161](https://github.com/oddbit/flutter_facebook_app_events/issues/161) - Adding configuration option for
`isAdvertiserIDCollectionEnabled` in the `setAdvertiserTracking()` method.

## 0.14.3
Fixing [issue 156](https://github.com/oddbit/flutter_facebook_app_events/issues/156) - iOS Compilation error 

## 0.14.2
Fixing [issue 147](https://github.com/oddbit/flutter_facebook_app_events/issues/147) - `logAddToCart()` throws PlatformException

## 0.14.1
See [PR 149](https://github.com/oddbit/flutter_facebook_app_events/pull/149)

- Updating Facebook SDK  dependency to follow all `12.x` versions.
- Adding debug/dev cert for android to build and test example app
- Removing deprecated methods
  - `setUserData`
  - `updateUserProperties`
  - `logActivatedApp`
  - `logDeactivatedApp`

## 0.13.5
- Updating Facebook SDK core kit dependency to follow all `11.x` versions.
- Removing references to Facebook Analytics in README (https://www.facebook.com/business/help/966883707418907)

## 0.13.4
Importing `FBSDKCoreKit_Basics` as a real fix for [#127](https://github.com/oddbit/flutter_facebook_app_events/issues/127) and [#129](https://github.com/oddbit/flutter_facebook_app_events/issues/129). See PR [#131](https://github.com/oddbit/flutter_facebook_app_events/pull/131). The PR adds back support for `setUserData` in iOS during deprecation grace period.

## 0.13.3
**N.B. Workaround release!!**
Removing function body for iOS handling of deprecated method `setUserData`. See issues [#127](https://github.com/oddbit/flutter_facebook_app_events/issues/127) and [#129](https://github.com/oddbit/flutter_facebook_app_events/issues/129). We 
were unable to reproduce or successfully troubleshoot the reported problems within the team and decided that it would be 
better to get around the compilation error with the sacrifice of the `setUserData` in the possibly short time before it
is removed from the SDK anyway.

## 0.13.2
- Addressing issue [#125](https://github.com/oddbit/flutter_facebook_app_events/issues/125) - iOS compilation error. See [PR #126](https://github.com/oddbit/flutter_facebook_app_events/pull/126)

## 0.13.1
- Fixing issue [#123](https://github.com/oddbit/flutter_facebook_app_events/issues/123)
  - Emptying the handling method for iOS `updateUserProperties` as it is removed from iOS SDK but only deprecated in Android.
  - Removing `nil` parameter from iOS `initializeSDK` method
  - Updating the missing `AppEvents.UserDataType` declarations 

## 0.13.0
- Bumping Facebook SDK core kit to `11.1`
- Adding deprecation notes for
  - `setUserData`
  - `updateUserProperties`
  - `logActivatedApp`
  - `logDeactivatedApp`
- Adding log events
  - `logAdClick`
  - `logAdImpression`
  - `logStartTrial` (see discussion [#119](https://github.com/oddbit/flutter_facebook_app_events/discussions/119))
  - `logSubscribe` (see discussion [#119](https://github.com/oddbit/flutter_facebook_app_events/discussions/119))

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
