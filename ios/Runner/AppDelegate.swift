import Flutter
import UIKit
import GoogleMaps
import AVFoundation
import PaymobSDK

@main
@objc class AppDelegate: FlutterAppDelegate {

    var sdkResult: FlutterResult?
    var paymob: PaymobSDK?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        GMSServices.provideAPIKey("AIzaSyBwj3AABMp5Sw9qpkfR1ByoBdrF1djZzFQ")

        GeneratedPluginRegistrant.register(with: self)

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

            let paymobChannel = FlutterMethodChannel(
                name: "paymob_sdk_flutter",
                binaryMessenger: controller.binaryMessenger
            )
            paymobChannel.setMethodCallHandler { [weak self] (call, result) in
                if call.method == "payWithPaymob",
                   let args = call.arguments as? [String: Any] {
                    self?.sdkResult = result
                    self?.callNativeSDK(arguments: args, VC: controller)
                } else {
                    result(FlutterMethodNotImplemented)
                }
            }
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func callNativeSDK(arguments: [String: Any], VC: FlutterViewController) {
        let paymob = PaymobSDK()
        paymob.delegate = self
        self.paymob = paymob

        if let appName = arguments["appName"] as? String {
            paymob.paymobSDKCustomization.appName = appName
        }
        if let buttonBackgroundColor = arguments["buttonBackgroundColor"] as? NSNumber {
            let colorInt = buttonBackgroundColor.intValue
            let alpha = CGFloat((colorInt >> 24) & 0xFF) / 255.0
            let red = CGFloat((colorInt >> 16) & 0xFF) / 255.0
            let green = CGFloat((colorInt >> 8) & 0xFF) / 255.0
            let blue = CGFloat(colorInt & 0xFF) / 255.0
            paymob.paymobSDKCustomization.buttonBackgroundColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        }
        if let buttonTextColor = arguments["buttonTextColor"] as? NSNumber {
            let colorInt = buttonTextColor.intValue
            let alpha = CGFloat((colorInt >> 24) & 0xFF) / 255.0
            let red = CGFloat((colorInt >> 16) & 0xFF) / 255.0
            let green = CGFloat((colorInt >> 8) & 0xFF) / 255.0
            let blue = CGFloat(colorInt & 0xFF) / 255.0
            paymob.paymobSDKCustomization.buttonTextColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        }
        if let saveCardDefault = arguments["saveCardDefault"] as? Bool {
            paymob.paymobSDKCustomization.saveCardDefault = saveCardDefault
        }
        if let showSaveCard = arguments["showSaveCard"] as? Bool {
            paymob.paymobSDKCustomization.showSaveCard = showSaveCard
        }

        if let publicKey = arguments["publicKey"] as? String,
           let clientSecret = arguments["clientSecret"] as? String {
            do {
                try paymob.presentPayVC(VC: VC, PublicKey: publicKey, ClientSecret: clientSecret)
            } catch let error {
                print("🔴 [Paymob] ERROR: \(error.localizedDescription)")
                sdkResult?(FlutterError(code: "SDK_ERROR", message: error.localizedDescription, details: nil))
                sdkResult = nil
            }
            return
        }
    }
}

extension AppDelegate: PaymobSDKDelegate {
    func transactionAccepted(transactionDetails: [String: Any]) {
        print("🟢 [Paymob] ACCEPTED!")
        sdkResult?(["status": "Successfull", "details": transactionDetails])
        sdkResult = nil
        paymob = nil
    }
    func transactionRejected() {
        print("🔴 [Paymob] REJECTED!")
        sdkResult?("Rejected")
        sdkResult = nil
        paymob = nil
    }
    func transactionPending() {
        print("🟡 [Paymob] PENDING!")
        sdkResult?("Pending")
        sdkResult = nil
        paymob = nil
    }
}