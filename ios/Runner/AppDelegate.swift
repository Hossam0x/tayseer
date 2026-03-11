import Flutter
import UIKit
import GoogleMaps
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    GMSServices.provideAPIKey("AIzaSyBwj3AABMp5Sw9qpkfR1ByoBdrF1djZzFQ")
    
    // ✅ لازم يكون أول حاجة
    GeneratedPluginRegistrant.register(with: self)

    // ✅ Audio Session Channel
    if let controller = window?.rootViewController as? FlutterViewController {
      let audioSessionChannel = FlutterMethodChannel(
        name: "com.athr.tayser/audio_session",
        binaryMessenger: controller.binaryMessenger
      )
      audioSessionChannel.setMethodCallHandler { (call, result) in
        if call.method == "configureForRecording" {
          do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try session.setActive(true)
            result(true)
          } catch {
            result(FlutterError(code: "AUDIO_SESSION_ERROR", message: error.localizedDescription, details: nil))
          }
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}