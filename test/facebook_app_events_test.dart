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
}
