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
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: CorePushConst.NotificationType.TokenRegisterSuccessNotification.rawValue), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: CorePushConst.NotificationType.TokenRegisterFailureNotification.rawValue), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "トークン登録"
        
        updateTokenLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(TokenRegisterViewController.didReceivedRegisterSuccessNotification(_:)), name: NSNotification.Name(rawValue: CorePushConst.NotificationType.TokenRegisterSuccessNotification.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(TokenRegisterViewController.didReceivedRegisterFailureNotification(_:)), name: NSNotification.Name(rawValue: CorePushConst.NotificationType.TokenRegisterFailureNotification.rawValue), object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: CorePushConst.NotificationType.TokenRegisterSuccessNotification.rawValue), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: CorePushConst.NotificationType.TokenRegisterFailureNotification.rawValue), object: nil)
    }
    
    func updateTokenLabel() {
        if let deviceToken = CorePushAppManager.sharedInstance.deviceToken, !deviceToken.isEmpty {
            tokenLabel.text = "デバイストークン： \(deviceToken)"
        } else {
            tokenLabel.text = "デバイストークン： 空"
        }
    }
    
    func didReceivedRegisterSuccessNotification(_ notification: Notification) {
        NSLog("---- didReceivedRegisterSuccessNotification ----")
        
        updateTokenLabel()
    }
    
    func didReceivedRegisterFailureNotification(_ notification: Notification) {
        NSLog("---- didReceivedRegisterFailureNotification ----")
    }
}
