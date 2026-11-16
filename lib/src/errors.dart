// Copyright (c) Oddbit (https://oddbit.id)
//
// This source file is part of facebook_app_events.
// Licensed under the Apache License, Version 2.0. See LICENSE and NOTICE.

/// Typed errors for failures reported by the plugin's native handlers.
library;

import 'package:flutter/services.dart';

/// Why a [FacebookAppEvents] call failed, as reported by the native handler.
///
/// Read it from [FacebookAppEventsException.errorCode].
enum FacebookAppEventsErrorCode {
  /// An argument was missing or malformed, for example a currency that is not
  /// a valid ISO 4217 code. The exception message says which one.
  invalidArgument('INVALID_ARGUMENT'),

  /// The native Facebook SDK is not initialized, so the call was rejected.
  /// Call [FacebookAppEvents.initializeSdk] first.
  ///
  /// On iOS this is the state before `initializeSdk()` when
  /// `FacebookAutoInitEnabled` is `false`. On Android it means the SDK's
  /// automatic start failed or was removed by the app.
  sdkNotInitialized('sdk_not_initialized'),

  /// [FacebookAppEvents.initializeSdk] was called and the native SDK could
  /// not start. The exception message carries the SDK's reason, usually a
  /// missing app id or client token. Calling it again will not help until
  /// the configuration is fixed. Android only.
  sdkInitializationFailed('sdk_initialization_failed'),

  /// The plugin has no Android `Context` to work with. Android only.
  missingContext('missing_context'),

  /// The plugin has no Android `Application` to work with. Android only.
  missingApplication('missing_application'),

  /// The native side reported a code this version of the plugin does not
  /// know, typically an exception thrown by the native SDK itself. The raw
  /// code is in [FacebookAppEventsException.code].
  unknown(null);

  const FacebookAppEventsErrorCode(this.wireCode);

  /// The string the native handlers send as [PlatformException.code], or
  /// `null` for [unknown].
  final String? wireCode;

  /// The value whose [wireCode] equals [code], or [unknown] if there is none.
  static FacebookAppEventsErrorCode fromWireCode(String code) {
    for (final value in values) {
      if (value.wireCode == code) {
        return value;
      }
    }
    return unknown;
  }
}

/// Thrown by [FacebookAppEvents] methods when the native handler reports an
/// error.
///
/// It extends [PlatformException], so code that catches `PlatformException`
/// and compares [code] strings keeps working. Prefer [errorCode]:
///
/// ```dart
/// try {
///   await facebookAppEvents.initializeSdk();
/// } on FacebookAppEventsException catch (e) {
///   if (e.errorCode == FacebookAppEventsErrorCode.sdkInitializationFailed) {
///     // e.message is the native SDK's reason.
///   }
/// }
/// ```
class FacebookAppEventsException extends PlatformException {
  /// Wraps the [PlatformException] received from the native handler.
  FacebookAppEventsException.fromPlatformException(PlatformException exception)
      : errorCode = FacebookAppEventsErrorCode.fromWireCode(exception.code),
        super(
          code: exception.code,
          message: exception.message,
          details: exception.details,
          stacktrace: exception.stacktrace,
        );

  /// The typed reason for the failure. [code] holds the same information as
  /// the raw string sent by the native handler.
  final FacebookAppEventsErrorCode errorCode;

  @override
  String toString() =>
      'FacebookAppEventsException(${errorCode.name}, $code, $message, $details, $stacktrace)';
}
