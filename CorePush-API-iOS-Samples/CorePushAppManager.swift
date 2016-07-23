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
    func handleBackgroundNotification(userInfo: [NSObject : AnyObject])
    
    /**
        アプリがフォアグランドで動作中に通知を受信した時に CorePushAppManager#handleRemoteNotification から呼び出される。
        - parameter userInfo: 通知情報を含むオブジェクト
     */
    func handleForegroundNotifcation(userInfo: [NSObject : AnyObject])
   
    /**
        アプリのプロセスが起動していない状態で通知からアプリを起動した時に CorePushManager#handleLaunchingNotificationWithOption から呼び出される。
        - parameter userInfo: 通知情報を含むオブジェクト
     */
    func handleLaunchingNotification(userInfo: [NSObject : AnyObject])
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
            let userDefaults = NSUserDefaults.standardUserDefaults()
            return userDefaults.stringForKey(CorePushConst.CorePushDeviceTokenKey)
        }
        
        set {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(newValue, forKey: CorePushConst.CorePushDeviceTokenKey)
            userDefaults.synchronize()
        }
    }
    
    /**
        デバイストークンのサーバ送信フラグ
    */
    var isSentDeviceTokenToServer: Bool {
        get {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            return userDefaults.boolForKey(CorePushConst.CorePushIsSentDeviceTokenToServerKey)
        }
        
        set {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setBool(true, forKey: CorePushConst.CorePushIsSentDeviceTokenToServerKey)
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
            let types: UIUserNotificationType = [.Badge, .Sound, .Alert]
            let settings = UIUserNotificationSettings(forTypes: types, categories: nil)
            UIApplication.sharedApplication().registerForRemoteNotifications()
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        } else {
            // iOS8未満
            let types: UIRemoteNotificationType =  [.Badge, .Sound, .Alert]
            UIApplication.sharedApplication().registerForRemoteNotificationTypes(types)
        }
    }
    
    /**
        デバイストークンを登録する
     
        - parameter token: 登録するトークンのNSDataオブジェクト
    */
    func registerDeviceToken(data: NSData) {
        // デバイストークンのNSDataオブジェクトを文字列オブジェクトに変換する
        var deviceTokenString = NSString(format: "%@", data)
        deviceTokenString = deviceTokenString.substringWithRange(NSMakeRange(1, deviceTokenString.length-2)).stringByReplacingOccurrencesOfString(" ", withString: "")
        
        NSLog("deviceTokenString: \(deviceTokenString)")
        
        // デバイストークン文字列を登録する
        registerDeviceTokenString(deviceTokenString as String)
    }
    
    /**
        デバイストークンを登録する
     
        - parameter token: 登録するデバイストークンの文字列
    */
    func registerDeviceTokenString(token: String) {
  
        if let oldToken = self.deviceToken where oldToken != token {
            // デバイストークンの値が更新された場合は、古いデバイストークンをサーバから削除し、新しいデバイストークンをサーバに登録する
            
            // UserDefaultsにデバイストークンのサーバ送信フラグをfalseで保存
            self.isSentDeviceTokenToServer = false
            
            // 古いデバイストークンをサーバから削除する
            removeTokenFromServer(oldToken) { (isSuccess) in
                
                if !isSuccess {
                    // デバイストークン登録失敗時の通知を送信
                    NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: CorePushConst.NotificationType.TokenRegisterFailureNotification.rawValue, object:nil))
                } else {
                    // デバイストークンをサーバに登録する
                    self.sendTokenToServer(token) { (isSuccess) in
                        if !isSuccess {
                            /// デバイストークン登録失敗時の通知を送信
                            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: CorePushConst.NotificationType.TokenRegisterFailureNotification.rawValue, object: nil))
                        } else {
                            /// デバイストークン登録成功の場合
                            // UserDefaultsにデバイストークンを保存
                            self.deviceToken = token
                            
                            // UserDefaultsにデバイストークンのサーバ送信フラグをtrueで保存
                            self.isSentDeviceTokenToServer = true
                            
                            // デバイストークン登録成功の通知を送信
                            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: CorePushConst.NotificationType.TokenRegisterSuccessNotification.rawValue, object: nil))
                        }
                    }
                }
            }
            
        } else {
            // デバイストークンをサーバに登録する。
            sendTokenToServer(token) { (isSuccess) in
                if !isSuccess {
                    /// デバイストークン登録失敗時の通知を送信
                    NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: CorePushConst.NotificationType.TokenRegisterFailureNotification.rawValue, object: nil))
                } else {
                    /// デバイストークン登録成功の場合
                    // UserDefaultsにデバイストークンを保存
                    self.deviceToken = token
                    
                    // UserDefaultsにデバイストークンのサーバ送信フラグをtrueで保存
                    self.isSentDeviceTokenToServer = true
                    
                    // デバイストークン登録成功の通知を送信
                    NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: CorePushConst.NotificationType.TokenRegisterSuccessNotification.rawValue, object: nil))
                }
            }
        }
    }
    
    /**
        デバイストークンを解除する。
    */
    func unregisterDeviceToken() {
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        guard let token = userDefaults.stringForKey(CorePushConst.CorePushDeviceTokenKey) else {
            // UserDefaultsに削除対象のデバイストークンがない場合、削除処理を行わない。
            // デバイストークン削除成功の通知を送信
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: CorePushConst.NotificationType.TokenUnregisterSuccessNotification.rawValue, object: nil))
            return
        }
        
        // サーバからデバイストークンを削除する
        removeTokenFromServer(token) { (isSuccess) in
        
            if !isSuccess {
                // デバイストークン削除失敗の通知を送信
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: CorePushConst.NotificationType.TokenUnregisterFailureNotification.rawValue, object: nil))
            } else {
                // UserDefaultsからデバイストークンを削除
                self.deviceToken = nil
                
                // UserDefaultsにデバイストークンの送信フラグを保存
                self.isSentDeviceTokenToServer = false
                
                // デバイストークン削除成功の通知を送信
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: CorePushConst.NotificationType.TokenUnregisterSuccessNotification.rawValue, object: nil))
            }
        }
    }
    
    /**
        指定のデバイストークンをサーバに送信する。
     
        - parameter completionHandler: 送信完了のコールバック関数
    */
    private func sendTokenToServer(token: String, completionHandler: (isSucess: Bool) -> Void) {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        let url = NSURL(string: CorePushConst.CorePushRegistTokenApi)!
        let request = NSMutableURLRequest(URL: url, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30.0)
        request.HTTPMethod = "POST";
        
        // リクエストパラメータ
        let params: [String: String] = [
            "config_key": CorePushConst.CorePushConfigKey,
            "device_token": token,
            "mode": CorePushConst.TokenRegisterApiMode.Register.rawValue
        ]
        
        request.HTTPBody = CorePushUtil.HTTPBodyData(params)
        
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
            dispatch_async(dispatch_get_main_queue(), {
                
                guard error == nil && data != nil else {
                    // トークン登録失敗時の通知を送信
                    completionHandler(isSucess: false)
                    return
                }
                
                do {
                    let result = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as! NSDictionary
                    
                    if let status = result["status"] as? String where status == "0" {
                        /// トークン登録成功の場合
                        completionHandler(isSucess: true)
                    } else {
                        /// トークン登録失敗の場合
                        completionHandler(isSucess: false)
                    }
                } catch {
                    // トークン登録失敗の通知を送信
                    completionHandler(isSucess: false)
                }
            })
            
        })
        
        task.resume()
    }
    
    /**
        指定のデバイストークンをサーバから削除する
     
        - parameter completionHandler: 削除完了のコールバック関数
     */
    private func removeTokenFromServer(token: String, completionHandler: (isSuccess: Bool) -> Void){
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        let url = NSURL(string: CorePushConst.CorePushRegistTokenApi)!
        let request = NSMutableURLRequest(URL: url, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30.0)
        request.HTTPMethod = "POST";
        
        // リクエストパラメータ
        let params: [String: String] = [
            "config_key": CorePushConst.CorePushConfigKey,
            "device_token": token,
            "mode": CorePushConst.TokenRegisterApiMode.Unregister.rawValue
        ]
        
        request.HTTPBody = CorePushUtil.HTTPBodyData(params)
        
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
            dispatch_async(dispatch_get_main_queue(), {
                
                guard error == nil && data != nil else {
                    completionHandler(isSuccess: false)
                    return
                }
                
                do {
                    let result = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as! NSDictionary
                    
                    if let status = result["status"] as? String where status == "0" {
                        completionHandler(isSuccess: true)
                    } else {
                        completionHandler(isSuccess: false)
                    }
                } catch {
                    completionHandler(isSuccess: false)
                }
            })
            
        })
        
        task.resume()
    }
    
    /**
        アイコンのバッジ数をリセットする。
     */
    class func resetApplicationIconBadgeNumber() {
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }
    
    /**
        アイコンのバッジ数を指定する。
     */
    class func setApplicationIconBadgeNumber(badgeNumber: Int) {
        UIApplication.sharedApplication().applicationIconBadgeNumber = badgeNumber
    }
}

// MARK: - 通知受信のアクション

extension CorePushAppManager {
    
    /**
        アプリがバックグランドあるいはフォアグランドで動作中に通知を受信した時の処理を行う。
    */
    func handleRemoteNotification(userInfo: [NSObject : AnyObject]) {
        let applicationState = UIApplication.sharedApplication().applicationState
        
        if applicationState == .Active {
            // アプリがバックグランドで動作中に通知からアプリを起動した時の処理を移譲する。
            delegate?.handleForegroundNotifcation(userInfo)
        } else if applicationState == .Inactive {
            // アプリがフォアグランドで動作中に通知を受信した時の処理を移譲する。
            delegate?.handleBackgroundNotification(userInfo)
        }
    }
    
    /**
        アプリのプロセスが起動していない状態で通知からアプリを起動した場合の処理を行う
     
        - parameter launchOptions: アプリ起動オプション
     */
    func handleLaunchingNotificationWithOption(launchOptions: [NSObject: AnyObject]?) {
        if let launchOptions = launchOptions, userInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey] as? [NSObject : AnyObject] {
            
            // アプリのプロセスが起動していない状態で通知からアプリを起動した場合の処理を移譲する。
            delegate?.handleLaunchingNotification(userInfo)
        }
    }
}
