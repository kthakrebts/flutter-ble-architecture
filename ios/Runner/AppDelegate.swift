import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  var bleManager: BLEManager?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    bleManager = BLEManager(messenger: controller.binaryMessenger)
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
