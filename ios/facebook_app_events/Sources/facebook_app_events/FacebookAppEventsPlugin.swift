// Copyright (c) Oddbit (https://oddbit.id)
//
// This source file is part of facebook_app_events.
// Licensed under the Apache License, Version 2.0. See LICENSE and NOTICE.

import Flutter
import UIKit
import FBSDKCoreKit
import FBSDKCoreKit_Basics

public class FacebookAppEventsPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "flutter.oddbit.id/facebook_app_events",
            binaryMessenger: registrar.messenger()
        )
        let instance = FacebookAppEventsPlugin()

        // Required for FB SDK 9.0, as it does not initialize the SDK automatically any more.
        // See: https://developers.facebook.com/blog/post/2021/01/19/introducing-facebook-platform-sdk-version-9/
        // "Removal of Auto Initialization of SDK" section
        ApplicationDelegate.shared.initializeSDK()

        // Override the Graph API version because Facebook iOS SDK v18.x still defaults to v17.0,
        // which was removed by Meta on September 12, 2025. This is a known upstream issue:
        // https://github.com/facebook/facebook-ios-sdk/issues/2610
        Settings.shared.graphAPIVersion = "v24.0"

        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addApplicationDelegate(instance)
    }

    /// Connect app delegate with SDK
    public func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        // For Facebook SDK 18.x+, use the simplified URL handling
        return ApplicationDelegate.shared.application(app, open: url, options: options)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "activateApp":
            handleActivateApp(call, result: result)
        case "clearUserData":
            handleClearUserData(call, result: result)
        case "setUserData":
            handleSetUserData(call, result: result)
        case "clearUserID":
            handleClearUserID(call, result: result)
        case "flush":
            handleFlush(call, result: result)
        case "getApplicationId":
            handleGetApplicationId(call, result: result)
        case "logEvent":
            handleLogEvent(call, result: result)
        case "logPushNotificationOpen":
            handlePushNotificationOpen(call, result: result)
        case "setUserID":
            handleSetUserId(call, result: result)
        case "setAutoLogAppEventsEnabled":
            handleSetAutoLogAppEventsEnabled(call, result: result)
        case "setDataProcessingOptions":
            handleSetDataProcessingOptions(call, result: result)
        case "logPurchase":
            handlePurchased(call, result: result)
        case "getAnonymousId":
            handleGetAnonymousId(call, result: result)
        case "setAdvertiserTracking":
            handleSetAdvertiserTracking(call, result: result)
        case "setGraphApiVersion":
            handleSetGraphApiVersion(call, result: result)
        case "logProductItem":
            handleLogProductItem(call, result: result)
        case "setPushNotificationToken":
            handleSetPushNotificationToken(call, result: result)
        case "setFlushBehavior":
            handleSetFlushBehavior(call, result: result)
        case "getFlushBehavior":
            handleGetFlushBehavior(call, result: result)
        case "getUserData":
            handleGetUserData(call, result: result)
        case "getUserID":
            handleGetUserID(call, result: result)
        case "clearUserDataForType":
            handleClearUserDataForType(call, result: result)
        case "setDebugLoggingEnabled":
            handleSetDebugLoggingEnabled(call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func handleActivateApp(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? [String: Any] ?? [:]

        if let applicationId = arguments["applicationId"] as? String, !applicationId.isEmpty {
            AppEvents.shared.loggingOverrideAppID = applicationId
        }

        AppEvents.shared.activateApp()
        result(nil)
    }

    private func handleClearUserData(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        AppEvents.shared.clearUserData()
        result(nil)
    }

    private func handleSetUserData(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? [String: Any] ?? [:]

        AppEvents.shared.setUserData(arguments["email"] as? String, forType: FBSDKAppEventUserDataType.email)
        AppEvents.shared.setUserData(arguments["firstName"] as? String, forType: FBSDKAppEventUserDataType.firstName)
        AppEvents.shared.setUserData(arguments["lastName"] as? String, forType: FBSDKAppEventUserDataType.lastName)
        AppEvents.shared.setUserData(arguments["phone"] as? String, forType: FBSDKAppEventUserDataType.phone)
        AppEvents.shared.setUserData(arguments["dateOfBirth"] as? String, forType: FBSDKAppEventUserDataType.dateOfBirth)
        AppEvents.shared.setUserData(arguments["gender"] as? String, forType: FBSDKAppEventUserDataType.gender)
        AppEvents.shared.setUserData(arguments["city"] as? String, forType: FBSDKAppEventUserDataType.city)
        AppEvents.shared.setUserData(arguments["state"] as? String, forType: FBSDKAppEventUserDataType.state)
        AppEvents.shared.setUserData(arguments["zip"] as? String, forType: FBSDKAppEventUserDataType.zip)
        AppEvents.shared.setUserData(arguments["country"] as? String, forType: FBSDKAppEventUserDataType.country)

        result(nil)
    }

    private func handleClearUserID(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        AppEvents.shared.userID = nil
        result(nil)
    }

    private func handleFlush(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        AppEvents.shared.flush()
        result(nil)
    }

    private func handleGetApplicationId(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Facebook SDK 18.x+: appID property was removed from Settings
        // Retrieve from Info.plist FacebookAppID key as fallback
        let appId = Bundle.main.object(forInfoDictionaryKey: "FacebookAppID") as? String
        result(appId)
    }

    private func handleGetAnonymousId(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(AppEvents.shared.anonymousID)
    }

    private func handleLogEvent(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? [String: Any] ?? [:]
        guard let eventName = arguments["name"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Event name is required and cannot be null.", details: nil))
            return
        }

        let rawParams = arguments["parameters"] as? [String: Any] ?? [:]
        let parameters: [AppEvents.ParameterName: Any] = Dictionary(
            uniqueKeysWithValues: rawParams.map { key, value in
                (AppEvents.ParameterName(key), value)
            }
        )

        if let valueToSum = arguments["_valueToSum"] as? Double {
            AppEvents.shared.logEvent(AppEvents.Name(eventName), valueToSum: valueToSum, parameters: parameters)
        } else {
            AppEvents.shared.logEvent(AppEvents.Name(eventName), parameters: parameters)
        }

        result(nil)
    }

    private func handlePushNotificationOpen(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? [String: Any] ?? [:]
        guard let payload = arguments["payload"] as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Payload is required", details: nil))
            return
        }

        if let action = arguments["action"] as? String {
            AppEvents.shared.logPushNotificationOpen(payload: payload, action: action)
        } else {
            AppEvents.shared.logPushNotificationOpen(payload: payload)
        }
        result(nil)
    }

    private func handleSetUserId(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let id = call.arguments as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "User ID is required", details: nil))
            return
        }
        AppEvents.shared.userID = id
        result(nil)
    }

    private func handleSetAutoLogAppEventsEnabled(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let enabled = call.arguments as? Bool ?? false
        Settings.shared.isAutoLogAppEventsEnabled = enabled
        result(nil)
    }

    private func handleSetDataProcessingOptions(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Facebook SDK 18.x+: setDataProcessingOptions was removed from Settings
        // Data processing options should now be configured via Facebook's Data Use Checkup
        // See: https://developers.facebook.com/docs/development/data-processing-options
        print("[FacebookAppEvents] setDataProcessingOptions() is not available in Facebook SDK 18.x+. Configure data processing options via Facebook's Data Use Checkup.")
        result(nil)
    }

    private func handlePurchased(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? [String: Any] ?? [:]
        guard let amount = arguments["amount"] as? Double,
              let currency = arguments["currency"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Amount and currency are required", details: nil))
            return
        }

        let rawParams = arguments["parameters"] as? [String: Any] ?? [:]
        let parameters: [AppEvents.ParameterName: Any] = Dictionary(
            uniqueKeysWithValues: rawParams.map { key, value in
                (AppEvents.ParameterName(key), value)
            }
        )

        AppEvents.shared.logPurchase(amount: amount, currency: currency, parameters: parameters)
        result(nil)
    }

    private func handleSetGraphApiVersion(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let version = call.arguments as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Graph API version string is required", details: nil))
            return
        }
        Settings.shared.graphAPIVersion = version
        result(nil)
    }

    private func handleSetAdvertiserTracking(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? [String: Any] ?? [:]
        let enabled = arguments["enabled"] as? Bool ?? false
        let collectId = arguments["collectId"] as? Bool ?? true

        Settings.shared.isAdvertiserTrackingEnabled = enabled
        Settings.shared.isAdvertiserIDCollectionEnabled = enabled && collectId

        result(nil)
    }

    private func handleLogProductItem(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? [String: Any] ?? [:]
        guard let itemId = arguments["itemId"] as? String,
              let availabilityToken = arguments["availability"] as? String,
              let conditionToken = arguments["condition"] as? String,
              let description = arguments["description"] as? String,
              let imageLink = arguments["imageLink"] as? String,
              let link = arguments["link"] as? String,
              let title = arguments["title"] as? String,
              let priceAmount = arguments["priceAmount"] as? Double,
              let currency = arguments["currency"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing required logProductItem fields", details: nil))
            return
        }

        let gtin = arguments["gtin"] as? String
        let mpn = arguments["mpn"] as? String
        let brand = arguments["brand"] as? String
        if gtin == nil && mpn == nil && brand == nil {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "At least one of gtin, mpn or brand is required", details: nil))
            return
        }

        guard let availability = Self.productAvailability(from: availabilityToken),
              let condition = Self.productCondition(from: conditionToken) else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid availability or condition value", details: nil))
            return
        }

        // logProductItem's `parameters` is typed [String: Any] (unlike
        // logEvent/logPurchase which use [AppEvents.ParameterName: Any]).
        let parameters = arguments["parameters"] as? [String: Any] ?? [:]

        AppEvents.shared.logProductItem(
            itemId,
            availability: availability,
            condition: condition,
            description: description,
            imageLink: imageLink,
            link: link,
            title: title,
            priceAmount: priceAmount,
            currency: currency,
            gtin: gtin,
            mpn: mpn,
            brand: brand,
            parameters: parameters
        )
        result(nil)
    }

    private static func productAvailability(from token: String) -> AppEvents.ProductAvailability? {
        switch token {
        case "inStock": return .inStock
        case "outOfStock": return .outOfStock
        case "preorder": return .preOrder
        case "availableForOrder": return .availableForOrder
        case "discontinued": return .discontinued
        default: return nil
        }
    }

    private static func productCondition(from token: String) -> AppEvents.ProductCondition? {
        switch token {
        case "newItem": return .new
        case "refurbished": return .refurbished
        case "used": return .used
        default: return nil
        }
    }

    private func handleSetPushNotificationToken(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let token = call.arguments as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Push notification token is required", details: nil))
            return
        }
        // The ObjC `setPushNotificationsDeviceTokenString:` is renamed in Swift
        // to `setPushNotificationsDeviceToken(_:)` via NS_SWIFT_NAME, overloaded
        // with the Data variant. Passing a String resolves to the String overload;
        // `setPushNotificationsDeviceTokenString` does not exist in Swift.
        AppEvents.shared.setPushNotificationsDeviceToken(token)
        result(nil)
    }

    private func handleSetFlushBehavior(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let behavior: AppEvents.FlushBehavior = (call.arguments as? String) == "explicitOnly" ? .explicitOnly : .auto
        AppEvents.shared.flushBehavior = behavior
        result(nil)
    }

    private func handleGetFlushBehavior(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch AppEvents.shared.flushBehavior {
        case .explicitOnly:
            result("explicitOnly")
        default:
            result("auto")
        }
    }

    private func handleGetUserData(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(AppEvents.shared.getUserData())
    }

    private func handleGetUserID(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(AppEvents.shared.userID)
    }

    private func handleClearUserDataForType(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let token = call.arguments as? String,
              let type = Self.userDataType(from: token) else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "A valid user data field is required", details: nil))
            return
        }
        AppEvents.shared.clearUserData(forType: type)
        result(nil)
    }

    private static func userDataType(from token: String) -> FBSDKAppEventUserDataType? {
        switch token {
        case "email": return .email
        case "firstName": return .firstName
        case "lastName": return .lastName
        case "phone": return .phone
        case "dateOfBirth": return .dateOfBirth
        case "gender": return .gender
        case "city": return .city
        case "state": return .state
        case "zip": return .zip
        case "country": return .country
        default: return nil
        }
    }

    private func handleSetDebugLoggingEnabled(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let enabled = call.arguments as? Bool ?? false
        if enabled {
            Settings.shared.enableLoggingBehavior(.appEvents)
            Settings.shared.enableLoggingBehavior(.networkRequests)
        } else {
            Settings.shared.disableLoggingBehavior(.appEvents)
            Settings.shared.disableLoggingBehavior(.networkRequests)
        }
        result(nil)
    }
}
