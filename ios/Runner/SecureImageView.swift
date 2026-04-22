import Flutter
import UIKit

// ✅ UITextField مع isSecureTextEntry = true بيمنع الـ screenshot على iOS
// نفس الطريقة اللي بتستخدمها تطبيقات البنوك وواتساب
class SecureImageView: NSObject, FlutterPlatformView {
    private let secureContainer: UIView

    init(frame: CGRect) {
        let textField = UITextField()
        textField.isSecureTextEntry = true
        textField.frame = frame

        // الـ subview الأول هو الـ secure container اللي بيمنع الـ screenshot
        secureContainer = textField.subviews.first ?? UIView(frame: frame)
        secureContainer.frame = frame
        secureContainer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        secureContainer.isUserInteractionEnabled = false
        super.init()
    }

    func view() -> UIView { secureContainer }
}

class SecureImageFactory: NSObject, FlutterPlatformViewFactory {
    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return SecureImageView(frame: frame)
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}
