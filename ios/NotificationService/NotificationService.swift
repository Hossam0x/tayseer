import UserNotifications

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

        // Look for matchImage in the FCM data payload
        let userInfo = request.content.userInfo
        let imageUrlString = userInfo["matchImage"] as? String
            ?? (userInfo["fcm_options"] as? [String: Any])?["image"] as? String

        guard let urlString = imageUrlString,
              let imageUrl = URL(string: urlString) else {
            // No image — deliver as-is
            contentHandler(bestAttemptContent)
            return
        }

        // Download the image and attach it
        downloadImage(from: imageUrl) { attachment in
            if let attachment = attachment {
                bestAttemptContent.attachments = [attachment]
            }
            contentHandler(bestAttemptContent)
        }
    }

    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension is terminated by the system.
        // Deliver whatever content we have so far.
        if let contentHandler = contentHandler,
           let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

    // MARK: - Private

    private func downloadImage(
        from url: URL,
        completion: @escaping (UNNotificationAttachment?) -> Void
    ) {
        let task = URLSession.shared.downloadTask(with: url) { location, _, error in
            guard let location = location, error == nil else {
                completion(nil)
                return
            }

            // Move the downloaded file to a temp location with the correct extension
            let fileExtension = url.pathExtension.isEmpty ? "jpg" : url.pathExtension
            let tempUrl = location.deletingLastPathComponent()
                .appendingPathComponent(url.lastPathComponent)
                .deletingPathExtension()
                .appendingPathExtension(fileExtension)

            do {
                try FileManager.default.moveItem(at: location, to: tempUrl)
                let attachment = try UNNotificationAttachment(
                    identifier: "matchImage",
                    url: tempUrl,
                    options: nil
                )
                completion(attachment)
            } catch {
                completion(nil)
            }
        }
        task.resume()
    }
}
