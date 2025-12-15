import Flutter
import UIKit
import FBSDKCoreKit
import FBSDKCoreKit_Basics

public class SwiftFacebookAppEventsPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter.oddbit.id/facebook_app_events", binaryMessenger: registrar.messenger())
        let instance = SwiftFacebookAppEventsPlugin()

        // Required for FB SDK 9.0, as it does not initialize the SDK automatically any more.
        // See: https://developers.facebook.com/blog/post/2021/01/19/introducing-facebook-platform-sdk-version-9/
        // "Removal of Auto Initialization of SDK" section
        ApplicationDelegate.shared.initializeSDK()

        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addApplicationDelegate(instance)
    }
    
    /// Connect app delegate with SDK
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable : Any] = [:]) -> Bool {
        var options = [UIApplication.LaunchOptionsKey: Any]()
        for (k, value) in launchOptions {
            let key = k as! UIApplication.LaunchOptionsKey
            options[key] = value
        }
        ApplicationDelegate.shared.application(application,didFinishLaunchingWithOptions: options)
        return true
    }
    
    public func application( _ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:] ) -> Bool {
        let processed = ApplicationDelegate.shared.application(
            app, open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation])
        return processed;
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
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
            handleHandleGetAnonymousId(call, result: result)
        case "setAdvertiserTracking":
            handleSetAdvertiserTracking(call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
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
        result(Settings.shared.appID)
    }

    private func handleHandleGetAnonymousId(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(AppEvents.shared.anonymousID)
    }

    private func handleLogEvent(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? [String: Any] ?? [:]
        guard let eventName = arguments["name"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Event name is required", details: nil))
            return
        }
        let parameters = arguments["parameters"] as? [AppEvents.ParameterName: Any] ?? [:]
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
        let arguments = call.arguments as? [String: Any] ?? [:]
        let options = arguments["options"] as? [String] ?? []
        let country = arguments["country"] as? Int32 ?? 0
        let state = arguments["state"] as? Int32 ?? 0

        Settings.shared.setDataProcessingOptions(options, country: country, state: state)

        result(nil)
    }

    private func handlePurchased(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? [String: Any] ?? [:]
        guard let amount = arguments["amount"] as? Double,
              let currency = arguments["currency"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Amount and currency are required", details: nil))
            return
        }
        let parameters = arguments["parameters"] as? [AppEvents.ParameterName: Any] ?? [:]
        AppEvents.shared.logPurchase(amount: amount, currency: currency, parameters: parameters)

        result(nil)
    }

    private func handleSetAdvertiserTracking(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? [String: Any] ?? [:]
        let enabled = arguments["enabled"] as? Bool ?? false
        let collectId = arguments["collectId"] as? Bool ?? true

        Settings.shared.isAdvertiserTrackingEnabled = enabled
        Settings.shared.isAdvertiserIDCollectionEnabled = collectId

        result(nil)
    }
}
