import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(channelName);
  final facebookAppEvents = FacebookAppEvents();

  MethodCall? methodCall;

  setUp(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      channel,
      (MethodCall m) async {
        methodCall = m;
        return null;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    methodCall = null;
  });

  group('Event logging', () {
    test('logEvent log events', () async {
      await facebookAppEvents.logEvent(
        name: 'test-event',
        parameters: <String, dynamic>{'a': 'b'},
      );
      expect(
        methodCall,
        isMethodCall(
          'logEvent',
          arguments: <String, dynamic>{
            'name': 'test-event',
            'parameters': <String, dynamic>{'a': 'b'},
          },
        ),
      );
    });

    test('logAdImpression forwards adType', () async {
      await facebookAppEvents.logAdImpression(adType: 'interstitial');

      expect(
        methodCall,
        isMethodCall(
          'logEvent',
          arguments: <String, dynamic>{
            'name': 'AdImpression',
            'parameters': <String, dynamic>{
              'fb_ad_type': 'interstitial',
            },
          },
        ),
      );
    });

    test('logViewContent handles custom parameters and overrides', () async {
      await facebookAppEvents.logViewContent(
        id: 'id123',
        currency: 'USD',
        price: 9.99,
        parameters: {
          'fb_content_id': 'SHOULD_BE_OVERRIDDEN',
          'custom_param': 'value',
        },
      );

      expect(
        methodCall,
        isMethodCall(
          'logEvent',
          arguments: <String, dynamic>{
            'name': 'fb_mobile_content_view',
            'parameters': <String, dynamic>{
              'fb_content_id': 'id123',
              'fb_currency': 'USD',
              'custom_param': 'value',
            },
            '_valueToSum': 9.99,
          },
        ),
      );
    });

    test('logSubscribe handles custom parameters and overrides', () async {
      await facebookAppEvents.logSubscribe(
        orderId: 'order123',
        currency: 'USD',
        price: 4.99,
        parameters: {
          'fb_order_id': 'SHOULD_BE_OVERRIDDEN',
          'custom_param': 'value',
        },
      );

      expect(
        methodCall,
        isMethodCall(
          'logEvent',
          arguments: <String, dynamic>{
            'name': 'Subscribe',
            'parameters': <String, dynamic>{
              'fb_order_id': 'order123',
              'fb_currency': 'USD',
              'custom_param': 'value',
            },
            '_valueToSum': 4.99,
          },
        ),
      );
    });

    test('logCompletedRegistration handles custom parameters and overrides', () async {
      await facebookAppEvents.logCompletedRegistration(
        registrationMethod: 'email',
        parameters: {
          'fb_registration_method': 'SHOULD_BE_OVERRIDDEN',
          'custom_param': 'value',
        },
      );

      expect(
        methodCall,
        isMethodCall(
          'logEvent',
          arguments: <String, dynamic>{
            'name': 'fb_mobile_complete_registration',
            'parameters': <String, dynamic>{
              'fb_registration_method': 'email',
              'custom_param': 'value',
            },
          },
        ),
      );
    });

    test('logAddToCart handles custom parameters and overrides', () async {
      await facebookAppEvents.logAddToCart(
        id: 'item-1',
        type: 'product',
        currency: 'USD',
        price: 9.99,
        parameters: {
          'fb_content_id': 'SHOULD_BE_OVERRIDDEN',
          'custom_param': 'value',
        },
      );

      expect(
        methodCall,
        isMethodCall(
          'logEvent',
          arguments: <String, dynamic>{
            'name': 'fb_mobile_add_to_cart',
            'parameters': <String, dynamic>{
              'fb_content_id': 'item-1',
              'fb_content_type': 'product',
              'fb_currency': 'USD',
              'custom_param': 'value',
            },
            '_valueToSum': 9.99,
          },
        ),
      );
    });

    test('logAdClick forwards adType', () async {
      await facebookAppEvents.logAdClick(adType: 'rewarded_video');

      expect(
        methodCall,
        isMethodCall(
          'logEvent',
          arguments: <String, dynamic>{
            'name': 'AdClick',
            'parameters': <String, dynamic>{
              'fb_ad_type': 'rewarded_video',
            },
          },
        ),
      );
    });

  });

  group('Purchase logging', () {
    test('logPurchase forwards parameters', () async {
      await facebookAppEvents.logPurchase(
        amount: 12.34,
        currency: 'USD',
        parameters: <String, dynamic>{'item': 'sku-123'},
      );

      expect(
        methodCall,
        isMethodCall(
          'logPurchase',
          arguments: <String, dynamic>{
            'amount': 12.34,
            'currency': 'USD',
            'parameters': <String, dynamic>{'item': 'sku-123'},
          },
        ),
      );
    });

    test('logPurchase omits parameters when null', () async {
      await facebookAppEvents.logPurchase(
        amount: 12.34,
        currency: 'USD',
      );

      expect(
        methodCall,
        isMethodCall(
          'logPurchase',
          arguments: <String, dynamic>{
            'amount': 12.34,
            'currency': 'USD',
          },
        ),
      );
    });
  });

  group('User data', () {
    test('setUserData omits null fields', () async {
      await facebookAppEvents.setUserData(
        email: 'user@example.com',
        firstName: null,
        lastName: null,
      );

      expect(
        methodCall,
        isMethodCall(
          'setUserData',
          arguments: <String, dynamic>{
            'email': 'user@example.com',
          },
        ),
      );
    });

    test('setUserData sends empty map when all null', () async {
      await facebookAppEvents.setUserData();

      expect(
        methodCall,
        isMethodCall(
          'setUserData',
          arguments: <String, dynamic>{},
        ),
      );
    });

    test('setUserData never sends null values (regression)', () async {
      await facebookAppEvents.setUserData(
        email: null,
        firstName: 'First',
        lastName: null,
        phone: null,
        dateOfBirth: null,
        gender: null,
        city: null,
        state: null,
        zip: null,
        country: null,
      );

      expect(methodCall?.method, 'setUserData');
      final args = methodCall?.arguments as Map<dynamic, dynamic>?;
      expect(args, isNotNull);
      expect(args!.values.any((v) => v == null), isFalse);
    });
  });

  group('Activation', () {
    test('activateApp sends empty args when null', () async {
      await facebookAppEvents.activateApp();

      expect(
        methodCall,
        isMethodCall(
          'activateApp',
          arguments: <String, dynamic>{},
        ),
      );
    });

    test('activateApp forwards applicationId when provided', () async {
      await facebookAppEvents.activateApp(applicationId: '123');

      expect(
        methodCall,
        isMethodCall(
          'activateApp',
          arguments: <String, dynamic>{'applicationId': '123'},
        ),
      );
    });
  });

  group('Configuration', () {
    test('setGraphApiVersion forwards version string', () async {
      await facebookAppEvents.setGraphApiVersion('v24.0');

      expect(
        methodCall,
        isMethodCall(
          'setGraphApiVersion',
          arguments: 'v24.0',
        ),
      );
    });

    test('setAutoLogAppEventsEnabled forwards boolean', () async {
      await facebookAppEvents.setAutoLogAppEventsEnabled(true);

      expect(
        methodCall,
        isMethodCall('setAutoLogAppEventsEnabled', arguments: true),
      );
    });

    test('setAdvertiserTracking forwards enabled and collectId', () async {
      await facebookAppEvents.setAdvertiserTracking(
        enabled: true,
        collectId: false,
      );

      expect(
        methodCall,
        isMethodCall(
          'setAdvertiserTracking',
          arguments: <String, dynamic>{
            'enabled': true,
            'collectId': false,
          },
        ),
      );
    });

    test('setDataProcessingOptions forwards options, country, state', () async {
      await facebookAppEvents.setDataProcessingOptions(
        ['LDU'],
        country: 1,
        state: 1000,
      );

      expect(
        methodCall,
        isMethodCall(
          'setDataProcessingOptions',
          arguments: <String, dynamic>{
            'options': ['LDU'],
            'country': 1,
            'state': 1000,
          },
        ),
      );
    });
  });

  group('User lifecycle', () {
    test('setUserID forwards id as scalar argument', () async {
      await facebookAppEvents.setUserID('user-42');

      expect(methodCall, isMethodCall('setUserID', arguments: 'user-42'));
    });

    test('clearUserID sends no arguments', () async {
      await facebookAppEvents.clearUserID();

      expect(methodCall, isMethodCall('clearUserID', arguments: null));
    });

    test('clearUserData sends no arguments', () async {
      await facebookAppEvents.clearUserData();

      expect(methodCall, isMethodCall('clearUserData', arguments: null));
    });

    test('flush sends no arguments', () async {
      await facebookAppEvents.flush();

      expect(methodCall, isMethodCall('flush', arguments: null));
    });

    test('getApplicationId invokes channel method', () async {
      await facebookAppEvents.getApplicationId();

      expect(methodCall, isMethodCall('getApplicationId', arguments: null));
    });

    test('getAnonymousId invokes channel method', () async {
      await facebookAppEvents.getAnonymousId();

      expect(methodCall, isMethodCall('getAnonymousId', arguments: null));
    });
  });

  group('Push notifications', () {
    test('logPushNotificationOpen forwards payload and action', () async {
      await facebookAppEvents.logPushNotificationOpen(
        payload: {'campaign': 'spring-sale'},
        action: 'opened',
      );

      expect(
        methodCall,
        isMethodCall(
          'logPushNotificationOpen',
          arguments: <String, dynamic>{
            'payload': {'campaign': 'spring-sale'},
            'action': 'opened',
          },
        ),
      );
    });
  });

  group('Standard event shorthands', () {
    test('logRated forwards valueToSum and parameters', () async {
      await facebookAppEvents.logRated(
        valueToSum: 4.5,
        parameters: {'content_id': 'sku-1'},
      );

      expect(
        methodCall,
        isMethodCall(
          'logEvent',
          arguments: <String, dynamic>{
            'name': 'fb_mobile_rate',
            'parameters': <String, dynamic>{'content_id': 'sku-1'},
            '_valueToSum': 4.5,
          },
        ),
      );
    });

    test('logInitiatedCheckout forwards totalPrice, currency, numItems',
        () async {
      await facebookAppEvents.logInitiatedCheckout(
        totalPrice: 49.99,
        currency: 'USD',
        contentType: 'product',
        contentId: 'sku-1',
        numItems: 2,
        paymentInfoAvailable: true,
      );

      expect(
        methodCall,
        isMethodCall(
          'logEvent',
          arguments: <String, dynamic>{
            'name': 'fb_mobile_initiated_checkout',
            'parameters': <String, dynamic>{
              'fb_content_type': 'product',
              'fb_content_id': 'sku-1',
              'fb_num_items': 2,
              'fb_currency': 'USD',
              'fb_payment_info_available': '1',
            },
            '_valueToSum': 49.99,
          },
        ),
      );
    });

    test('logStartTrial forwards orderId, price, currency', () async {
      await facebookAppEvents.logStartTrial(
        orderId: 'order-9',
        price: 0.0,
        currency: 'USD',
      );

      expect(
        methodCall,
        isMethodCall(
          'logEvent',
          arguments: <String, dynamic>{
            'name': 'StartTrial',
            'parameters': <String, dynamic>{
              'fb_currency': 'USD',
              'fb_order_id': 'order-9',
            },
            '_valueToSum': 0.0,
          },
        ),
      );
    });

    test('logAddToWishlist forwards required fields and price', () async {
      await facebookAppEvents.logAddToWishlist(
        id: 'sku-7',
        type: 'product',
        currency: 'EUR',
        price: 19.5,
      );

      expect(
        methodCall,
        isMethodCall(
          'logEvent',
          arguments: <String, dynamic>{
            'name': 'fb_mobile_add_to_wishlist',
            'parameters': <String, dynamic>{
              'fb_content_id': 'sku-7',
              'fb_content_type': 'product',
              'fb_currency': 'EUR',
            },
            '_valueToSum': 19.5,
          },
        ),
      );
    });
  });
}
