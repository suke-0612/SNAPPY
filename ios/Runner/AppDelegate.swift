import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("${googleService_API_KEY}")
    GeneratedPluginRegistrant.register(with: self)
    GMSServices.setMetalRendererEnabled(false)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
