// Runs inside the example app on an Android emulator or iOS simulator, against
// the real Facebook SDK. The unit tests in `test/` mock the method channel, so
// this is the only place the Kotlin and Swift handlers actually execute.
//
//   flutter test integration_test/plugin_test.dart -d <device>
//
// The tests share one app process and run in order: initialization first.
// The example app ships with automatic SDK initialization turned off on both
// platforms, which is what the first group relies on.

import 'dart:io';

import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// The app id configured in the example app (strings.xml / Info.plist).
const exampleAppId = '391810292537784';

/// Polls [read] until [matches] accepts its value. The Android SDK applies
/// user id and user data changes on a background executor, so a read straight
/// after a write can still see the old value.
Future<T> eventually<T>(
  Future<T> Function() read,
  bool Function(T value) matches, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final deadline = DateTime.now().add(timeout);
  var value = await read();
  while (!matches(value) && DateTime.now().isBefore(deadline)) {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    value = await read();
  }
  return value;
}

Matcher throwsErrorCode(FacebookAppEventsErrorCode code) => throwsA(
      isA<FacebookAppEventsException>()
          .having((e) => e.errorCode, 'errorCode', code),
    );

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final facebookAppEvents = FacebookAppEvents();

  group('before initializeSdk()', () {
    testWidgets('setGraphApiVersion is allowed', (tester) async {
      await facebookAppEvents.setGraphApiVersion('v24.0');
    });

    testWidgets('iOS rejects other calls, Android answers them',
        (tester) async {
      if (Platform.isIOS) {
        await expectLater(
          facebookAppEvents.getApplicationId(),
          throwsErrorCode(FacebookAppEventsErrorCode.sdkNotInitialized),
        );
        await expectLater(
          facebookAppEvents.logEvent(name: 'integration_test_too_early'),
          throwsErrorCode(FacebookAppEventsErrorCode.sdkNotInitialized),
        );
      } else {
        // AutoInitEnabled=false does not keep the Android SDK from loading.
        expect(await facebookAppEvents.getApplicationId(), exampleAppId);
      }
    });
  });

  group('after initializeSdk()', () {
    testWidgets('initializeSdk succeeds and can be repeated', (tester) async {
      await facebookAppEvents.initializeSdk();
      await facebookAppEvents.initializeSdk();
    });

    // First, so that nothing logged below is sent to Meta from CI.
    testWidgets('flush behavior round-trips', (tester) async {
      await facebookAppEvents.setFlushBehavior(FlushBehavior.explicitOnly);
      expect(
        await facebookAppEvents.getFlushBehavior(),
        FlushBehavior.explicitOnly,
      );
    });

    testWidgets('reports the configured app id and an anonymous id',
        (tester) async {
      expect(await facebookAppEvents.getApplicationId(), exampleAppId);
      expect(await facebookAppEvents.getAnonymousId(), isNotEmpty);
    });

    testWidgets('user id round-trips and clears', (tester) async {
      await facebookAppEvents.setUserID('integration-test-user');
      expect(
        await eventually(
          facebookAppEvents.getUserID,
          (id) => id == 'integration-test-user',
        ),
        'integration-test-user',
      );

      await facebookAppEvents.clearUserID();
      expect(
        await eventually(facebookAppEvents.getUserID, (id) => id == null),
        isNull,
      );
    });

    testWidgets('user data is stored hashed and can be cleared',
        (tester) async {
      await facebookAppEvents.setUserData(
        email: 'integration@example.com',
        firstName: 'Integration',
      );
      final stored = await eventually(
        facebookAppEvents.getUserData,
        (data) => data != null && data.contains('"em"'),
      );
      expect(stored, contains('"em"'));
      expect(stored, contains('"fn"'));
      expect(stored, isNot(contains('integration@example.com')));

      await facebookAppEvents.clearUserDataForType(FacebookUserDataField.email);
      await facebookAppEvents.clearUserData();
      final cleared = await eventually(
        facebookAppEvents.getUserData,
        (data) => data == null || !data.contains('"fn"'),
      );
      expect(cleared ?? '', isNot(contains('"fn"')));
    });

    testWidgets('logs events with every supported parameter type',
        (tester) async {
      await facebookAppEvents.logEvent(name: 'integration_test_plain');
      await facebookAppEvents.logEvent(
        name: 'integration_test_parameters',
        valueToSum: 1.5,
        parameters: {
          'string': 'value',
          'int': 42,
          'double': 4.2,
          'bool': true,
        },
      );
      await facebookAppEvents.logAddToCart(
        id: 'sku-1',
        type: 'product',
        currency: 'USD',
        price: 9.99,
      );
    });

    testWidgets('purchases accept ISO 4217 currencies in any case',
        (tester) async {
      await facebookAppEvents.logPurchase(amount: 1.0, currency: 'USD');
      await facebookAppEvents.logPurchase(
        amount: 1.0,
        currency: 'eur',
        parameters: {'order': 'integration-test'},
      );
    });

    testWidgets('an unknown currency is an invalid argument', (tester) async {
      await expectLater(
        facebookAppEvents.logPurchase(amount: 1.0, currency: 'dollars'),
        throwsErrorCode(FacebookAppEventsErrorCode.invalidArgument),
      );
    });

    testWidgets('product items are logged, and validated', (tester) async {
      Future<void> logItem(String currency) {
        return facebookAppEvents.logProductItem(
          itemId: 'sku-1',
          availability: ProductAvailability.inStock,
          condition: ProductCondition.newItem,
          description: 'Integration test item',
          imageLink: 'https://example.com/item.png',
          link: 'https://example.com/item',
          title: 'Item',
          priceAmount: 9.99,
          currency: currency,
          brand: 'Example',
        );
      }

      await logItem('USD');
      await expectLater(
        logItem('dollars'),
        throwsErrorCode(FacebookAppEventsErrorCode.invalidArgument),
      );
    });

    // The iOS SDK crashes the app on an `fb_push_payload` that is not a
    // dictionary with a string campaign, and the Android SDK only reads it as
    // a JSON string. The handlers convert; every shape below must be survived
    // on both platforms.
    testWidgets('push payloads are accepted in every shape', (tester) async {
      // As Firebase Cloud Messaging delivers it.
      await facebookAppEvents.logPushNotificationOpen(
        payload: {
          'fb_push_payload': '{"campaign":"integration-test"}',
          'nested': {'key': 'value'},
          'list': [1, 2, 3],
        },
        action: 'open',
      );
      // As APNs delivers it.
      await facebookAppEvents.logPushNotificationOpen(
        payload: {
          'fb_push_payload': {'campaign': 'integration-test'},
        },
      );
      // Malformed or missing entries are ignored, not fatal.
      await facebookAppEvents.logPushNotificationOpen(
        payload: {'fb_push_payload': 'not json'},
      );
      await facebookAppEvents.logPushNotificationOpen(
        payload: {
          'fb_push_payload': {'campaign': 42},
        },
      );
      await facebookAppEvents.logPushNotificationOpen(
        payload: {
          'fb_push_payload': [1, 2, 3],
        },
      );
      await facebookAppEvents.logPushNotificationOpen(payload: {});

      await facebookAppEvents.setPushNotificationsDeviceToken('0a1b2c3d');
    });

    testWidgets('privacy and consent settings are accepted', (tester) async {
      await facebookAppEvents.setAutoLogAppEventsEnabled(false);
      await facebookAppEvents.setAdvertiserIdCollectionEnabled(false);
      await facebookAppEvents.setLimitEventAndDataUsage(true);
      await facebookAppEvents.setLimitEventAndDataUsage(false);
      await facebookAppEvents.setAutoLogMetaDataEnabled(false);
      await facebookAppEvents.setDataProcessingOptions(
        ['LDU'],
        country: 0,
        state: 0,
      );
      await facebookAppEvents.setDataProcessingOptions([]);
      await facebookAppEvents.setDebugLoggingEnabled(true);
      await facebookAppEvents.setDebugLoggingEnabled(false);
    });
  });
}
