// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:facebook_app_events_example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App renders correctly with all components',
      (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();

    // Verify app bar
    expect(find.text('Plugin example app'), findsOneWidget);

    // Verify Anonymous ID text
    expect(find.textContaining('Anonymous ID:'), findsOneWidget);

    // Verify all buttons exist
    expect(find.text('Click me!'), findsOneWidget);
    expect(find.text('Set user data'), findsOneWidget);
    expect(find.text('Test logAddToCart'), findsOneWidget);
    expect(find.text('Test purchase!'), findsOneWidget);
    expect(find.text('Enable advertise tracking!'), findsOneWidget);
    expect(find.text('Disabled advertise tracking!'), findsOneWidget);
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
    expect(find.widgetWithText(MaterialButton, 'Enable advertise tracking!'),
        findsOneWidget);
    expect(find.widgetWithText(MaterialButton, 'Disabled advertise tracking!'),
        findsOneWidget);
  });
}
