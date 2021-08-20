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
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "clearUserData":
            handleClearUserData(call, result: result)
            break
        case "clearUserID":
            handleClearUserID(call, result: result)
            break
        case "flush":
            handleFlush(call, result: result)
            break
        case "getApplicationId":
            handleGetApplicationId(call, result: result)
            break
        case "logEvent":
            handleLogEvent(call, result: result)
            break
        case "logPushNotificationOpen":
            handlePushNotificationOpen(call, result: result)
            break
        case "setUserData":
            handleSetUserData(call, result: result)
            break
        case "setUserID":
            handleSetUserId(call, result: result)
            break
        case "updateUserProperties":
            handleUpdateUserProperties(call, result: result)
            break
        case "setAutoLogAppEventsEnabled":
            handleSetAutoLogAppEventsEnabled(call, result: result)
            break
        case "setDataProcessingOptions":
            handleSetDataProcessingOptions(call, result: result)
            break
        case "logPurchase":
            handlePurchased(call, result: result)
            break
        case "getAnonymousId":
            handleHandleGetAnonymousId(call, result: result)
            break
        case "setAdvertiserTracking":
            handleSetAdvertiserTracking(call, result: result)
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func handleClearUserData(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        AppEvents.clearUserData()
        result(nil)
    }

    private func handleClearUserID(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        AppEvents.clearUserID()
        result(nil)
    }

    private func handleFlush(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        AppEvents.flush()
        result(nil)
    }

    private func handleGetApplicationId(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(Settings.appID)
    }

    private func handleHandleGetAnonymousId(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(AppEvents.anonymousID)
    }

    private func handleLogEvent(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? [String: Any] ?? [String: Any]()
        let eventName = arguments["name"] as! String
        let parameters = arguments["parameters"] as? [String: Any] ?? [String: Any]()
        if arguments["_valueToSum"] != nil && !(arguments["_valueToSum"] is NSNull) {
            let valueToDouble = arguments["_valueToSum"] as! Double
            AppEvents.logEvent(AppEvents.Name(eventName), valueToSum: valueToDouble, parameters: parameters)
        } else {
            AppEvents.logEvent(AppEvents.Name(eventName), parameters: parameters)
        }

        result(nil)
    }

    private func handlePushNotificationOpen(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? [String: Any] ?? [String: Any]()
        let payload = arguments["payload"] as? [String: Any]
        if let action = arguments["action"] {
            let actionString = action as! String
            AppEvents.logPushNotificationOpen(payload!, action: actionString)
        } else {
            AppEvents.logPushNotificationOpen(payload!)
        }

        result(nil)
    }

    private func handleSetUserData(_ call: FlutterMethodCall, result: @escaping FlutterResult) {        
        let arguments = call.arguments as? [String: Any] ?? [String: Any]()

        AppEvents.setUserData(arguments["email"] as? String, forType: FBSDKAppEventUserDataType.email)
        AppEvents.setUserData(arguments["firstName"] as? String, forType: FBSDKAppEventUserDataType.firstName)
        AppEvents.setUserData(arguments["lastName"] as? String, forType: FBSDKAppEventUserDataType.lastName)
        AppEvents.setUserData(arguments["phone"] as? String, forType: FBSDKAppEventUserDataType.phone)
        AppEvents.setUserData(arguments["dateOfBirth"] as? String, forType: FBSDKAppEventUserDataType.dateOfBirth)
        AppEvents.setUserData(arguments["gender"] as? String, forType: FBSDKAppEventUserDataType.gender)
        AppEvents.setUserData(arguments["city"] as? String, forType: FBSDKAppEventUserDataType.city)
        AppEvents.setUserData(arguments["state"] as? String, forType: FBSDKAppEventUserDataType.state)
        AppEvents.setUserData(arguments["zip"] as? String, forType: FBSDKAppEventUserDataType.zip)
        AppEvents.setUserData(arguments["country"] as? String, forType: FBSDKAppEventUserDataType.country)

        result(nil)
    }

    private func handleSetUserId(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let id = call.arguments as! String
        AppEvents.userID = id
        result(nil)
    }

    private func handleUpdateUserProperties(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Seems to have been removed in iOS SDK but only deprecated in the Android SDK
        //  - iOS removal note: https://github.com/facebook/facebook-ios-sdk/blob/0e1d8774db783d85bd8fc3b53ec96444c048ae42/CHANGELOG.md#removed
        //  - Android deprecation: https://github.com/facebook/facebook-android-sdk/blob/9da80baea0d23a82ce797e17bd4bc0e0d75b3912/facebook-core/src/main/java/com/facebook/appevents/AppEventsLogger.kt#L633 
        // Leave this one here for until fully removed in SDK v12
        result(nil)
    }

    private func handleSetAutoLogAppEventsEnabled(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let enabled = call.arguments as! Bool
        Settings.isAutoLogAppEventsEnabled = enabled
        result(nil)
    }

    private func handleSetDataProcessingOptions(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? [String: Any] ?? [String: Any]()
        let modes = arguments["options"] as? [String] ?? []
        let state = arguments["state"] as? Int32 ?? 0
        let country = arguments["country"] as? Int32 ?? 0

        Settings.setDataProcessingOptions(modes, country: country, state: state)

        result(nil)
    }

    private func handlePurchased(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? [String: Any] ?? [String: Any]()
        let amount = arguments["amount"] as! Double
        let currency = arguments["currency"] as! String
        let parameters = arguments["parameters"] as? [String: Any] ?? [String: Any]()
        AppEvents.logPurchase(amount, currency: currency, parameters: parameters)

        result(nil)
    }

    private func handleSetAdvertiserTracking(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? [String: Any] ?? [String: Any]()
        let enabled = arguments["enabled"] as! Bool
        Settings.setAdvertiserTrackingEnabled(enabled)        
        result(nil)
    }
}
