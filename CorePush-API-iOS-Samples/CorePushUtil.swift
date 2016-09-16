//
//  CorePushUtil.swift
//  CorePush-API-iOS-Samples
//
//  Copyright © 2016年 BlessService. All rights reserved.
//

import Foundation

/**
 ユーティリティクラス
 */
class CorePushUtil {
    
    /**
     パラメータの辞書データをHTTPBodyのDataオブジェクトに変換する
     */
    static func HTTPBodyData(_ params: [String: String]) -> Data? {
        var bodyData = ""
        for (index, element) in params.enumerated() {
            let key = element.0
            let value = element.1
            bodyData += "\(key)=\(value)"
            if index != params.count-1 {
                bodyData += "&"
            }
        }
        
        return bodyData.data(using: String.Encoding.utf8)
    }
}
