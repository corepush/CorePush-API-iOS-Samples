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
    static func HTTPBodyData(params: [String: String]) -> NSData? {
        var bodyData = ""
        for (index, element) in params.enumerate() {
            let key = element.0
            let value = element.1
            bodyData += "\(key)=\(value)"
            if index != params.count-1 {
                bodyData += "&"
            }
        }

        return bodyData.dataUsingEncoding(NSUTF8StringEncoding)
    }
}