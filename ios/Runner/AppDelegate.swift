import Flutter
import UIKit
import GoogleMaps
import AVFoundation
import PaymobSDK
import StoreKit

// MARK: - Secure Image Platform View (prevents screenshots)
class SecureImageView: NSObject, FlutterPlatformView {
    private let secureContainer: UIView
    private let imageView: UIImageView

    init(frame: CGRect, args: Any?) {
        let textField = UITextField()
        textField.isSecureTextEntry = true
        textField.frame = frame

        // ✅ الـ secure container هو الـ subview الأول للـ UITextField
        let container = textField.subviews.first ?? UIView(frame: frame)
        container.frame = frame
        container.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        container.isUserInteractionEnabled = false
        secureContainer = container

        // ✅ ImageView جوه الـ secure container مباشرة
        imageView = UIImageView(frame: container.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        container.addSubview(imageView)

        super.init()

        // ✅ حمّل الصورة من الـ args
        if let argsDict = args as? [String: Any],
           let urlString = argsDict["url"] as? String,
           let url = URL(string: urlString) {
            loadImage(from: url)
        }
    }

    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self?.imageView.image = image
            }
        }.resume()
    }

    func view() -> UIView { secureContainer }
}

class SecureImageFactory: NSObject, FlutterPlatformViewFactory {
    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return SecureImageView(frame: frame, args: args)
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

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

        // ✅ تسجيل الـ SecureImageView للحماية من الـ screenshot
        let registrar = self.registrar(forPlugin: "SecureImagePlugin")
        registrar?.register(
            SecureImageFactory(),
            withId: "secure_image_view"
        )

        // ✅ Force Universal Links to stay in app
        if #available(iOS 14.0, *) {
            // Prevent iOS from opening Universal Links in Safari
            // This ensures deep links always open in the app
        }

        // ✅ Add additional safeguards for Universal Links
        if #available(iOS 13.0, *) {
            // Configure app to handle Universal Links more aggressively
        }

        if let controller = window?.rootViewController as? FlutterViewController {

            // ── IAP JWS Channel ──────────────────────────────────────────────
            // يجيب الـ JWS (jwsRepresentation) من Transaction.currentEntitlements
            // الـ Flutter package مش بيبعت الـ JWS — بنجيبه مباشرة من native
            let iapJwsChannel = FlutterMethodChannel(
                name: "com.athr.tayser/iap_jws",
                binaryMessenger: controller.binaryMessenger
            )
            iapJwsChannel.setMethodCallHandler { (call, result) in
                if call.method == "getCurrentEntitlementsJWS" {
                    if #available(iOS 15.0, *) {
                        Task {
                            var jwsList: [[String: String]] = []
                            for await verificationResult in Transaction.currentEntitlements {
                                switch verificationResult {
                                case .verified(let transaction):
                                    jwsList.append([
                                        "transactionId": "\(transaction.id)",
                                        "productId": transaction.productID,
                                        "jws": verificationResult.jwsRepresentation
                                    ])
                                case .unverified(let transaction, _):
                                    // نضيف الـ JWS حتى لو unverified — الباك-إند هيتحقق
                                    jwsList.append([
                                        "transactionId": "\(transaction.id)",
                                        "productId": transaction.productID,
                                        "jws": verificationResult.jwsRepresentation
                                    ])
                                }
                            }
                            DispatchQueue.main.async {
                                result(jwsList)
                            }
                        }
                    } else {
                        result(FlutterError(
                            code: "UNSUPPORTED",
                            message: "StoreKit 2 requires iOS 15+",
                            details: nil
                        ))
                    }
                } else {
                    result(FlutterMethodNotImplemented)
                }
            }
            // ────────────────────────────────────────────────────────────────

            // ── IAP Management Channel ───────────────────────────────────────
            // manageSubscriptionsSheet و beginRefundRequest — native Apple sheets
            let iapManageChannel = FlutterMethodChannel(
                name: "com.athr.tayser/iap_manage",
                binaryMessenger: controller.binaryMessenger
            )
            iapManageChannel.setMethodCallHandler { [weak controller] (call, result) in
                if #available(iOS 15.0, *) {
                    if call.method == "showManageSubscriptions" {
                        // يفتح Apple's native Manage Subscriptions sheet داخل التطبيق
                        Task { @MainActor in
                            guard let scene = UIApplication.shared.connectedScenes
                                .compactMap({ $0 as? UIWindowScene })
                                .first else {
                                result(FlutterError(code: "NO_SCENE", message: "No UIWindowScene found", details: nil))
                                return
                            }
                            do {
                                try await AppStore.showManageSubscriptions(in: scene)
                                result(true)
                            } catch {
                                result(FlutterError(code: "MANAGE_ERROR", message: error.localizedDescription, details: nil))
                            }
                        }
                    } else if call.method == "beginRefundRequest" {
                        // يفتح Apple's native Refund Request sheet داخل التطبيق
                        guard let args = call.arguments as? [String: Any],
                              let transactionIdStr = args["transactionId"] as? String,
                              let transactionId = UInt64(transactionIdStr) else {
                            result(FlutterError(code: "INVALID_ARGS", message: "transactionId required", details: nil))
                            return
                        }
                        Task { @MainActor in
                            guard let scene = UIApplication.shared.connectedScenes
                                .compactMap({ $0 as? UIWindowScene })
                                .first else {
                                result(FlutterError(code: "NO_SCENE", message: "No UIWindowScene found", details: nil))
                                return
                            }
                            do {
                                let status = try await Transaction.beginRefundRequest(for: transactionId, in: scene)
                                switch status {
                                case .success:
                                    result("success")
                                case .userCancelled:
                                    result("cancelled")
                                @unknown default:
                                    result("unknown")
                                }
                            } catch {
                                result(FlutterError(code: "REFUND_ERROR", message: error.localizedDescription, details: nil))
                            }
                        }
                    } else if call.method == "getLatestTransactionId" {
                        // يجيب أحدث transactionId للـ subscription الحالية
                        guard let args = call.arguments as? [String: Any],
                              let productId = args["productId"] as? String else {
                            result(FlutterError(code: "INVALID_ARGS", message: "productId required", details: nil))
                            return
                        }
                        Task {
                            var latestId: String? = nil
                            for await verificationResult in Transaction.currentEntitlements {
                                if case .verified(let transaction) = verificationResult,
                                   transaction.productID == productId {
                                    latestId = "\(transaction.id)"
                                    break
                                }
                            }
                            DispatchQueue.main.async {
                                result(latestId)
                            }
                        }
                    } else {
                        result(FlutterMethodNotImplemented)
                    }
                } else {
                    // iOS 14 fallback — فتح Settings
                    result(FlutterError(code: "UNSUPPORTED", message: "iOS 15+ required", details: nil))
                }
            }
            // ────────────────────────────────────────────────────────────────

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

    // ✅ Override Universal Link handling to prevent Safari redirect
    override func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        // Check if this is a Universal Link
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
           let url = userActivity.webpageURL {
            
            print("🔗 [iOS] Universal Link received: \(url)")
            
            // Check if this is our domain
            if url.host == "tayser-app.net" {
                print("🔗 [iOS] Force handling Universal Link in app (bypass Safari)")
                
                // ✅ Force the app to handle the link instead of Safari
                // Convert the URL to our custom scheme to ensure app handling
                if let components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                    // Create a custom scheme URL that Flutter can handle
                    var customComponents = components
                    customComponents.scheme = "tayseer"
                    
                    // Map the path to our custom format
                    let path = components.path
                    if path.hasPrefix("/marriage/profile/") {
                        let profileId = String(path.dropFirst("/marriage/profile/".count))
                        customComponents.host = "marriage"
                        customComponents.path = ""
                        customComponents.queryItems = [URLQueryItem(name: "profileId", value: profileId)]
                    } else if path.hasPrefix("/advisor/profile/") {
                        let advisorId = String(path.dropFirst("/advisor/profile/".count))
                        customComponents.host = "advisor"
                        customComponents.path = ""
                        customComponents.queryItems = [URLQueryItem(name: "profileId", value: advisorId)]
                    } else if path.hasPrefix("/user/profile/") {
                        let userId = String(path.dropFirst("/user/profile/".count))
                        customComponents.host = "user"
                        customComponents.path = ""
                        customComponents.queryItems = [URLQueryItem(name: "profileId", value: userId)]
                    } else if path.hasPrefix("/posts/") {
                        let postId = String(path.dropFirst("/posts/".count))
                        customComponents.host = "post"
                        customComponents.path = ""
                        customComponents.queryItems = [URLQueryItem(name: "postId", value: postId)]
                    }
                    
                    if let customUrl = customComponents.url {
                        print("🔗 [iOS] Converted to custom scheme: \(customUrl)")
                        // Handle the custom URL through Flutter
                        return super.application(application, open: customUrl, options: [:])
                    }
                }
                
                // Fallback: let Flutter handle the original URL
                return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
            }
        }
        
        return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
    }

    // ✅ Handle custom URL schemes (fallback)
    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("🔗 [iOS] Custom URL scheme received: \(url)")
        
        // ✅ Prevent any web redirects by handling all our URLs
        if url.scheme == "tayseer" || (url.scheme == "https" && url.host == "tayser-app.net") {
            print("🔗 [iOS] Forcing app handling for: \(url)")
            return super.application(app, open: url, options: options)
        }
        
        return super.application(app, open: url, options: options)
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