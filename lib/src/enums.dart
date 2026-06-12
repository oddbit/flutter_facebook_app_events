// Copyright (c) Oddbit (https://oddbit.id)
//
// This source file is part of facebook_app_events.
// Licensed under the Apache License, Version 2.0. See LICENSE and NOTICE.

/// Type-safe enums that mirror the Facebook App Events native SDK enumerations.
///
/// Each value carries a stable wire token (its [Enum.name]) that the platform
/// handlers map back to the corresponding native SDK enum. Keeping the token
/// equal to the Dart `name` keeps the Dart ↔ Kotlin ↔ Swift contract obvious.
library;

/// Controls when the SDK flushes logged events to Meta's servers.
///
/// Mirrors `FBSDKAppEventsFlushBehavior` (iOS) and
/// `AppEventsLogger.FlushBehavior` (Android).
enum FlushBehavior {
  /// Events are flushed periodically and when the app is backgrounded.
  /// This is the SDK default.
  auto,

  /// Events are only sent when [FacebookAppEvents.flush] is called explicitly.
  explicitOnly,
}

/// Stock availability of a catalog item logged via
/// [FacebookAppEvents.logProductItem].
///
/// Mirrors `FBSDKProductAvailability` (iOS) and
/// `AppEventsLogger.ProductAvailability` (Android).
enum ProductAvailability {
  /// Item ships immediately.
  inStock,

  /// No plan to restock.
  outOfStock,

  /// Available in the future.
  preorder,

  /// Ships in 1–2 weeks.
  availableForOrder,

  /// Discontinued.
  discontinued,
}

/// Condition of a catalog item logged via
/// [FacebookAppEvents.logProductItem].
///
/// Mirrors `FBSDKProductCondition` (iOS) and
/// `AppEventsLogger.ProductCondition` (Android).
enum ProductCondition {
  /// A brand new item. Named `newItem` because `new` is a reserved Dart keyword;
  /// maps to the native `NEW` condition.
  newItem,

  /// A refurbished item.
  refurbished,

  /// A used item.
  used,
}

/// A single field of the hashed user data set via
/// [FacebookAppEvents.setUserData], used by
/// [FacebookAppEvents.clearUserDataForType].
///
/// Mirrors `FBSDKAppEventUserDataType` on iOS. Android's `AppEventsLogger`
/// has no per-field clear, so [FacebookAppEvents.clearUserDataForType] is a
/// no-op there (see the iOS/Android divergence note in the README).
enum FacebookUserDataField {
  email,
  firstName,
  lastName,
  phone,
  dateOfBirth,
  gender,
  city,
  state,
  zip,
  country,

  /// Your own identifier for the user (`extern_id`), used by Meta for
  /// advanced matching.
  externalId,
}

/// Parses a [FlushBehavior] from a wire token, defaulting to
/// [FlushBehavior.auto] for unknown values.
FlushBehavior flushBehaviorFromWire(String? token) {
  for (final value in FlushBehavior.values) {
    if (value.name == token) return value;
  }
  return FlushBehavior.auto;
}
