import 'dart:js';

import 'package:facebook_app_events/web/browser_interactor.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

class FacebookAppEventsPlugin {
  static MethodChannel channel;
  static FacebookAppEventsPlugin instance;
  BrowserInteractor _browserInteractor = BrowserInteractor();

  static void registerWith(Registrar registrar) {
    channel = MethodChannel('flutter.oddbit.id/facebook_app_events',
        const StandardMethodCodec(), registrar.messenger);

    instance = FacebookAppEventsPlugin();
    channel.setMethodCallHandler(instance.handleMethodCall);
  }

  Future<dynamic> handleMethodCall(MethodCall call) async {
    /*
    return _channel.invokeMethod<void>('clearUserData');
    return _channel.invokeMethod<void>('clearUserID');
    return _channel.invokeMethod<void>('flush');
    return _channel.invokeMethod<void>('getApplicationId');
    return _channel.invokeMethod<void>('logEvent', _filterOutNulls(args));
    return _channel.invokeMethod<void>('setUserData', args);
    return _channel.invokeMethod<void>('logPushNotificationOpen', args);
    return _channel.invokeMethod<void>('setUserID', id);
    return _channel.invokeMethod<void>('updateUserProperties', args);
    return _channel.invokeMethod<void>('setAutoLogAppEventsEnabled', enabled);
    return _channel.invokeMethod<void>('setIsDebugEnabled', enabled);
    */

    switch (call.method) {
      case 'logEvent':
        await _browserInteractor.callJSMethod(
            ['FB', 'AppEvents'], 'logEvent', [call.arguments['name']]);
        break;
      default:
        var message =
            "The flutter_facebook_login plugin for web doesn't implement the method '${call.method}'";
        throw PlatformException(code: 'Unimplemented', details: message);
    }
  }
}
