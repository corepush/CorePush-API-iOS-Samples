//
//  CorePushHistoryManager.swift
//  CorePush-API-iOS-Samples
//
//  Copyright © 2016年 BlessService. All rights reserved.
//

import Foundation

/**
    通知履歴取得のマネージャークラス
 */
class CorePushHistoryManager {
    
    static let sharedInstance = CorePushHistoryManager()
    
    private init() {
        
    }
    
    /**
        通知履歴を取得する。
     
        - paramter completionHandler: 履歴取得完了のコールバック関数
    */
    func requestHistory(completionHandler: (historys: [[String: AnyObject]]?) -> Void) {
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        let url = NSURL(string: CorePushConst.CorePushNotificationHistoryApi)!
        let request = NSMutableURLRequest(URL: url, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30.0)
        request.HTTPMethod = "POST";
        
        // リクエストパラメータ
        let params: [String: String] = [
            "config_type": "1",
            "config_key": CorePushConst.CorePushConfigKey
        ]
    
        request.HTTPBody = CorePushUtil.HTTPBodyData(params)
        
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
            dispatch_async(dispatch_get_main_queue(), {
                
                guard error == nil && data != nil else {
                    completionHandler(historys: nil)
                    return
                }
                
                do {
                    let result = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as! NSDictionary
                
                    if let status = result["status"] as? String where status == "0" {
                        // statusが0の場合、履歴一覧を取得する
                        if let results = result["results"] as? [[String: AnyObject]] {
                            completionHandler(historys: results)
                        }
                        
                    } else {
                        completionHandler(historys: nil)
                    }
                } catch {
                    completionHandler(historys: nil)
                }
            })
            
        })
        
        task.resume()
    }
}