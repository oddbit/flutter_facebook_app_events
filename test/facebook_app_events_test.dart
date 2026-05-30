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

  group('Product catalog', () {
    test('logProductItem forwards required fields and enum tokens', () async {
      await facebookAppEvents.logProductItem(
        itemId: 'SKU-1',
        availability: ProductAvailability.inStock,
        condition: ProductCondition.newItem,
        description: 'A product',
        imageLink: 'https://example.com/img.png',
        link: 'https://example.com/buy',
        title: 'Product',
        priceAmount: 9.99,
        currency: 'USD',
        gtin: '0123456789012',
      );

      expect(
        methodCall,
        isMethodCall(
          'logProductItem',
          arguments: <String, dynamic>{
            'itemId': 'SKU-1',
            'availability': 'inStock',
            'condition': 'newItem',
            'description': 'A product',
            'imageLink': 'https://example.com/img.png',
            'link': 'https://example.com/buy',
            'title': 'Product',
            'priceAmount': 9.99,
            'currency': 'USD',
            'gtin': '0123456789012',
          },
        ),
      );
    });

    test('logProductItem maps availableForOrder/used tokens', () async {
      await facebookAppEvents.logProductItem(
        itemId: 'SKU-2',
        availability: ProductAvailability.availableForOrder,
        condition: ProductCondition.used,
        description: 'desc',
        imageLink: 'https://example.com/i',
        link: 'https://example.com/l',
        title: 'title',
        priceAmount: 1.0,
        currency: 'EUR',
        brand: 'Acme',
      );

      final args = methodCall?.arguments as Map<dynamic, dynamic>;
      expect(args['availability'], 'availableForOrder');
      expect(args['condition'], 'used');
      expect(args['brand'], 'Acme');
      expect(args.containsKey('gtin'), isFalse);
      expect(args.containsKey('mpn'), isFalse);
    });
  });

  group('Flush behavior', () {
    test('setFlushBehavior forwards behavior token', () async {
      await facebookAppEvents.setFlushBehavior(FlushBehavior.explicitOnly);

      expect(
        methodCall,
        isMethodCall('setFlushBehavior', arguments: 'explicitOnly'),
      );
    });

    test('getFlushBehavior maps token back to enum', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall m) async {
        methodCall = m;
        return 'explicitOnly';
      });

      final behavior = await facebookAppEvents.getFlushBehavior();

      expect(methodCall, isMethodCall('getFlushBehavior', arguments: null));
      expect(behavior, FlushBehavior.explicitOnly);
    });

    test('getFlushBehavior defaults to auto for unknown token', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall m) async => null);

      final behavior = await facebookAppEvents.getFlushBehavior();
      expect(behavior, FlushBehavior.auto);
    });
  });

  group('Getters and granular user data', () {
    test('getUserData returns the value from the platform', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall m) async {
        methodCall = m;
        return '{"em":"hashed-email"}';
      });

      final data = await facebookAppEvents.getUserData();

      expect(methodCall, isMethodCall('getUserData', arguments: null));
      expect(data, '{"em":"hashed-email"}');
    });

    test('getUserID returns the value from the platform', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall m) async {
        methodCall = m;
        return 'user-42';
      });

      final id = await facebookAppEvents.getUserID();

      expect(methodCall, isMethodCall('getUserID', arguments: null));
      expect(id, 'user-42');
    });

    test('clearUserDataForType forwards field token', () async {
      await facebookAppEvents
          .clearUserDataForType(FacebookUserDataField.email);
      expect(
        methodCall,
        isMethodCall('clearUserDataForType', arguments: 'email'),
      );
    });
  });

  group('Push token and debug logging', () {
    test('setPushNotificationToken forwards token as scalar', () async {
      await facebookAppEvents.setPushNotificationToken('tok-123');
      expect(
        methodCall,
        isMethodCall('setPushNotificationToken', arguments: 'tok-123'),
      );
    });

    test('setDebugLoggingEnabled forwards boolean', () async {
      await facebookAppEvents.setDebugLoggingEnabled(true);
      expect(
        methodCall,
        isMethodCall('setDebugLoggingEnabled', arguments: true),
      );
    });
  });

  group('Additional standard events', () {
    test('logAchievedLevel forwards level', () async {
      await facebookAppEvents.logAchievedLevel(level: '5');

      expect(
        methodCall,
        isMethodCall(
          'logEvent',
          arguments: <String, dynamic>{
            'name': 'fb_mobile_level_achieved',
            'parameters': <String, dynamic>{'fb_level': '5'},
          },
        ),
      );
    });

    test('logSearched forwards search string and content type', () async {
      await facebookAppEvents.logSearched(
        searchString: 'shoes',
        contentType: 'product',
      );

      expect(
        methodCall,
        isMethodCall(
          'logEvent',
          arguments: <String, dynamic>{
            'name': 'fb_mobile_search',
            'parameters': <String, dynamic>{
              'fb_search_string': 'shoes',
              'fb_content_type': 'product',
            },
          },
        ),
      );
    });

    test('logUnlockedAchievement forwards description', () async {
      await facebookAppEvents.logUnlockedAchievement(description: 'first_win');

      expect(
        methodCall,
        isMethodCall(
          'logEvent',
          arguments: <String, dynamic>{
            'name': 'fb_mobile_achievement_unlocked',
            'parameters': <String, dynamic>{'fb_description': 'first_win'},
          },
        ),
      );
    });

    test('logDonate forwards valueToSum and currency', () async {
      await facebookAppEvents.logDonate(valueToSum: 10.0, currency: 'USD');

      expect(
        methodCall,
        isMethodCall(
          'logEvent',
          arguments: <String, dynamic>{
            'name': 'Donate',
            'parameters': <String, dynamic>{'fb_currency': 'USD'},
            '_valueToSum': 10.0,
          },
        ),
      );
    });

    test('logSubmitApplication routes through logEvent', () async {
      await facebookAppEvents.logSubmitApplication();

      expect(
        methodCall,
        isMethodCall(
          'logEvent',
          arguments: <String, dynamic>{'name': 'SubmitApplication'},
        ),
      );
    });

    test('logSpentCredits forwards valueToSum and content', () async {
      await facebookAppEvents.logSpentCredits(
        valueToSum: 100.0,
        currency: 'USD',
        contentType: 'coins',
        contentId: 'pack-1',
      );

      expect(
        methodCall,
        isMethodCall(
          'logEvent',
          arguments: <String, dynamic>{
            'name': 'fb_mobile_spent_credits',
            'parameters': <String, dynamic>{
              'fb_currency': 'USD',
              'fb_content_type': 'coins',
              'fb_content_id': 'pack-1',
            },
            '_valueToSum': 100.0,
          },
        ),
      );
    });

    test('logAddedPaymentInfo routes through logEvent with parameters',
        () async {
      await facebookAppEvents.logAddedPaymentInfo(
        parameters: {'fb_success': '1'},
      );

      expect(
        methodCall,
        isMethodCall(
          'logEvent',
          arguments: <String, dynamic>{
            'name': 'fb_mobile_add_payment_info',
            'parameters': <String, dynamic>{'fb_success': '1'},
          },
        ),
      );
    });

    test('logCompletedTutorial forwards contentId', () async {
      await facebookAppEvents.logCompletedTutorial(contentId: 'intro-1');

      expect(
        methodCall,
        isMethodCall(
          'logEvent',
          arguments: <String, dynamic>{
            'name': 'fb_mobile_tutorial_completion',
            'parameters': <String, dynamic>{'fb_content_id': 'intro-1'},
          },
        ),
      );
    });

    test('logContact routes through logEvent', () async {
      await facebookAppEvents.logContact();

      expect(
        methodCall,
        isMethodCall(
          'logEvent',
          arguments: <String, dynamic>{'name': 'Contact'},
        ),
      );
    });

    test('logCustomizeProduct routes through logEvent', () async {
      await facebookAppEvents.logCustomizeProduct();

      expect(
        methodCall,
        isMethodCall(
          'logEvent',
          arguments: <String, dynamic>{'name': 'CustomizeProduct'},
        ),
      );
    });

    test('logFindLocation routes through logEvent', () async {
      await facebookAppEvents.logFindLocation();

      expect(
        methodCall,
        isMethodCall(
          'logEvent',
          arguments: <String, dynamic>{'name': 'FindLocation'},
        ),
      );
    });

    test('logSchedule routes through logEvent', () async {
      await facebookAppEvents.logSchedule();

      expect(
        methodCall,
        isMethodCall(
          'logEvent',
          arguments: <String, dynamic>{'name': 'Schedule'},
        ),
      );
    });
  });
}
