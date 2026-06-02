import UserNotifications
import UIKit

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

        // matchBlur == true → deliver without image (privacy mode)
        let rawBlur = userInfo["matchBlur"] as? String ?? ""
        if rawBlur.lowercased() == "true" {
            contentHandler(bestAttemptContent)
            return
        }

        // FCM puts all `data` fields directly in userInfo on iOS
        let imageUrlString = userInfo["matchImage"] as? String
            ?? (userInfo["fcm_options"] as? [String: Any])?["image"] as? String

        guard let urlString = imageUrlString,
              let imageUrl = URL(string: urlString) else {
            contentHandler(bestAttemptContent)
            return
        }

        downloadAndAttach(from: imageUrl) { attachment in
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

    private func downloadAndAttach(
        from url: URL,
        completion: @escaping (UNNotificationAttachment?) -> Void
    ) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil,
                  let uiImage = UIImage(data: data) else {
                completion(nil)
                return
            }
            completion(Self.saveAsAttachment(image: uiImage))
        }.resume()
    }

    /// Encodes UIImage as JPEG and saves to a temp file.
    /// JPEG is used because UNNotificationAttachment does NOT support .webp.
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
