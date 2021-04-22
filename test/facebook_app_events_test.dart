import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:facebook_app_events/facebook_app_events.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(channelName);
  final facebookAppEvents = FacebookAppEvents();


  MethodCall? methodCall;

  setUp(() async {
    channel.setMockMethodCallHandler((MethodCall m) async {
      methodCall = m;
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
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
}
