//
//  TokenRegisterViewController.swift
//  CorePush-API-iOS-Samples
//
//  Copyright © 2016年 BlessService. All rights reserved.
//

import UIKit

/**
    トークン登録画面のビューコントローラ
 */
class TokenRegisterViewController: UIViewController {
    
    // トークン登録ボタン
    @IBOutlet weak var registerButton: UIButton!
    
    // トークン表示ラベル
    @IBOutlet weak var tokenLabel: UILabel!
    
    // トークンラベル
    @IBAction func registerAction() {
        // トークン登録処理
        CorePushAppManager.sharedInstance.registerForRemoteNotifications()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: CorePushConst.NotificationType.TokenRegisterSuccessNotification.rawValue, object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: CorePushConst.NotificationType.TokenRegisterFailureNotification.rawValue, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "トークン登録"
        
        updateTokenLabel()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TokenRegisterViewController.didReceivedRegisterSuccessNotification(_:)), name: CorePushConst.NotificationType.TokenRegisterSuccessNotification.rawValue, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TokenRegisterViewController.didReceivedRegisterFailureNotification(_:)), name: CorePushConst.NotificationType.TokenRegisterFailureNotification.rawValue, object: nil)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: CorePushConst.NotificationType.TokenRegisterSuccessNotification.rawValue, object: nil)
        
       NSNotificationCenter.defaultCenter().removeObserver(self, name: CorePushConst.NotificationType.TokenRegisterFailureNotification.rawValue, object: nil)
    }
    
    func updateTokenLabel() {
        if let deviceToken = CorePushAppManager.sharedInstance.deviceToken where !deviceToken.isEmpty {
            tokenLabel.text = "デバイストークン： \(deviceToken)"
        } else {
            tokenLabel.text = "デバイストークン： 空"
        }
    }
    
    func didReceivedRegisterSuccessNotification(notification: NSNotification) {
        NSLog("---- didReceivedRegisterSuccessNotification ----")
        
        updateTokenLabel()
    }
    
    func didReceivedRegisterFailureNotification(notification: NSNotification) {
        NSLog("---- didReceivedRegisterFailureNotification ----")
    }
}