import Flutter
import UIKit
import FBSDKCoreKit
import FBSDKCoreKit_Basics
import FBAEMKit

public class FacebookAppEventsPlugin: NSObject, FlutterPlugin, FlutterSceneLifeCycleDelegate {
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

        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addApplicationDelegate(instance)
        registrar.addSceneDelegate(instance)
    }

    /// Connect app delegate with SDK for URL schemes
    public func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        // Handle AEM (Aggregated Event Measurement) for iOS 14.5+ attribution
        // This is required for re-engagement ad campaigns to work properly
        if let appId = Bundle.main.object(forInfoDictionaryKey: "FacebookAppID") as? String {
            AEMReporter.configure(networker: nil, appID: appId, reporter: nil)
            AEMReporter.enable()
            AEMReporter.handle(url)
        }

        // For Facebook SDK 18.x+, use the simplified URL handling
        return ApplicationDelegate.shared.application(app, open: url, options: options)
    }

    /// Handle Universal Links for AEM attribution
    public func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        // Handle AEM for Universal Links
        // Note: Facebook SDK handles Universal Links internally via swizzling,
        // but we explicitly handle AEM here to ensure attribution works
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
           let url = userActivity.webpageURL,
           let appId = Bundle.main.object(forInfoDictionaryKey: "FacebookAppID") as? String {
            AEMReporter.configure(networker: nil, appID: appId, reporter: nil)
            AEMReporter.enable()
            AEMReporter.handle(url)
        }

        // Return false to allow other handlers to process the activity
        return false
    }

    // MARK: - UISceneDelegate (Flutter 3.38+ / UIScene lifecycle)

    /// Scene-based URL handler for deep links (replaces application:open:options: on UIScene apps)
    public func scene(
        _ scene: UIScene,
        openURLContexts URLContexts: Set<UIOpenURLContext>
    ) -> Bool {
        for context in URLContexts {
            let url = context.url
            if let appId = Bundle.main.object(forInfoDictionaryKey: "FacebookAppID") as? String {
                AEMReporter.configure(networker: nil, appID: appId, reporter: nil)
                AEMReporter.enable()
                AEMReporter.handle(url)
            }
            ApplicationDelegate.shared.application(
                UIApplication.shared,
                open: url,
                sourceApplication: context.options.sourceApplication,
                annotation: context.options.annotation
            )
        }
        return true
    }

    /// Scene-based Universal Links handler (replaces application:continue:restorationHandler: on UIScene apps)
    public func scene(
        _ scene: UIScene,
        continue userActivity: NSUserActivity
    ) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
           let url = userActivity.webpageURL,
           let appId = Bundle.main.object(forInfoDictionaryKey: "FacebookAppID") as? String {
            AEMReporter.configure(networker: nil, appID: appId, reporter: nil)
            AEMReporter.enable()
            AEMReporter.handle(url)
        }
        return false
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
            handleHandleGetAnonymousId(call, result: result)
        case "setAdvertiserTracking":
            handleSetAdvertiserTracking(call, result: result)
        case "fetchDeferredAppLink":
            handleFetchDeferredAppLink(call, result: result)
        case "setDebugEnabled":
            handleSetDebugEnabled(call, result: result)
        case "recordAndUpdateAEMEvent":
            handleRecordAndUpdateAEMEvent(call, result: result)
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

    private func handleHandleGetAnonymousId(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
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

        let valueToSum = arguments["_valueToSum"] as? Double

        if let valueToSum = valueToSum {
            AppEvents.shared.logEvent(AppEvents.Name(eventName), valueToSum: valueToSum, parameters: parameters)
        } else {
            AppEvents.shared.logEvent(AppEvents.Name(eventName), parameters: parameters)
        }

        // Automatically record AEM event for iOS 14.5+ attribution
        let currency = rawParams["fb_currency"] as? String
        AEMReporter.recordAndUpdate(event: eventName,
                                          currency: currency,
                                          value: valueToSum as NSNumber?,
                                          parameters: rawParams)

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

        // Automatically record AEM event for iOS 14.5+ attribution
        AEMReporter.recordAndUpdate(event: "fb_mobile_purchase",
                                          currency: currency,
                                          value: NSNumber(value: amount),
                                          parameters: rawParams)

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

    private func handleSetDebugEnabled(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
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

    private func handleRecordAndUpdateAEMEvent(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? [String: Any] ?? [:]
        let eventName = arguments["eventName"] as? String ?? ""
        let value = arguments["value"] as? NSNumber ?? 0
        let currency = arguments["currency"] as? String
        let parameters = arguments["parameters"] as? [String: Any]

        AEMReporter.recordAndUpdate(event: eventName,
                                          currency: currency,
                                          value: value,
                                          parameters: parameters)
        result(nil)
    }

    private func handleFetchDeferredAppLink(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        AppLinkUtility.fetchDeferredAppLink { url, error in
            if let error = error {
                print("[FacebookAppEvents] fetchDeferredAppLink error: \(error.localizedDescription)")
                result(nil)
                return
            }

            guard let url = url else {
                result(nil)
                return
            }

            var data: [String: Any] = [
                "targetUrl": url.absoluteString
            ]

            // Parse URL query parameters for campaign data
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let queryItems = components.queryItems {
                var queryParams: [String: String] = [:]
                for item in queryItems {
                    if let value = item.value {
                        queryParams[item.name] = value

                        // Extract known Facebook parameters
                        if item.name == "fb_click_time_utc" {
                            data["clickTimestamp"] = value
                        }
                        if item.name == "fb_ref" {
                            data["ref"] = value
                        }
                    }
                }
                if !queryParams.isEmpty {
                    data["queryParameters"] = queryParams
                }
            }

            // Try to extract data from deeplink_context if present
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let deeplinkContext = components.queryItems?.first(where: { $0.name == "deeplink_context" })?.value,
               let contextData = deeplinkContext.data(using: .utf8),
               let contextJson = try? JSONSerialization.jsonObject(with: contextData) as? [String: Any] {
                if let promoCode = contextJson["promo_code"] as? String {
                    data["promotionCode"] = promoCode
                }
                // Also check for ref in deeplink_context if not already set from query params
                if data["ref"] == nil, let ref = contextJson["fb_ref"] as? String {
                    data["ref"] = ref
                }
            }

            result(data)
        }
    }
}
