import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const channelName = 'flutter.oddbit.id/facebook_app_events';

class FacebookAppEvents {
  static const _channel = MethodChannel(channelName);

  Future<void> clearUserData() {
    return _channel.invokeMethod<void>('clearUserData');
  }

  Future<void> clearUserID() {
    return _channel.invokeMethod<void>('clearUserID');
  }

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

  Future<void> setUserID(String id) {
    return _channel.invokeMethod<void>('setUserID', id);
  }

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
