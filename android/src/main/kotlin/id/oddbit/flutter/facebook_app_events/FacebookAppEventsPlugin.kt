// Copyright (c) Oddbit (https://oddbit.id)
//
// This source file is part of facebook_app_events.
// Licensed under the Apache License, Version 2.0. See LICENSE and NOTICE.

package id.oddbit.flutter.facebook_app_events

import androidx.annotation.NonNull

import android.app.Application
import android.content.Context
import android.os.Bundle
import android.util.Log
import com.facebook.FacebookSdk
import com.facebook.appevents.AppEventsLogger
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.math.BigDecimal
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

  private var application: Application? = null
  private var applicationContext: Context? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter.oddbit.id/facebook_app_events")
    channel.setMethodCallHandler(this)

    applicationContext = flutterPluginBinding.applicationContext
    application = flutterPluginBinding.applicationContext.applicationContext as? Application
    appEventsLogger = AppEventsLogger.newLogger(flutterPluginBinding.applicationContext)
    anonymousId = AppEventsLogger.getAnonymousAppDeviceGUID(flutterPluginBinding.applicationContext)

    // Override the Graph API version because Facebook Android SDK v18.x still defaults to v16.0,
    // which was removed by Meta on May 14, 2025. This is a known upstream issue:
    // https://github.com/facebook/facebook-android-sdk/issues/1308
    // Note: the SDK emits a Log.w in release builds when this is called, but the version is
    // still applied. This is intentional and correct behavior for a plugin.
    FacebookSdk.setGraphApiVersion("v24.0")
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    application = null
    applicationContext = null
    channel.setMethodCallHandler(null)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "activateApp" -> handleActivateApp(call, result)
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
      "setAdvertiserIdCollectionEnabled" -> handleSetAdvertiserIdCollectionEnabled(call, result)
      "setLimitEventAndDataUsage" -> handleSetLimitEventAndDataUsage(call, result)
      "setGraphApiVersion" -> handleSetGraphApiVersion(call, result)
      "logProductItem" -> handleLogProductItem(call, result)
      "setPushNotificationsDeviceToken", "setPushNotificationToken" -> handleSetPushNotificationToken(call, result)
      "setFlushBehavior" -> handleSetFlushBehavior(call, result)
      "getFlushBehavior" -> handleGetFlushBehavior(call, result)
      "getUserData" -> handleGetUserData(call, result)
      "getUserID" -> handleGetUserId(call, result)
      "clearUserDataForType" -> handleClearUserDataForType(call, result)
      "setDebugLoggingEnabled" -> handleSetDebugLoggingEnabled(call, result)

      else -> result.notImplemented()
    }
  }

  private fun handleActivateApp(call: MethodCall, result: Result) {
      val application = this.application

      if (application == null) {
          result.error("missing_application", "could not activate app: Android application is missing", null)
          return
      }

      val applicationId = call.argument("applicationId") as? String

      AppEventsLogger.activateApp(application, applicationId)

      result.success(null)
  }

  private fun handleClearUserData(call: MethodCall, result: Result) {
    AppEventsLogger.clearUserData()
    result.success(null)
  }

  private fun handleSetUserData(call: MethodCall, result: Result) {
    val arguments = call.arguments as? Map<String, Any?> ?: emptyMap()

    // Merge semantics: the native SDK only stores non-null fields and leaves
    // previously-set fields untouched, matching the iOS handler. Clearing is
    // done explicitly via clearUserData.
    AppEventsLogger.setUserData(
      arguments["email"] as? String,
      arguments["firstName"] as? String,
      arguments["lastName"] as? String,
      arguments["phone"] as? String,
      arguments["dateOfBirth"] as? String,
      arguments["gender"] as? String,
      arguments["city"] as? String,
      arguments["state"] as? String,
      arguments["zip"] as? String,
      arguments["country"] as? String,
      arguments["externalId"] as? String
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
  
  private fun handleSetGraphApiVersion(call: MethodCall, result: Result) {
    val version = call.arguments as? String
    if (version == null) {
      result.error("INVALID_ARGUMENT", "Graph API version string is required", null)
      return
    }
    FacebookSdk.setGraphApiVersion(version)
    result.success(null)
  }

  private fun handleSetAdvertiserTracking(call: MethodCall, result: Result) {
    val enabled = call.argument<Boolean>("enabled") ?: false
    val collectId = call.argument<Boolean>("collectId") ?: true

    FacebookSdk.setAdvertiserIDCollectionEnabled(enabled && collectId)

    result.success(null)
  }

  private fun handleSetAdvertiserIdCollectionEnabled(call: MethodCall, result: Result) {
    val enabled = call.arguments as? Boolean ?: false
    FacebookSdk.setAdvertiserIDCollectionEnabled(enabled)
    result.success(null)
  }

  private fun handleSetLimitEventAndDataUsage(call: MethodCall, result: Result) {
    val context = applicationContext
    if (context == null) {
      result.error("missing_context", "could not set limitEventAndDataUsage: Android context is missing", null)
      return
    }
    val enabled = call.arguments as? Boolean ?: false
    FacebookSdk.setLimitEventAndDataUsage(context, enabled)
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

  private fun createBundleFromMap(parameterMap: Map<String, Any?>?): Bundle? {
    if (parameterMap == null) {
      return null
    }

    val bundle = Bundle()
    for (jsonParam in parameterMap.entries) {
      val value: Any? = jsonParam.value
      val key = jsonParam.key
      when (value) {
        null -> {
          // Ignore null values (Dart may send keys with null values).
        }
        is String -> bundle.putString(key, value)
        is Int -> bundle.putInt(key, value)
        is Long -> bundle.putLong(key, value)
        is Double -> bundle.putDouble(key, value)
        is Boolean -> bundle.putBoolean(key, value)
        is Map<*, *> -> {
          @Suppress("UNCHECKED_CAST")
          val nestedBundle = createBundleFromMap(value as? Map<String, Any?>)
          if (nestedBundle != null) {
            bundle.putBundle(key, nestedBundle)
          }
        }
        else -> throw IllegalArgumentException(
            "Unsupported value type: ${value::class}")
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
    val currency = currencyFromCode(currencyCode)
    if (currency == null) {
      result.error("INVALID_ARGUMENT", "'$currencyCode' is not a valid ISO 4217 currency code", null)
      return
    }
    val parameters = call.argument<Map<String, Any>>("parameters")
    val parameterBundle = createBundleFromMap(parameters) ?: Bundle()

    appEventsLogger.logPurchase(amount, currency, parameterBundle)
    result.success(null)
  }

  private fun handleLogProductItem(call: MethodCall, result: Result) {
    val itemId = call.argument<String>("itemId")
    val availabilityToken = call.argument<String>("availability")
    val conditionToken = call.argument<String>("condition")
    val description = call.argument<String>("description")
    val imageLink = call.argument<String>("imageLink")
    val link = call.argument<String>("link")
    val title = call.argument<String>("title")
    val priceAmount = call.argument<Double>("priceAmount")
    val currencyCode = call.argument<String>("currency")
    val gtin = call.argument<String>("gtin")
    val mpn = call.argument<String>("mpn")
    val brand = call.argument<String>("brand")

    if (itemId == null || availabilityToken == null || conditionToken == null ||
        description == null || imageLink == null || link == null || title == null ||
        priceAmount == null || currencyCode == null) {
      result.error("INVALID_ARGUMENT", "Missing required logProductItem fields", null)
      return
    }
    if (gtin == null && mpn == null && brand == null) {
      result.error("INVALID_ARGUMENT", "At least one of gtin, mpn or brand is required", null)
      return
    }

    val availability = productAvailabilityFromToken(availabilityToken)
    val condition = productConditionFromToken(conditionToken)
    if (availability == null || condition == null) {
      result.error("INVALID_ARGUMENT", "Invalid availability or condition value", null)
      return
    }

    val currency = currencyFromCode(currencyCode)
    if (currency == null) {
      result.error("INVALID_ARGUMENT", "'$currencyCode' is not a valid ISO 4217 currency code", null)
      return
    }

    val parameters = call.argument<Map<String, Any>>("parameters")
    val parameterBundle = createBundleFromMap(parameters) ?: Bundle()

    appEventsLogger.logProductItem(
      itemId,
      availability,
      condition,
      description,
      imageLink,
      link,
      title,
      BigDecimal.valueOf(priceAmount),
      currency,
      gtin,
      mpn,
      brand,
      parameterBundle
    )
    result.success(null)
  }

  private fun currencyFromCode(code: String): Currency? {
    return try {
      Currency.getInstance(code)
    } catch (e: IllegalArgumentException) {
      null
    }
  }

  private fun productAvailabilityFromToken(token: String): AppEventsLogger.ProductAvailability? {
    return when (token) {
      "inStock" -> AppEventsLogger.ProductAvailability.IN_STOCK
      "outOfStock" -> AppEventsLogger.ProductAvailability.OUT_OF_STOCK
      "preorder" -> AppEventsLogger.ProductAvailability.PREORDER
      // Note: the Android SDK enum constant is historically misspelled.
      "availableForOrder" -> AppEventsLogger.ProductAvailability.AVALIABLE_FOR_ORDER
      "discontinued" -> AppEventsLogger.ProductAvailability.DISCONTINUED
      else -> null
    }
  }

  private fun productConditionFromToken(token: String): AppEventsLogger.ProductCondition? {
    return when (token) {
      "newItem" -> AppEventsLogger.ProductCondition.NEW
      "refurbished" -> AppEventsLogger.ProductCondition.REFURBISHED
      "used" -> AppEventsLogger.ProductCondition.USED
      else -> null
    }
  }

  private fun handleSetPushNotificationToken(call: MethodCall, result: Result) {
    val token = call.arguments as? String
    if (token == null) {
      result.error("INVALID_ARGUMENT", "Push notification token is required", null)
      return
    }
    AppEventsLogger.setPushNotificationsRegistrationId(token)
    result.success(null)
  }

  private fun handleSetFlushBehavior(call: MethodCall, result: Result) {
    val behavior = when (call.arguments as? String) {
      "explicitOnly" -> AppEventsLogger.FlushBehavior.EXPLICIT_ONLY
      else -> AppEventsLogger.FlushBehavior.AUTO
    }
    AppEventsLogger.setFlushBehavior(behavior)
    result.success(null)
  }

  private fun handleGetFlushBehavior(call: MethodCall, result: Result) {
    val token = when (AppEventsLogger.getFlushBehavior()) {
      AppEventsLogger.FlushBehavior.EXPLICIT_ONLY -> "explicitOnly"
      else -> "auto"
    }
    result.success(token)
  }

  private fun handleGetUserData(call: MethodCall, result: Result) {
    result.success(AppEventsLogger.getUserData())
  }

  private fun handleGetUserId(call: MethodCall, result: Result) {
    result.success(AppEventsLogger.getUserID())
  }

  private fun handleClearUserDataForType(call: MethodCall, result: Result) {
    // Android's AppEventsLogger has no per-field clear; this is intentionally a
    // no-op. Use clearUserData() to clear all fields. See README "Known Limitations".
    Log.w(logTag, "clearUserDataForType is not supported on Android; use clearUserData() to clear all fields.")
    result.success(null)
  }

  private fun handleSetDebugLoggingEnabled(call: MethodCall, result: Result) {
    val enabled = call.arguments as? Boolean ?: false
    FacebookSdk.setIsDebugEnabled(enabled)
    if (enabled) {
      FacebookSdk.addLoggingBehavior(LoggingBehavior.APP_EVENTS)
      FacebookSdk.addLoggingBehavior(LoggingBehavior.REQUESTS)
    } else {
      FacebookSdk.removeLoggingBehavior(LoggingBehavior.APP_EVENTS)
      FacebookSdk.removeLoggingBehavior(LoggingBehavior.REQUESTS)
    }
    result.success(null)
  }
}
