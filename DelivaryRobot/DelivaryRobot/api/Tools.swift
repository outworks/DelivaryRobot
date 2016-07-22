//
//  Tools.swift
//  DelivaryRobot
//
//  Created by ilikeido on 16/7/13.
//  Copyright © 2016年 ilikeido. All rights reserved.
//

import Foundation

class TopicTools {
    
    static var notificationMap : [String :String] = [:]
    
    static func pushNotification(notificationName:String,endpoint_id:String) -> Void {
        notificationMap[notificationName] = endpoint_id
    }
    
    static func getEndpoint_id(notificationName:String) -> String? {
        return notificationMap[notificationName]
    }
}

class ShareDatas {
    class var sharedInstance : ShareDatas {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : ShareDatas? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = ShareDatas()
        }
        return Static.instance!
    }

}