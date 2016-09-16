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
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: CorePushConst.NotificationType.TokenUnregisterSuccessNotification.rawValue), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: CorePushConst.NotificationType.TokenUnregisterFailureNotification.rawValue), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "トークン削除"
        
        updateTokenLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(TokenUnregisterViewController.didReceivedUnregisterSuccessNotification(_:)), name: NSNotification.Name(rawValue: CorePushConst.NotificationType.TokenUnregisterSuccessNotification.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(TokenUnregisterViewController.didReceivedUnregisterFailureNotification(_:)), name: NSNotification.Name(rawValue: CorePushConst.NotificationType.TokenUnregisterFailureNotification.rawValue), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: CorePushConst.NotificationType.TokenUnregisterSuccessNotification.rawValue), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: CorePushConst.NotificationType.TokenUnregisterFailureNotification.rawValue), object: nil)
    }
    
    func updateTokenLabel() {
        if let deviceToken = CorePushAppManager.sharedInstance.deviceToken, !deviceToken.isEmpty {
            tokenLabel.text = "デバイストークン： \(deviceToken)"
        } else {
            tokenLabel.text = "デバイストークン： 空"
        }
    }
    
    func didReceivedUnregisterSuccessNotification(_ notification: Notification) {
        NSLog("---- didReceivedUnregisterSuccessNotification ----")
        
        updateTokenLabel()
    }
    
    func didReceivedUnregisterFailureNotification(_ notification: Notification) {
        NSLog("---- didReceivedUnregisterFailureNotification ----")
    }
}
