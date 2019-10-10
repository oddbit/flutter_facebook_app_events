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
    let userParams = ["email", "firstName", "lastName", "phone", "dateOfBirth"]

    for key in userParams {
      let value = arguments[key] as? String
      AppEvents.setUserData(value, forType: AppEvents.UserDataType(key))
    }

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
      let requestCallback =  graphRequest.start { (urlResponse, requestResult, error) in
         if error != nil {
           result(nil)
         } else {
            let dict = requestResult as! NSMutableDictionary
            result(dict)
         }
      }

      if let id = applicationId {
        //error in graphrequest, error message :  error: cannot convert value of type 'GraphRequest' to expected argument type 'GraphRequestBlock?'
        AppEvents.updateUserProperties( parameters, applicationId, handler: graphRequest)
      } else {
        AppEvents.updateUserProperties( parameters, handler: graphRequest)
      }
  }
}