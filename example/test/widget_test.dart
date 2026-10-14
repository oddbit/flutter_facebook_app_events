// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:facebook_app_events_example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App renders correctly with all components',
      (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();

    // Verify app bar
    expect(find.text('Plugin example app'), findsOneWidget);

    // The example defers SDK initialization, so nothing is read from the
    // SDK until the consent button is pressed.
    expect(find.text('Initialize SDK (consent given)'), findsOneWidget);
    expect(find.text('SDK not initialized'), findsOneWidget);
    expect(find.textContaining('Anonymous ID:'), findsNothing);

    // Verify all buttons exist
    expect(find.text('Click me!'), findsOneWidget);
    expect(find.text('Set user data'), findsOneWidget);
    expect(find.text('Test logAddToCart'), findsOneWidget);
    expect(find.text('Test purchase!'), findsOneWidget);
    expect(find.text('Enable advertiser ID collection'), findsOneWidget);
    expect(find.text('Disable advertiser ID collection'), findsOneWidget);
    expect(find.text('Limit event and data usage'), findsOneWidget);
    expect(find.text('Enable Limited Data Use (LDU)'), findsOneWidget);
  });

  testWidgets('Consent button initializes the SDK, then reads the anonymous ID',
      (WidgetTester tester) async {
    const channel = MethodChannel(channelName);
    final calls = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall call) async {
        calls.add(call.method);
        return call.method == 'getAnonymousId' ? 'anon-123' : null;
      },
    );
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null));

    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();
    expect(calls, isEmpty);

    await tester.tap(find.text('Initialize SDK (consent given)'));
    await tester.pumpAndSettle();

    expect(calls, ['initializeSdk', 'getAnonymousId']);
    expect(find.text('Anonymous ID: anon-123'), findsOneWidget);
  });

  testWidgets('Button text content', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();

    // Verify button texts
    expect(find.widgetWithText(MaterialButton, 'Click me!'), findsOneWidget);
    expect(
        find.widgetWithText(MaterialButton, 'Set user data'), findsOneWidget);
    expect(find.widgetWithText(MaterialButton, 'Test logAddToCart'),
        findsOneWidget);
    expect(
        find.widgetWithText(MaterialButton, 'Test purchase!'), findsOneWidget);
    expect(
        find.widgetWithText(MaterialButton, 'Enable advertiser ID collection'),
        findsOneWidget);
    expect(
        find.widgetWithText(MaterialButton, 'Disable advertiser ID collection'),
        findsOneWidget);
  });
}
