import Flutter
import UIKit
import XCTest

class RunnerTests: XCTestCase {

  func testExample() {
    // If you add code to the Runner application, consider adding tests here.
    // See https://developer.apple.com/documentation/xctest for more information about using XCTest.
  }

}

// @UIApplicationMain
// @objc class AppDelegate: FlutterAppDelegate {
//     override func application(
//         _ application: UIApplication,
//         didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//     ) -> Bool {
//         GeneratedPluginRegistrant.register(with: self)
//         BackgroundTaskRunner().startBackgroundTask()
//         return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//     }
// }
//
// @objc class BackgroundTaskRunner: NSObject {
//     @objc func startBackgroundTask() {
//         let backgroundTask = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
//         DispatchQueue.global(qos: .background).async {
//             // Your background task code here
//             let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
//             let backgroundChannel = FlutterMethodChannel(name: "background_task", binaryMessenger: controller.binaryMessenger)
//             backgroundChannel.setMethodCallHandler({ [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
//                 // Handle method call
//             })
//             UIApplication.shared.endBackgroundTask(backgroundTask)
//         }
//     }
// }