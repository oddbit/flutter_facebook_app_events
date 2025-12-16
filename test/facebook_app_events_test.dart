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
}
