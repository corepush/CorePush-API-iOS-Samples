//
//  NotificationService.swift
//  NotificationService
//
//  Copyright © 2016年 BlessService. All rights reserved.
//

import UserNotifications

/**
    通知データを前処理するサービスクラス
 */
class NotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            // media-urlをキーにメディアのurlを取得
            // media-typeをキーにメディアの種別を取得
            if let mediaUrlString = bestAttemptContent.userInfo["media-url"] as? String,
                let mediaUrl = URL(string: mediaUrlString),
                let mediaTypeString = bestAttemptContent.userInfo["media-type"] as? String
            {
                // 指定のurlのメディアをダウンロード
                let session = URLSession(configuration: URLSessionConfiguration.default)
                let downloadTask = session.downloadTask(with: mediaUrl, completionHandler: { (url, response, error) in
                    if let error = error {
                        print("Error downloading attachment: \(error.localizedDescription)")
                    } else if let url = url {
                        // ダウンロードしたメディアを通知に添付する
                        let attachment = try! UNNotificationAttachment(identifier: mediaUrlString, url: url, options: [UNNotificationAttachmentOptionsTypeHintKey : mediaTypeString])
                        bestAttemptContent.attachments = [attachment]
                    }
                    contentHandler(bestAttemptContent)
                })
                downloadTask.resume()
            } else {
                contentHandler(bestAttemptContent)
            }
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}
