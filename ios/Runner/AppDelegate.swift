import Flutter
import UIKit
<<<<<<< HEAD

@main
=======
import GoogleMaps


@UIApplicationMain
>>>>>>> 6abd21ff920c9967230cbd1a72bdd7fb0c130af5
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
<<<<<<< HEAD
  >> GMSServices.provideAPIKey("AIzaSyBnlUwGFhk0UZ_sbSLeClMJhgoS9ngu6mk")
=======
   >> GMSServices.provideAPIKey("AIzaSyDHp5MFsl9WSbDJXz9NA7JWmudtft4w-Vk")
>>>>>>> 6abd21ff920c9967230cbd1a72bdd7fb0c130af5
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
