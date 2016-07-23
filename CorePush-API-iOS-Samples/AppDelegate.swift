//
//  AppDelegate.swift
//  CorePush-API-iOS-Samples
//
//  Copyright © 2016年 BlessService. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // CorePushAppManagerの初期設定
        let corePushAppManager = CorePushAppManager.sharedInstance
        corePushAppManager.delegate = self
        
        // アプリ起動時に通知許可を行う場合は、通知の登録処理を行う。
//        corePushAppManager.registerForRemoteNotifications()
        
        // アプリのプロセスが起動していない状態で通知からアプリを起動した場合の処理を行う。
        corePushAppManager.handleLaunchingNotificationWithOption(launchOptions)
        
        return true
    }

    // 通知サービスの登録成功時に呼ばれる。
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
       NSLog("---- application:didRegisterForRemoteNotificationsWithDeviceToken ----")
        CorePushAppManager.sharedInstance.registerDeviceToken(deviceToken)
    }
    
    // 通知サービスの登録失敗時に呼ばれる。
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        NSLog("---- application:didFailToRegisterForRemoteNotificationsWithError:error ----")
        NSLog("error: \(error.description)")
    }
    
    @available(iOS 8.0, *)
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        NSLog("---- application:didRegisterUserNotificationSettings ----")
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        NSLog("---- application:didReceiveRemoteNotification:userInfo ----")
        
        // 通知の受信処理を行う。
        CorePushAppManager.sharedInstance.handleRemoteNotification(userInfo)
 
        // アイコンのバッジ数をリセットする。
        CorePushAppManager.resetApplicationIconBadgeNumber()
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // アイコンのバッジ数をリセットする。
        CorePushAppManager.resetApplicationIconBadgeNumber()
    }

}

// MARK: - CorePushManagerDelegate

extension AppDelegate: CorePushAppManagerDelegate {
    
    func handleBackgroundNotification(userInfo: [NSObject : AnyObject]) {
        NSLog("---- handleBackgroundNotification -----")
    }
    
    func handleForegroundNotifcation(userInfo: [NSObject : AnyObject]) {
        NSLog("---- handleForegroundNotifcation -----")
    }
    
    func handleLaunchingNotification(userInfo: [NSObject : AnyObject]) {
        NSLog("---- handleLaunchingNotification -----")
    }
}


