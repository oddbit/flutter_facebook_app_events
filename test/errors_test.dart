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

  // The wire strings are public: apps may compare `PlatformException.code`
  // against them. Spelled out here, not derived from the enum, so a renamed or
  // swapped wire code fails a test.
  const wireCodes = <String, FacebookAppEventsErrorCode>{
    'INVALID_ARGUMENT': FacebookAppEventsErrorCode.invalidArgument,
    'sdk_not_initialized': FacebookAppEventsErrorCode.sdkNotInitialized,
    'sdk_initialization_failed':
        FacebookAppEventsErrorCode.sdkInitializationFailed,
    'missing_context': FacebookAppEventsErrorCode.missingContext,
    'missing_application': FacebookAppEventsErrorCode.missingApplication,
  };

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('FacebookAppEventsErrorCode', () {
    test('every value has the wire code that has shipped', () {
      expect(
        {
          for (final value in FacebookAppEventsErrorCode.values)
            if (value.wireCode != null) value.wireCode: value,
        },
        wireCodes,
      );
      expect(FacebookAppEventsErrorCode.unknown.wireCode, isNull);
    });

    test('fromWireCode maps each wire code to its value', () {
      wireCodes.forEach((wireCode, value) {
        expect(FacebookAppEventsErrorCode.fromWireCode(wireCode), value);
      });
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

  // Every plugin method must reach the channel through the one wrapper that
  // converts errors. The channel exists only inside that wrapper; this fails
  // if a second `invokeMethod` call appears anywhere in lib/.
  test('lib/ calls the method channel in exactly one place', () {
    final calls = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .expand((file) =>
            RegExp(r'\binvokeMethod\b').allMatches(file.readAsStringSync()))
        .length;
    expect(calls, 1);
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
      for (final MapEntry(key: wireCode, value: value) in wireCodes.entries) {
        failWith(PlatformException(code: wireCode));

        await expectLater(
          facebookAppEvents.flush(),
          throwsA(
            isA<FacebookAppEventsException>()
                .having((e) => e.errorCode, 'errorCode', value)
                .having((e) => e.code, 'code', wireCode),
          ),
        );
      }
    });

    // Checked on the constructor: the test binding's mock channel drops the
    // `stacktrace` field when it encodes a thrown PlatformException.
    test('forwards the native stack trace', () {
      final exception = FacebookAppEventsException.fromPlatformException(
        PlatformException(
          code: 'error',
          message: 'boom',
          stacktrace: 'java.lang.IllegalStateException: boom',
        ),
      );
      expect(exception.stacktrace, 'java.lang.IllegalStateException: boom');
    });

    test('keeps the Dart stack trace of the failed channel call', () async {
      failWith(PlatformException(code: 'sdk_not_initialized'));

      late StackTrace rethrown;
      try {
        await facebookAppEvents.flush();
        fail('flush should have thrown');
      } on FacebookAppEventsException catch (_, stackTrace) {
        rethrown = stackTrace;
      }
      // A plain `throw` inside the wrapper would start the trace at the
      // wrapper; the original one comes from the channel's own decoding.
      expect(rethrown.toString(), contains('invokeMethod'));
    });

    test('can be created from an error code', () {
      final exception = FacebookAppEventsException(
        FacebookAppEventsErrorCode.sdkNotInitialized,
        message: 'not yet',
      );
      expect(exception.code, 'sdk_not_initialized');
      expect(exception.message, 'not yet');
      expect(
        FacebookAppEventsException(FacebookAppEventsErrorCode.unknown).code,
        'unknown',
      );
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
