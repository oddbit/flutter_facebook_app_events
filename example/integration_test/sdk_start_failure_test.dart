// Android only, and only meaningful on a build whose manifest has no
// `com.facebook.sdk.ClientToken`, which makes the Facebook SDK fail to start.
// CI removes that entry before running this file:
//
//   flutter test integration_test/sdk_start_failure_test.dart -d <device>
//
// This is the situation behind
// https://github.com/oddbit/flutter_facebook_app_events/issues/516: the SDK
// swallows its own failed start, and the plugin has to report it.

import 'dart:io';

import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

Matcher throwsErrorCode(FacebookAppEventsErrorCode code) => throwsA(
      isA<FacebookAppEventsException>()
          .having((e) => e.errorCode, 'errorCode', code),
    );

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final facebookAppEvents = FacebookAppEvents();

  testWidgets('calls that need the SDK report that it is not initialized',
      (tester) async {
    await expectLater(
      facebookAppEvents.logEvent(name: 'integration_test_no_sdk'),
      throwsErrorCode(FacebookAppEventsErrorCode.sdkNotInitialized),
    );
    await expectLater(
      facebookAppEvents.getApplicationId(),
      throwsErrorCode(FacebookAppEventsErrorCode.sdkNotInitialized),
    );
    await expectLater(
      facebookAppEvents.flush(),
      throwsErrorCode(FacebookAppEventsErrorCode.sdkNotInitialized),
    );
  }, skip: !Platform.isAndroid);

  testWidgets('setGraphApiVersion does not need the SDK', (tester) async {
    await facebookAppEvents.setGraphApiVersion('v24.0');
  }, skip: !Platform.isAndroid);

  testWidgets('initializeSdk reports why the SDK cannot start', (tester) async {
    await expectLater(
      facebookAppEvents.initializeSdk(),
      throwsA(
        isA<FacebookAppEventsException>()
            .having(
              (e) => e.errorCode,
              'errorCode',
              FacebookAppEventsErrorCode.sdkInitializationFailed,
            )
            .having(
              (e) => e.message,
              'message',
              contains('client token'),
            ),
      ),
    );

    // Still not initialized afterwards, and still reported as such.
    await expectLater(
      facebookAppEvents.logEvent(name: 'integration_test_no_sdk'),
      throwsErrorCode(FacebookAppEventsErrorCode.sdkNotInitialized),
    );
  }, skip: !Platform.isAndroid);
}
