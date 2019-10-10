import Flutter
import UIKit
import FBSDKCoreKit

public class SwiftFacebookAppEventsPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter.oddbit.id/facebook_app_events", binaryMessenger: registrar.messenger())
    let instance = SwiftFacebookAppEventsPlugin()
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
    case "getPlatformVersion":
      handleGetPlatformVersion(call, result: result)
      break
    case "logEvent":
      handleLogEvent(call, result: result)
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

  private func handleLogEvent(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let arguments = call.arguments as? [String: Any] ?? [String: Any]()
    let eventName = arguments["name"] as! String
    let parameters = arguments["parameters"] as! [String: Any]
    if let valueToSum = arguments["valueToSum"] {
        let valueToDouble = valueToSum as! Double
        AppEvents.logEvent(AppEvents.Name(eventName), valueToSum: valueToDouble, parameters: parameters)
        result(nil)
    } else {
         AppEvents.logEvent(AppEvents.Name(eventName), parameters: parameters)
         result(nil)
    }
  }

  private func handleSetUserData(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let arguments = call.arguments as? [String: Any] ?? [String: Any]()
    AppEvents.setUserData(arguments["email"] as? String, FBSDKAppEventUserDataType.email)
    AppEvents.setUserData(arguments["firstName"] as? String, FBSDKAppEventUserDataType.firstName)
    AppEvents.setUserData(arguments["lastName"] as? String, FBSDKAppEventUserDataType.lastName)
    AppEvents.setUserData(arguments["phone"] as? String, FBSDKAppEventUserDataType.phone)
    AppEvents.setUserData(arguments["dateOfBirth"] as? String, FBSDKAppEventUserDataType.dateOfBirth)
    AppEvents.setUserData(arguments["gender"] as? String, FBSDKAppEventUserDataType.gender)
    AppEvents.setUserData(arguments["city"] as? String, FBSDKAppEventUserDataType.city)
    AppEvents.setUserData(arguments["state"] as? String, FBSDKAppEventUserDataType.state)
    AppEvents.setUserData(arguments["zip"] as? String, FBSDKAppEventUserDataType.zip)
    AppEvents.setUserData(arguments["country"] as? String, FBSDKAppEventUserDataType.country)

    result(nil)
  }

  private func handleGetPlatformVersion(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }

  private func handleSetUserId(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      let id = call.arguments as! String
      AppEvents.userID = id
      result(nil)
  }

  private func handleUpdateUserProperties(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      let arguments = call.arguments as? [String: Any] ?? [String: Any]()
      let applicationId = arguments["applicationId"] as? String
      let parameters =  arguments["parameters"] as! [String: Any]
      let graphRequest = GraphRequest(graphPath: "path", parameters: parameters)
      
      let callback: GraphRequestBlock =  { (connection, result, error) in
         if error != nil {
           result(nil)
         } else {
            result(result)
         }
      }

      if let id = applicationId {
        AppEvents.updateUserProperties( parameters, applicationId, handler: callback)
      } else {
        AppEvents.updateUserProperties( parameters, handler: callback)
      }
  }
}