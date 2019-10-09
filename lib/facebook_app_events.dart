import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const MethodChannel facebookAppEventsChannel =
    MethodChannel('flutter.oddbit.id/facebook_app_events');

class FacebookAppEvents {
  static const MethodChannel _channel = facebookAppEventsChannel;

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  Future<void> logEvent({
    @required String name,
    Map<String, dynamic> parameters,
    double valueToSum,
  }) async {
    final arguments = <String, dynamic>{
      'name': name,
      'parameters': parameters,
      'valueToSum': valueToSum,
    };

    await _channel.invokeMethod<void>('logEvent', arguments);
  }

  Future<void> setUserID(String id) async {
    await _channel.invokeMethod<void>('setUserID', id);
  }

  Future<void> clearUserID() async {
    await _channel.invokeMethod<void>('clearUserID');
  }
}
