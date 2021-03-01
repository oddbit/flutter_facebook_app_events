import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const channelName = 'flutter.oddbit.id/facebook_app_events';

class FacebookAppEvents {
  static const _channel = MethodChannel(channelName);

  // See: https://github.com/facebook/facebook-android-sdk/blob/master/facebook-core/src/main/java/com/facebook/appevents/AppEventsConstants.java
  static const eventNameActivatedApp = 'fb_mobile_activate_app';
  static const eventNameDeactivatedApp = 'fb_mobile_deactivate_app';
  static const eventNameCompletedRegistration =
      'fb_mobile_complete_registration';
  static const eventNameViewedContent = 'fb_mobile_content_view';
  static const eventNameRated = 'fb_mobile_rate';
  static const eventNameInitiatedCheckout = 'fb_mobile_initiated_checkout';

  static const _paramNameValueToSum = "_valueToSum";
  static const paramNameCurrency = "fb_currency";
  static const paramNameRegistrationMethod = "fb_registration_method";
  static const paramNamePaymentInfoAvailable = "fb_payment_info_available";
  static const paramNameNumItems = "fb_num_items";
  static const paramValueYes = "1";
  static const paramValueNo = "0";

  /// Parameter key used to specify a generic content type/family for the logged event, e.g.
  /// "music", "photo", "video".  Options to use will vary depending on the nature of the app.
  static const paramNameContentType = "fb_content_type";

  /// Parameter key used to specify data for the one or more pieces of content being logged about.
  /// Data should be a JSON encoded string.
  /// Example:
  ///   "[{\"id\": \"1234\", \"quantity\": 2, \"item_price\": 5.99}, {\"id\": \"5678\", \"quantity\": 1, \"item_price\": 9.99}]"
  static const paramNameContent = "fb_content";

  /// Parameter key used to specify an ID for the specific piece of content being logged about.
  /// This could be an EAN, article identifier, etc., depending on the nature of the app.
  static const paramNameContentId = "fb_content_id";

  /// Clears the current user data
  Future<void> clearUserData() {
    return _channel.invokeMethod<void>('clearUserData');
  }

  /// Clears the currently set user id.
  Future<void> clearUserID() {
    return _channel.invokeMethod<void>('clearUserID');
  }

  /// Explicitly flush any stored events to the server.
  Future<void> flush() {
    return _channel.invokeMethod<void>('flush');
  }

  /// Returns the app ID this logger was configured to log to.
  Future<String> getApplicationId() {
    return _channel.invokeMethod<String>('getApplicationId');
  }

  Future<String> getAnonymousId() {
    return _channel.invokeMethod<String>('getAnonymousId');
  }

  /// Log an app event with the specified [name] and the supplied [parameters] value.
  Future<void> logEvent({
    @required String name,
    Map<String, dynamic> parameters,
    double valueToSum,
  }) {
    final args = <String, dynamic>{
      'name': name,
      'parameters': parameters,
      _paramNameValueToSum: valueToSum,
    };

    return _channel.invokeMethod<void>('logEvent', _filterOutNulls(args));
  }

  /// Sets user data to associate with all app events.
  /// All user data are hashed and used to match Facebook user from this
  /// instance of an application. The user data will be persisted between
  /// application instances.
  Future<void> setUserData({
    String email,
    String firstName,
    String lastName,
    String phone,
    String dateOfBirth,
    String gender,
    String city,
    String state,
    String zip,
    String country,
  }) {
    final args = <String, dynamic>{
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'city': city,
      'state': state,
      'zip': zip,
      'country': country,
    };

    return _channel.invokeMethod<void>('setUserData', args);
  }

  /// Logs an app event that tracks that the application was open via Push Notification.
  Future<void> logPushNotificationOpen({
    @required Map<String, dynamic> payload,
    String action,
  }) {
    final args = <String, dynamic>{
      'payload': payload,
      'action': action,
    };

    return _channel.invokeMethod<void>('logPushNotificationOpen', args);
  }

  /// Sets a user [id] to associate with all app events.
  /// This can be used to associate your own user id with the
  /// app events logged from this instance of an application.
  /// The user ID will be persisted between application instances.
  Future<void> setUserID(String id) {
    return _channel.invokeMethod<void>('setUserID', id);
  }

  /// Update user properties as provided by a map of [parameters]
  Future<void> updateUserProperties({
    @required Map<String, dynamic> parameters,
    String applicationId,
  }) {
    final args = <String, dynamic>{
      'parameters': parameters,
      'applicationId': applicationId,
    };

    return _channel.invokeMethod<void>('updateUserProperties', args);
  }

  // Below are shorthand implementations of the predefined app event constants

  /// Log this event when an app is being activated.
  ///
  /// See: https://developers.facebook.com/docs/reference/androidsdk/current/facebook/com/facebook/appevents/appeventsconstants.html/#eventnameactivatedapp
  Future<void> logActivatedApp() {
    return logEvent(name: eventNameActivatedApp);
  }

  /// Log this event when an app is being deactivated.
  ///
  /// See: https://developers.facebook.com/docs/reference/androidsdk/current/facebook/com/facebook/appevents/appeventsconstants.html/#eventnamedeactivatedapp
  Future<void> logDeactivatedApp() {
    return logEvent(name: eventNameDeactivatedApp);
  }

  /// Log this event when the user has completed registration with the app.
  /// Parameter [registrationMethod] is used to specify the method the user has
  /// used to register for the app, e.g. "Facebook", "email", "Google", etc.
  /// See: https://developers.facebook.com/docs/reference/androidsdk/current/facebook/com/facebook/appevents/appeventsconstants.html/#eventnamecompletedregistration
  Future<void> logCompletedRegistration({String registrationMethod}) {
    return logEvent(
      name: eventNameCompletedRegistration,
      parameters: {
        paramNameRegistrationMethod: registrationMethod,
      },
    );
  }

  /// Log this event when the user has rated an item in the app.
  ///
  /// See: https://developers.facebook.com/docs/reference/androidsdk/current/facebook/com/facebook/appevents/appeventsconstants.html/#eventnamerated
  Future<void> logRated({double valueToSum}) {
    return logEvent(
      name: eventNameRated,
      valueToSum: valueToSum,
    );
  }

  /// Log this event when the user has viewed a form of content in the app.
  ///
  /// See: https://developers.facebook.com/docs/reference/androidsdk/current/facebook/com/facebook/appevents/appeventsconstants.html/#eventnameviewedcontent
  Future<void> logViewContent({
    Map<String, dynamic> content,
    String id,
    String type,
  }) {
    return logEvent(
      name: eventNameViewedContent,
      parameters: {
        paramNameContent: content,
        paramNameContentId: id,
        paramNameContentType: type,
      },
    );
  }

  /// Re-enables auto logging of app events after user consent
  /// if disabled for GDPR-compliance.
  ///
  /// See: https://developers.facebook.com/docs/app-events/gdpr-compliance
  Future<void> setAutoLogAppEventsEnabled(bool enabled) {
    return _channel.invokeMethod<void>('setAutoLogAppEventsEnabled', enabled);
  }

  /// Set Data Processing Options
  /// This is needed for California Consumer Privacy Act (CCPA) compliance
  ///
  /// See: https://developers.facebook.com/docs/marketing-apis/data-processing-options
  Future<void> setDataProcessingOptions(
    List<String> options, {
    int country,
    int state,
  }) {
    final args = <String, dynamic>{
      'options': options,
      'country': country,
      'state': state,
    };

    return _channel.invokeMethod<void>('setDataProcessingOptions', args);
  }

  Future<void> logPurchase({
    @required double amount,
    @required String currency,
    Map<String, dynamic> parameters,
  }) {
    final args = <String, dynamic>{
      'amount': amount,
      'currency': currency,
      'parameters': parameters,
    };
    return _channel.invokeMethod<void>('logPurchase', _filterOutNulls(args));
  }

  Future<void> logInitiatedCheckout({
    @required double totalPrice,
    @required String currency,
    @required String contentType,
    @required String contentId,
    @required int numItems,
    bool paymentInfoAvailable = false,
  }) {
    return logEvent(
      name: eventNameInitiatedCheckout,
      valueToSum: totalPrice,
      parameters: {
        paramNameContentType: contentType,
        paramNameContentId: contentId,
        paramNameNumItems: numItems,
        paramNameCurrency: currency,
        paramNamePaymentInfoAvailable:
            paymentInfoAvailable ? paramValueYes : paramValueNo,
      },
    );
  }

   /// Sets the Advert Tracking propeety for iOS advert tracking 
   /// an iOS 14+ feature, android should just return a success. 
  Future<void> setAdvertiserTracking({
    @required bool enabled,
  }) {
    final args = <String, dynamic>{
      'enabled': enabled
    };

    return _channel.invokeMethod<void>('setAdvertiserTracking', args);
  }


  // ---------------------------------------------------------------------------
  // ---------------------------------------------------------------------------
  //
  // PRIVATE METHODS BELOW HERE

  /// Creates a new map containing all of the key/value pairs from [parameters]
  /// except those whose value is `null`.
  Map<String, dynamic> _filterOutNulls(Map<String, dynamic> parameters) {
    final Map<String, dynamic> filtered = <String, dynamic>{};
    parameters.forEach((String key, dynamic value) {
      if (value != null) {
        filtered[key] = value;
      }
    });
    return filtered;
  }
}
