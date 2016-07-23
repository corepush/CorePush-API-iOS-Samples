//
//  TokenUnregisterViewController.swift
//  CorePush-API-iOS-Samples
//
//  Copyright © 2016年 BlessService. All rights reserved.
//

import UIKit

/**
    トークン削除画面のビューコントローラ
 */
class TokenUnregisterViewController: UIViewController {
 
    // トークン削除ボタン
    @IBOutlet weak var unregisterButton: UIButton!
    
    // トークン表示ラベル
    @IBOutlet weak var tokenLabel: UILabel!
    
    /**
        トークン削除処理
    */
    @IBAction func unregisterAction() {
        CorePushAppManager.sharedInstance.unregisterDeviceToken()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: CorePushConst.NotificationType.TokenUnregisterSuccessNotification.rawValue, object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: CorePushConst.NotificationType.TokenUnregisterFailureNotification.rawValue, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "トークン削除"
        
        updateTokenLabel()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TokenUnregisterViewController.didReceivedUnregisterSuccessNotification(_:)), name: CorePushConst.NotificationType.TokenUnregisterSuccessNotification.rawValue, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TokenUnregisterViewController.didReceivedUnregisterFailureNotification(_:)), name: CorePushConst.NotificationType.TokenUnregisterFailureNotification.rawValue, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: CorePushConst.NotificationType.TokenUnregisterSuccessNotification.rawValue, object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: CorePushConst.NotificationType.TokenUnregisterFailureNotification.rawValue, object: nil)
    }
    
    func updateTokenLabel() {
        if let deviceToken = CorePushAppManager.sharedInstance.deviceToken where !deviceToken.isEmpty {
            tokenLabel.text = "デバイストークン： \(deviceToken)"
        } else {
            tokenLabel.text = "デバイストークン： 空"
        }
    }
    
    func didReceivedUnregisterSuccessNotification(notification: NSNotification) {
        NSLog("---- didReceivedUnregisterSuccessNotification ----")
        
        updateTokenLabel()
    }
    
    func didReceivedUnregisterFailureNotification(notification: NSNotification) {
        NSLog("---- didReceivedUnregisterFailureNotification ----")
    }
}