// Copyright (c) Oddbit (https://oddbit.id)
//
// This source file is part of facebook_app_events.
// Licensed under the Apache License, Version 2.0. See LICENSE and NOTICE.

part of '../facebook_app_events.dart';

/// Convenience wrappers for Meta's remaining predefined standard events.
///
/// Each method routes through [FacebookAppEvents.logEvent] with the correct
/// standard event name and parameters, so there is no additional native code:
/// the behavior is identical to calling `logEvent` directly with the matching
/// `eventName*` constant.
///
/// See [standard events](https://developers.facebook.com/docs/app-events/best-practices#standard-events).
extension StandardEventLogging on FacebookAppEvents {
  /// Log this event when the user reaches a level in the app.
  Future<void> logAchievedLevel({
    String? level,
    Map<String, dynamic>? parameters,
  }) {
    return logEvent(
      name: FacebookAppEvents.eventNameAchievedLevel,
      parameters: {
        if (parameters != null) ...parameters,
        if (level != null) FacebookAppEvents.paramNameLevel: level,
      },
    );
  }

  /// Log this event when the user adds payment information.
  Future<void> logAddedPaymentInfo({
    Map<String, dynamic>? parameters,
  }) {
    return logEvent(
      name: FacebookAppEvents.eventNameAddedPaymentInfo,
      parameters: parameters,
    );
  }

  /// Log this event when the user completes the app's tutorial flow.
  Future<void> logCompletedTutorial({
    String? contentId,
    Map<String, dynamic>? parameters,
  }) {
    return logEvent(
      name: FacebookAppEvents.eventNameCompletedTutorial,
      parameters: {
        if (parameters != null) ...parameters,
        if (contentId != null) FacebookAppEvents.paramNameContentId: contentId,
      },
    );
  }

  /// Log this event when the user performs a search in the app.
  Future<void> logSearched({
    String? searchString,
    String? contentType,
    Map<String, dynamic>? parameters,
  }) {
    return logEvent(
      name: FacebookAppEvents.eventNameSearched,
      parameters: {
        if (parameters != null) ...parameters,
        if (searchString != null)
          FacebookAppEvents.paramNameSearchString: searchString,
        if (contentType != null)
          FacebookAppEvents.paramNameContentType: contentType,
      },
    );
  }

  /// Log this event when the user spends in-app credits.
  ///
  /// To be eligible for ad revenue optimization (ROAS), include the
  /// [valueToSum] (the credits value) and [currency].
  Future<void> logSpentCredits({
    double? valueToSum,
    String? contentType,
    String? contentId,
    Map<String, dynamic>? parameters,
  }) {
    return logEvent(
      name: FacebookAppEvents.eventNameSpentCredits,
      valueToSum: valueToSum,
      parameters: {
        if (parameters != null) ...parameters,
        if (contentType != null)
          FacebookAppEvents.paramNameContentType: contentType,
        if (contentId != null) FacebookAppEvents.paramNameContentId: contentId,
      },
    );
  }

  /// Log this event when the user unlocks an achievement.
  Future<void> logUnlockedAchievement({
    String? description,
    Map<String, dynamic>? parameters,
  }) {
    return logEvent(
      name: FacebookAppEvents.eventNameUnlockedAchievement,
      parameters: {
        if (parameters != null) ...parameters,
        if (description != null)
          FacebookAppEvents.paramNameDescription: description,
      },
    );
  }

  /// Log this event when the user contacts your business.
  Future<void> logContact({
    Map<String, dynamic>? parameters,
  }) {
    return logEvent(
      name: FacebookAppEvents.eventNameContact,
      parameters: parameters,
    );
  }

  /// Log this event when the user customizes a product.
  Future<void> logCustomizeProduct({
    Map<String, dynamic>? parameters,
  }) {
    return logEvent(
      name: FacebookAppEvents.eventNameCustomizeProduct,
      parameters: parameters,
    );
  }

  /// Log this event when the user donates funds.
  ///
  /// To be eligible for ad revenue optimization (ROAS), include the
  /// [valueToSum] (the donation amount) and [currency].
  Future<void> logDonate({
    double? valueToSum,
    String? currency,
    Map<String, dynamic>? parameters,
  }) {
    return logEvent(
      name: FacebookAppEvents.eventNameDonate,
      valueToSum: valueToSum,
      parameters: {
        if (parameters != null) ...parameters,
        if (currency != null) FacebookAppEvents.paramNameCurrency: currency,
      },
    );
  }

  /// Log this event when the user locates one of your physical locations.
  Future<void> logFindLocation({
    Map<String, dynamic>? parameters,
  }) {
    return logEvent(
      name: FacebookAppEvents.eventNameFindLocation,
      parameters: parameters,
    );
  }

  /// Log this event when the user schedules an appointment.
  Future<void> logSchedule({
    Map<String, dynamic>? parameters,
  }) {
    return logEvent(
      name: FacebookAppEvents.eventNameSchedule,
      parameters: parameters,
    );
  }

  /// Log this event when the user submits an application (e.g. job, loan).
  Future<void> logSubmitApplication({
    Map<String, dynamic>? parameters,
  }) {
    return logEvent(
      name: FacebookAppEvents.eventNameSubmitApplication,
      parameters: parameters,
    );
  }
}
