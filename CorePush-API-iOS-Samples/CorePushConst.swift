//
//  CorePushConst.swift
//  CorePush-API-iOS-Samples
//
//  Copyright © 2016年 BlessService. All rights reserved.
//

import Foundation

/**
    定数クラス
 */
struct CorePushConst {
    
    // トークン登録API
    static let CorePushRegistTokenApi = "https://api.core-asp.com/iphone_token_regist.php";
 
    // 履歴取得API
    static let CorePushNotificationHistoryApi = "https://api.core-asp.com/notify_history.php";

    // 設定キー
    static let CorePushConfigKey = "＜管理画面内のアプリの設定キーの値＞"
    
    // トークン保存のUserDefaultsのキー
    static let CorePushDeviceTokenKey = "COREPUSH_DEVICE_TOKEN_KEY";
    
    // デバイストークンをサーバに送信済みかを判定するUserDefaultsのキー
    static let CorePushIsSentDeviceTokenToServerKey = "COREPUSH_IS_SENT_DEVICE_TOKEN_TO_SERVER_KEY"
    
    /**
        トークン登録APIのモード
     
        - Register:   登録モード
        - Unregister: 削除モード
    */
    enum TokenRegisterApiMode: String {
        case Register   = "1"
        case Unregister = "2"
    }
    
    /**
        Notificationタイプ
     
        - TokenRegisterSuccessNotification:   トークン登録成功時のNSNotification
        - TokenRegisterFailureNotification:   トークン登録失敗時のNSNotification
        - TokenUnregisterSuccessNotification: トークン削除成功時のNSNotification
        - TokenUnregisterFailureNotification: トークン削除失敗時のNSNotification
     */
    enum NotificationType: String {
        case TokenRegisterSuccessNotification
        case TokenRegisterFailureNotification
        case TokenUnregisterSuccessNotification
        case TokenUnregisterFailureNotification
    }
}

