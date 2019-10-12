import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const channelName = 'flutter.oddbit.id/facebook_app_events';

class FacebookAppEvents {
  static const _channel = MethodChannel(channelName);

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

  /// Log an app event with the specified [name] and the supplied [parameters] value.
  Future<void> logEvent({
    @required String name,
    Map<String, dynamic> parameters,
    double valueToSum,
  }) {
    final args = <String, dynamic>{
      'name': name,
      'parameters': parameters,
      'valueToSum': valueToSum,
    };

    return _channel.invokeMethod<void>('logEvent', args);
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
}
