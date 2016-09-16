//
//  AppDelegate.swift
//  CorePush-API-iOS-Samples
//
//  Copyright © 2016年 BlessService. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        
        // CorePushAppManagerの初期設定
        let corePushAppManager = CorePushAppManager.sharedInstance
        corePushAppManager.delegate = self
        
        // UserNotificationsの初期設定(iOS10)
        configureUserNotifications()
        
        // アプリ起動時に通知許可を行う場合は、通知の登録処理を行う。
        //        corePushAppManager.registerForRemoteNotifications()
        
        // アプリのプロセスが起動していない状態で通知からアプリを起動した場合の処理を行う。
        corePushAppManager.handleLaunchingNotificationWithOption(launchOptions)
        
        return true
    }
    
    // 通知サービスの登録成功時に呼ばれる。
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        NSLog("---- application:didRegisterForRemoteNotificationsWithDeviceToken ----")
        CorePushAppManager.sharedInstance.registerDeviceToken(deviceToken)
    }
    
    // 通知サービスの登録失敗時に呼ばれる。
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        NSLog("---- application:didFailToRegisterForRemoteNotificationsWithError:error ----")
        NSLog("error: \(error)")
    }
    
    @available(iOS 8.0, *)
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        NSLog("---- application:didRegisterUserNotificationSettings ----")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        NSLog("---- application:didReceiveRemoteNotification:userInfo ----")
        
        // 通知の受信処理を行う。
        CorePushAppManager.sharedInstance.handleRemoteNotification(userInfo)
        
        // アイコンのバッジ数をリセットする。
        CorePushAppManager.resetApplicationIconBadgeNumber()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // アイコンのバッジ数をリセットする。
        CorePushAppManager.resetApplicationIconBadgeNumber()
    }
    
    private func configureUserNotifications() {
        // iOS10のUser Notficationsの設定
        if #available(iOS 10.0, *) {
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.delegate = self
        }
    }
}

// MARK: - CorePushManagerDelegate

extension AppDelegate: CorePushAppManagerDelegate {
    
    func handleBackgroundNotification(_ userInfo: [AnyHashable : Any]) {
        NSLog("---- handleBackgroundNotification -----")
    }
    
    func handleForegroundNotifcation(_ userInfo: [AnyHashable : Any]) {
        NSLog("---- handleForegroundNotifcation -----")
    }
    
    func handleLaunchingNotification(_ userInfo: [AnyHashable : Any]) {
        NSLog("---- handleLaunchingNotification -----")
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Swift.Void) {
        completionHandler([.badge, .sound, .alert])
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Swift.Void) {
        completionHandler()
    }
}

