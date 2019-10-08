import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:facebook_app_events/facebook_app_events.dart';

void main() {
  const MethodChannel channel = MethodChannel('facebook_app_events');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await FacebookAppEvents.platformVersion, '42');
  });
}
