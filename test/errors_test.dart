import 'dart:io';

import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(channelName);
  final facebookAppEvents = FacebookAppEvents();

  void failWith(Object error) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall m) async => throw error);
  }

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('FacebookAppEventsErrorCode', () {
    test('wire codes are unique', () {
      final wireCodes = FacebookAppEventsErrorCode.values
          .map((value) => value.wireCode)
          .whereType<String>()
          .toList();
      expect(wireCodes.toSet(), hasLength(wireCodes.length));
    });

    test('fromWireCode maps every known wire code back to its value', () {
      for (final value in FacebookAppEventsErrorCode.values) {
        final wireCode = value.wireCode;
        if (wireCode == null) continue;
        expect(FacebookAppEventsErrorCode.fromWireCode(wireCode), value);
      }
    });

    test('fromWireCode falls back to unknown', () {
      expect(
        FacebookAppEventsErrorCode.fromWireCode('error'),
        FacebookAppEventsErrorCode.unknown,
      );
    });

    // The native handlers and this enum are kept in sync by hand. Scan the
    // handler sources for the codes they send so a new one cannot be added
    // without a matching enum value.
    test('covers every error code the native handlers send', () {
      final sources = <String, RegExp>{
        'android/src/main/kotlin/id/oddbit/flutter/facebook_app_events/FacebookAppEventsPlugin.kt':
            RegExp(r'result\.error\(\s*"([^"]+)"'),
        'ios/facebook_app_events/Sources/facebook_app_events/FacebookAppEventsPlugin.swift':
            RegExp(r'FlutterError\(\s*code:\s*"([^"]+)"'),
      };
      final known = FacebookAppEventsErrorCode.values
          .map((value) => value.wireCode)
          .toSet();

      sources.forEach((path, pattern) {
        final file = File(path);
        expect(file.existsSync(), isTrue, reason: '$path should exist');
        final sent = pattern
            .allMatches(file.readAsStringSync())
            .map((match) => match.group(1))
            .toSet();
        expect(sent, isNotEmpty, reason: 'no error codes found in $path');
        expect(
          sent.difference(known),
          isEmpty,
          reason: '$path sends error codes that FacebookAppEventsErrorCode '
              'does not list',
        );
      });
    });
  });

  group('FacebookAppEventsException', () {
    test('native errors are rethrown with a typed error code', () async {
      failWith(PlatformException(
        code: 'sdk_initialization_failed',
        message: 'A valid Facebook app client token must be set',
        details: 'details',
      ));

      await expectLater(
        facebookAppEvents.initializeSdk(),
        throwsA(
          isA<FacebookAppEventsException>()
              .having(
                (e) => e.errorCode,
                'errorCode',
                FacebookAppEventsErrorCode.sdkInitializationFailed,
              )
              .having((e) => e.code, 'code', 'sdk_initialization_failed')
              .having(
                (e) => e.message,
                'message',
                'A valid Facebook app client token must be set',
              )
              .having((e) => e.details, 'details', 'details'),
        ),
      );
    });

    test('is still catchable as a PlatformException by string code', () async {
      failWith(PlatformException(code: 'sdk_not_initialized'));

      await expectLater(
        facebookAppEvents.logEvent(name: 'test-event'),
        throwsA(
          isA<PlatformException>()
              .having((e) => e.code, 'code', 'sdk_not_initialized'),
        ),
      );
    });

    test('maps each known wire code', () async {
      for (final value in FacebookAppEventsErrorCode.values) {
        final wireCode = value.wireCode;
        if (wireCode == null) continue;
        failWith(PlatformException(code: wireCode));

        await expectLater(
          facebookAppEvents.flush(),
          throwsA(
            isA<FacebookAppEventsException>()
                .having((e) => e.errorCode, 'errorCode', value),
          ),
        );
      }
    });

    test('keeps the raw code when it is not a known one', () async {
      failWith(PlatformException(code: 'error', message: 'boom'));

      await expectLater(
        facebookAppEvents.getApplicationId(),
        throwsA(
          isA<FacebookAppEventsException>()
              .having(
                (e) => e.errorCode,
                'errorCode',
                FacebookAppEventsErrorCode.unknown,
              )
              .having((e) => e.code, 'code', 'error')
              .having((e) => e.message, 'message', 'boom'),
        ),
      );
    });

    test('a missing plugin is not turned into a typed exception', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);

      await expectLater(
        facebookAppEvents.flush(),
        throwsA(isA<MissingPluginException>()),
      );
    });

    test('toString names the typed code', () {
      final exception = FacebookAppEventsException.fromPlatformException(
        PlatformException(code: 'INVALID_ARGUMENT', message: 'bad currency'),
      );
      expect(exception.toString(), contains('invalidArgument'));
      expect(exception.toString(), contains('bad currency'));
    });
  });
}
