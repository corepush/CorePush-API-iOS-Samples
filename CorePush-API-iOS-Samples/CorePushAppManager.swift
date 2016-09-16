//
//  CorePushAppManager.swift
//  CorePush-API-iOS-Samples
//
//  Copyright © 2016年 BlessService. All rights reserved.
//

import UIKit

/**
 CorePushAppManagerのデリゲートプロトコル
 */
protocol CorePushAppManagerDelegate: class {
    /**
     アプリがバックグランドで動作中に通知からアプリを起動した時に CorePushAppManager#handleRemoteNotification から呼び出される
     - parameter userInfo: 通知情報を含むオブジェクト
     */
    func handleBackgroundNotification(_ userInfo: [AnyHashable : Any])
    
    /**
     アプリがフォアグランドで動作中に通知を受信した時に CorePushAppManager#handleRemoteNotification から呼び出される。
     - parameter userInfo: 通知情報を含むオブジェクト
     */
    func handleForegroundNotifcation(_ userInfo: [AnyHashable : Any])
    
    /**
     アプリのプロセスが起動していない状態で通知からアプリを起動した時に CorePushManager#handleLaunchingNotificationWithOption から呼び出される。
     - parameter userInfo: 通知情報を含むオブジェクト
     */
    func handleLaunchingNotification(_ userInfo: [AnyHashable : Any])
}

/**
 通知のマネージャークラス
 */
class CorePushAppManager {
    
    // シングルトン
    static let sharedInstance = CorePushAppManager()
    
    // CorePushAppManagerDelegateのデリゲートオブジェクト
    weak var delegate: CorePushAppManagerDelegate?
    
    /**
     デバイストークン
     */
    var deviceToken: String? {
        get {
            let userDefaults = UserDefaults.standard
            return userDefaults.string(forKey: CorePushConst.CorePushDeviceTokenKey)
        }
        
        set {
            let userDefaults = UserDefaults.standard
            userDefaults.set(newValue, forKey: CorePushConst.CorePushDeviceTokenKey)
            userDefaults.synchronize()
        }
    }
    
    /**
     デバイストークンのサーバ送信フラグ
     */
    var isSentDeviceTokenToServer: Bool {
        get {
            let userDefaults = UserDefaults.standard
            return userDefaults.bool(forKey: CorePushConst.CorePushIsSentDeviceTokenToServerKey)
        }
        
        set {
            let userDefaults = UserDefaults.standard
            userDefaults.set(true, forKey: CorePushConst.CorePushIsSentDeviceTokenToServerKey)
            userDefaults.synchronize()
        }
    }
    
    private init() {
        
    }
    
    /**
     リモート通知の登録を行う
     */
    func registerForRemoteNotifications() {
        if #available(iOS 8, *) {
            // iOS8以上
            let types: UIUserNotificationType = [.badge, .sound, .alert]
            let settings = UIUserNotificationSettings(types: types, categories: nil)
            UIApplication.shared.registerForRemoteNotifications()
            UIApplication.shared.registerUserNotificationSettings(settings)
        } else {
            // iOS8未満
            let types: UIRemoteNotificationType =  [.badge, .sound, .alert]
            UIApplication.shared.registerForRemoteNotifications(matching: types)
        }
    }
    
    /**
     デバイストークンを登録する
     
     - parameter token: 登録するトークンのNSDataオブジェクト
     */
    func registerDeviceToken(_ data: Data) {
        // デバイストークンのNSDataオブジェクトを文字列オブジェクトに変換する
        var deviceTokenString = NSString(format: "%@", data as CVarArg)
        deviceTokenString = deviceTokenString.substring(with: NSMakeRange(1, deviceTokenString.length-2)).replacingOccurrences(of: " ", with: "") as NSString
        
        NSLog("deviceTokenString: \(deviceTokenString)")
        
        // デバイストークン文字列を登録する
        registerDeviceTokenString(deviceTokenString as String)
    }
    
    /**
     デバイストークンを登録する
     
     - parameter token: 登録するデバイストークンの文字列
     */
    func registerDeviceTokenString(_ token: String) {
        
        if let oldToken = self.deviceToken, oldToken != token {
            // デバイストークンの値が更新された場合は、古いデバイストークンをサーバから削除し、新しいデバイストークンをサーバに登録する
            
            // UserDefaultsにデバイストークンのサーバ送信フラグをfalseで保存
            self.isSentDeviceTokenToServer = false
            
            // 古いデバイストークンをサーバから削除する
            removeTokenFromServer(oldToken) { (isSuccess) in
                
                if !isSuccess {
                    // デバイストークン登録失敗時の通知を送信
                    NotificationCenter.default.post(name: Notification.Name(CorePushConst.NotificationType.TokenRegisterFailureNotification.rawValue), object: nil)
                } else {
                    // デバイストークンをサーバに登録する
                    self.sendTokenToServer(token) { (isSuccess) in
                        if !isSuccess {
                            /// デバイストークン登録失敗時の通知を送信
                            NotificationCenter.default.post(name: Notification.Name(CorePushConst.NotificationType.TokenRegisterFailureNotification.rawValue), object: nil)
                        } else {
                            /// デバイストークン登録成功の場合
                            // UserDefaultsにデバイストークンを保存
                            self.deviceToken = token
                            
                            // UserDefaultsにデバイストークンのサーバ送信フラグをtrueで保存
                            self.isSentDeviceTokenToServer = true
                            
                            // デバイストークン登録成功の通知を送信
                            NotificationCenter.default.post(name: Notification.Name(CorePushConst.NotificationType.TokenRegisterSuccessNotification.rawValue), object: nil)
                        }
                    }
                }
            }
            
        } else {
            // デバイストークンをサーバに登録する。
            sendTokenToServer(token) { (isSuccess) in
                if !isSuccess {
                    /// デバイストークン登録失敗時の通知を送信
                    NotificationCenter.default.post(name: Notification.Name(CorePushConst.NotificationType.TokenRegisterFailureNotification.rawValue), object: nil)
                } else {
                    /// デバイストークン登録成功の場合
                    // UserDefaultsにデバイストークンを保存
                    self.deviceToken = token
                    
                    // UserDefaultsにデバイストークンのサーバ送信フラグをtrueで保存
                    self.isSentDeviceTokenToServer = true
                    
                    // デバイストークン登録成功の通知を送信
                    NotificationCenter.default.post(name: Notification.Name(CorePushConst.NotificationType.TokenRegisterSuccessNotification.rawValue), object: nil)
                }
            }
        }
    }
    
    /**
     デバイストークンを解除する。
     */
    func unregisterDeviceToken() {
        
        let userDefaults = UserDefaults.standard
        guard let token = userDefaults.string(forKey: CorePushConst.CorePushDeviceTokenKey) else {
            // UserDefaultsに削除対象のデバイストークンがない場合、削除処理を行わない。
            // デバイストークン削除成功の通知を送信
            NotificationCenter.default.post(name: Notification.Name(CorePushConst.NotificationType.TokenUnregisterSuccessNotification.rawValue), object: nil)
            return
        }
        
        // サーバからデバイストークンを削除する
        removeTokenFromServer(token) { (isSuccess) in
            
            if !isSuccess {
                // デバイストークン削除失敗の通知を送信
                NotificationCenter.default.post(name: Notification.Name(rawValue: CorePushConst.NotificationType.TokenUnregisterFailureNotification.rawValue), object: nil)
            } else {
                // UserDefaultsからデバイストークンを削除
                self.deviceToken = nil
                
                // UserDefaultsにデバイストークンの送信フラグを保存
                self.isSentDeviceTokenToServer = false
                
                // デバイストークン削除成功の通知を送信
                NotificationCenter.default.post(name: Notification.Name(CorePushConst.NotificationType.TokenUnregisterSuccessNotification.rawValue), object: nil)
            }
        }
    }
    
    /**
     指定のデバイストークンをサーバに送信する。
     
     - parameter completionHandler: 送信完了のコールバック関数
     */
    private func sendTokenToServer(_ token: String, completionHandler: @escaping (_ isSucess: Bool) -> Void) {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let url = URL(string: CorePushConst.CorePushRegistTokenApi)!
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30.0)
        request.httpMethod = "POST";
        
        // リクエストパラメータ
        let params: [String: String] = [
            "config_key": CorePushConst.CorePushConfigKey,
            "device_token": token,
            "mode": CorePushConst.TokenRegisterApiMode.Register.rawValue
        ]
        
        request.httpBody = CorePushUtil.HTTPBodyData(params)
        
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            DispatchQueue.main.async(execute: {
                
                guard error == nil && data != nil else {
                    // トークン登録失敗時の通知を送信
                    completionHandler(false)
                    return
                }
                
                do {
                    let result = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary
                    
                    if let status = result["status"] as? String, status == "0" {
                        /// トークン登録成功の場合
                        completionHandler(true)
                    } else {
                        /// トークン登録失敗の場合
                        completionHandler(false)
                    }
                } catch {
                    // トークン登録失敗の通知を送信
                    completionHandler(false)
                }
            })
            
        })
        
        task.resume()
    }
    
    /**
     指定のデバイストークンをサーバから削除する
     
     - parameter completionHandler: 削除完了のコールバック関数
     */
    private func removeTokenFromServer(_ token: String, completionHandler: @escaping (_ isSuccess: Bool) -> Void){
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let url = URL(string: CorePushConst.CorePushRegistTokenApi)!
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30.0)
        request.httpMethod = "POST";
        
        // リクエストパラメータ
        let params: [String: String] = [
            "config_key": CorePushConst.CorePushConfigKey,
            "device_token": token,
            "mode": CorePushConst.TokenRegisterApiMode.Unregister.rawValue
        ]
        
        request.httpBody = CorePushUtil.HTTPBodyData(params)
        
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            DispatchQueue.main.async(execute: {
                
                guard error == nil && data != nil else {
                    completionHandler(false)
                    return
                }
                
                do {
                    let result = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary
                    
                    if let status = result["status"] as? String, status == "0" {
                        completionHandler(true)
                    } else {
                        completionHandler(false)
                    }
                } catch {
                    completionHandler(false)
                }
            })
            
        })
        
        task.resume()
    }
    
    /**
     アイコンのバッジ数をリセットする。
     */
    class func resetApplicationIconBadgeNumber() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    /**
     アイコンのバッジ数を指定する。
     */
    class func setApplicationIconBadgeNumber(_ badgeNumber: Int) {
        UIApplication.shared.applicationIconBadgeNumber = badgeNumber
    }
}

// MARK: - 通知受信のアクション

extension CorePushAppManager {
    
    /**
     アプリがバックグランドあるいはフォアグランドで動作中に通知を受信した時の処理を行う。
     */
    func handleRemoteNotification(_ userInfo: [AnyHashable : Any]) {
        let applicationState = UIApplication.shared.applicationState
        
        if applicationState == .active {
            // アプリがバックグランドで動作中に通知からアプリを起動した時の処理を移譲する。
            delegate?.handleForegroundNotifcation(userInfo)
        } else if applicationState == .inactive {
            // アプリがフォアグランドで動作中に通知を受信した時の処理を移譲する。
            delegate?.handleBackgroundNotification(userInfo)
        }
    }
    
    /**
     アプリのプロセスが起動していない状態で通知からアプリを起動した場合の処理を行う
     
     - parameter launchOptions: アプリ起動オプション
     */
    func handleLaunchingNotificationWithOption(_ launchOptions: [UIApplicationLaunchOptionsKey : Any]? ) {
        if let launchOptions = launchOptions, let userInfo = launchOptions[.remoteNotification] as? [NSObject : AnyObject] {
            // アプリのプロセスが起動していない状態で通知からアプリを起動した場合の処理を移譲する。
            delegate?.handleLaunchingNotification(userInfo)
        }
    }
}
