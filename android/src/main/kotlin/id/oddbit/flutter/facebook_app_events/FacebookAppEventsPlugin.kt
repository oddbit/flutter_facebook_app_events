package id.oddbit.flutter.facebook_app_events

import androidx.annotation.NonNull

import android.os.Bundle
import android.util.Log
import com.facebook.FacebookSdk
import com.facebook.appevents.AppEventsLogger
import com.facebook.GraphRequest
import com.facebook.GraphResponse
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.Currency
import com.facebook.LoggingBehavior

/** FacebookAppEventsPlugin */
class FacebookAppEventsPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var appEventsLogger: AppEventsLogger
  private lateinit var anonymousId: String

  private val logTag = "FacebookAppEvents"

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter.oddbit.id/facebook_app_events")
    channel.setMethodCallHandler(this)
    appEventsLogger = AppEventsLogger.newLogger(flutterPluginBinding.applicationContext)
    anonymousId = AppEventsLogger.getAnonymousAppDeviceGUID(flutterPluginBinding.applicationContext)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "clearUserData" -> handleClearUserData(call, result)
      "setUserData" -> handleSetUserData(call, result)
      "clearUserID" -> handleClearUserId(call, result)
      "flush" -> handleFlush(call, result)
      "getApplicationId" -> handleGetApplicationId(call, result)
      "logEvent" -> handleLogEvent(call, result)
      "logPushNotificationOpen" -> handlePushNotificationOpen(call, result)
      "setUserID" -> handleSetUserId(call, result)
      "setAutoLogAppEventsEnabled" -> handleSetAutoLogAppEventsEnabled(call, result)
      "setDataProcessingOptions" -> handleSetDataProcessingOptions(call, result)
      "getAnonymousId" -> handleGetAnonymousId(call, result)
      "logPurchase" -> handlePurchased(call, result)
      "setAdvertiserTracking" -> handleSetAdvertiserTracking(call, result)

      else -> result.notImplemented()
    }
  }

  private fun handleClearUserData(call: MethodCall, result: Result) {
    AppEventsLogger.clearUserData()
    result.success(null)
  }

  private fun handleSetUserData(call: MethodCall, result: Result) {
    val parameters = call.arguments as? Map<String, Any> ?: mapOf<String, Any>()
    val parameterBundle = createBundleFromMap(parameters)

    AppEventsLogger.setUserData(
      parameterBundle?.getString("email"),
      parameterBundle?.getString("firstName"),
      parameterBundle?.getString("lastName"),
      parameterBundle?.getString("phone"),
      parameterBundle?.getString("dateOfBirth"),
      parameterBundle?.getString("gender"),
      parameterBundle?.getString("city"),
      parameterBundle?.getString("state"),
      parameterBundle?.getString("zip"),
      parameterBundle?.getString("country")
    )

    result.success(null)
  }

  private fun handleClearUserId(call: MethodCall, result: Result) {
    AppEventsLogger.clearUserID()
    result.success(null)
  }

  private fun handleFlush(call: MethodCall, result: Result) {
    appEventsLogger.flush()
    result.success(null)
  }

  private fun handleGetApplicationId(call: MethodCall, result: Result) {
    result.success(appEventsLogger.applicationId)
  }
 private fun handleGetAnonymousId(call: MethodCall, result: Result) {
    result.success(anonymousId)
  }
  
  private fun handleSetAdvertiserTracking(call: MethodCall, result: Result) {
    val enabled = call.argument<Boolean>("enabled") ?: false
    val collectId = call.argument<Boolean>("collectId") ?: true

    FacebookSdk.setAdvertiserIDCollectionEnabled(collectId)
    FacebookSdk.setIsDebugEnabled(enabled)
    // Enable logging for debug builds
    if (enabled && BuildConfig.BUILD_TYPE == "debug") {
      FacebookSdk.addLoggingBehavior(LoggingBehavior.APP_EVENTS)
      FacebookSdk.addLoggingBehavior(LoggingBehavior.REQUESTS)
    }
    result.success(null)
  }

  private fun handleLogEvent(call: MethodCall, result: Result) {
    val eventName = call.argument<String>("name")
    if (eventName == null) {
      result.error("INVALID_ARGUMENT", "Event name is required and cannot be null.", null)
      return
    }
    val parameters = call.argument<Map<String, Any>>("parameters")
    val valueToSum = call.argument<Double>("_valueToSum")

    if (valueToSum != null && parameters != null) {
      val parameterBundle = createBundleFromMap(parameters)
      appEventsLogger.logEvent(eventName, valueToSum, parameterBundle)
    } else if (valueToSum != null) {
      appEventsLogger.logEvent(eventName, valueToSum)
    } else if (parameters != null) {
      val parameterBundle = createBundleFromMap(parameters)
      appEventsLogger.logEvent(eventName, parameterBundle)
    } else {
      appEventsLogger.logEvent(eventName)
    }

    result.success(null)
  }

  private fun handlePushNotificationOpen(call: MethodCall, result: Result) {
    val action = call.argument<String>("action")
    val payload = call.argument<Map<String, Any>>("payload")
    val payloadBundle = createBundleFromMap(payload)
    if (payloadBundle == null) {
      result.error("INVALID_ARGUMENT", "Payload is required", null)
      return
    }

    if (action != null) {
      appEventsLogger.logPushNotificationOpen(payloadBundle, action)
    } else {
      appEventsLogger.logPushNotificationOpen(payloadBundle)
    }

    result.success(null)
  }

  private fun handleSetUserId(call: MethodCall, result: Result) {
    val id = call.arguments as? String
    if (id == null) {
      result.error("INVALID_ARGUMENT", "User ID is required", null)
      return
    }
    AppEventsLogger.setUserID(id)
    result.success(null)
  }

  private fun createBundleFromMap(parameterMap: Map<String, Any>?): Bundle? {
    if (parameterMap == null) {
      return null
    }

    val bundle = Bundle()
    for (jsonParam in parameterMap.entries) {
      val value = jsonParam.value
      val key = jsonParam.key
      when (value) {
        is String -> bundle.putString(key, value)
        is Int -> bundle.putInt(key, value)
        is Long -> bundle.putLong(key, value)
        is Double -> bundle.putDouble(key, value)
        is Boolean -> bundle.putBoolean(key, value)
        is Map<*, *> -> {
          @Suppress("UNCHECKED_CAST")
          val nestedBundle = createBundleFromMap(value as Map<String, Any>)
          bundle.putBundle(key, nestedBundle)
        }
        else -> throw IllegalArgumentException(
            "Unsupported value type: " + value.javaClass.kotlin)
      }
    }
    return bundle
  }

  private fun handleSetAutoLogAppEventsEnabled(call: MethodCall, result: Result) {
    val enabled = call.arguments as? Boolean ?: false
    FacebookSdk.setAutoLogAppEventsEnabled(enabled)
    result.success(null)
  }

  private fun handleSetDataProcessingOptions(call: MethodCall, result: Result) {
    val options = call.argument<ArrayList<String>>("options") ?: arrayListOf()
    val country = call.argument<Int>("country") ?: 0
    val state = call.argument<Int>("state") ?: 0

    FacebookSdk.setDataProcessingOptions(options.toTypedArray(), country, state)
    result.success(null)
  }

  private fun handlePurchased(call: MethodCall, result: Result) {
    val amount = call.argument<Double>("amount")?.toBigDecimal()
    val currencyCode = call.argument<String>("currency")
    if (amount == null || currencyCode == null) {
      result.error("INVALID_ARGUMENT", "Amount and currency are required", null)
      return
    }
    val currency = Currency.getInstance(currencyCode)
    val parameters = call.argument<Map<String, Any>>("parameters")
    val parameterBundle = createBundleFromMap(parameters) ?: Bundle()

    appEventsLogger.logPurchase(amount, currency, parameterBundle)
    result.success(null)
  }
}
