import UserNotifications
import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(
        _ request: UNNotificationRequest,
        withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
    ) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        guard let bestAttemptContent = bestAttemptContent else {
            contentHandler(request.content)
            return
        }

        let userInfo = request.content.userInfo

        // FCM puts all `data` fields directly in userInfo on iOS
        let imageUrlString = userInfo["matchImage"] as? String
            ?? (userInfo["fcm_options"] as? [String: Any])?["image"] as? String

        let rawBlur = userInfo["matchBlur"] as? String ?? ""
        let shouldBlur = rawBlur.lowercased() == "true"

        guard let urlString = imageUrlString,
              let imageUrl = URL(string: urlString) else {
            contentHandler(bestAttemptContent)
            return
        }

        downloadAndProcess(from: imageUrl, blur: shouldBlur) { attachment in
            if let attachment = attachment {
                bestAttemptContent.attachments = [attachment]
            }
            contentHandler(bestAttemptContent)
        }
    }

    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler,
           let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

    // MARK: - Private

    private func downloadAndProcess(
        from url: URL,
        blur: Bool,
        completion: @escaping (UNNotificationAttachment?) -> Void
    ) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }

            // UIImage can decode webp, jpg, png, heic — normalises everything
            guard let uiImage = UIImage(data: data) else {
                completion(nil)
                return
            }

            let finalImage: UIImage

            if blur {
                // Apply Gaussian blur via CoreImage
                guard let ciImage = CIImage(image: uiImage) else {
                    finalImage = uiImage
                    completion(Self.saveAsAttachment(image: finalImage))
                    return
                }

                let filter = CIFilter.gaussianBlur()
                filter.inputImage = ciImage
                filter.radius = 20

                let context = CIContext()
                if let outputImage = filter.outputImage,
                   let cgImage = context.createCGImage(outputImage, from: ciImage.extent) {
                    finalImage = UIImage(cgImage: cgImage)
                } else {
                    finalImage = uiImage
                }
            } else {
                finalImage = uiImage
            }

            completion(Self.saveAsAttachment(image: finalImage))
        }.resume()
    }

    /// Encodes UIImage as JPEG and saves to a temp file for use as a notification attachment.
    /// JPEG is used because UNNotificationAttachment supports jpg/png/gif but NOT webp.
    private static func saveAsAttachment(image: UIImage) -> UNNotificationAttachment? {
        guard let jpegData = image.jpegData(compressionQuality: 0.85) else { return nil }

        let tempUrl = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("jpg")

        do {
            try jpegData.write(to: tempUrl)
            return try UNNotificationAttachment(
                identifier: "matchImage",
                url: tempUrl,
                options: nil
            )
        } catch {
            return nil
        }
    }
}
