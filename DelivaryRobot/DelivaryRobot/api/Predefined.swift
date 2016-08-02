//
//  Predefined.swift
//  DelivaryRobot
//
//  Created by ilikeido on 16/7/12.
//  Copyright © 2016年 ilikeido. All rights reserved.
//

import Foundation
import EVReflection

/// 通知预定义
public class RobotNotification{
    static let STATUS_CHANGE = "STATUS_CHANGE"
    static let POWER_CHANGE = "POWER_CHANGE"
    static let LOCATION_CHANGE = "LOCATION_CHANGE"
    static let ONLINE_CHANGE = "ONLINE_CHANGE"
    static let POSLABLE_CHANGE = "POSLABLE_CHANGE"
    static let DEVICE_STATUS = "DEVICE_STATUS"
    static let TABLEID_CHANGE = "TABLEID_CHANGE"
    static let APPBECOMEACTIVE = "APPBECOMEACTIVE"
}

/**
 控制指令
 
 - ACT_AUTOMOVE_SUSPEND: 暂停
 - ACT_FINDPATH_RESUME:  继续
 - ACT_MOVE_CTRL_CHARGE: 充电
 - ACT_MOVE_CTRL_WANDER: 漫游
 - ACT_MOVE_CTRL_STOP_SLOW: 停止
 - ACT_FINDPATH_STOP: 中断寻路
 - ACT_CTRL_GET_MEALS: 送餐机器人取餐
 */
public enum MOVE_CTRL_ACTION: Int {
    case ACT_AUTOMOVE_SUSPEND = 1
    case ACT_FINDPATH_RESUME = 2
    case ACT_MOVE_CTRL_CHARGE = 3
    case ACT_MOVE_CTRL_WANDER = 4
    case ACT_MOVE_CTRL_STOP_SLOW  = 5
    case ACT_FINDPATH_STOP  = 6
    case ACT_MOVE_CTRL_GET_MEALS  = 7
}

/**
 移动方向
 
 - MOVE_DIRCTION_LEFT:   左
 - MOVE_DIRCTION_RIGHT:  右
 - MOVE_DIRCTION_FONT:   上
 - MOVE_DIRCTION_BOTTOM: 下
 */
public enum MOVE_DIRCTION: Int {
    case MOVE_DIRCTION_LEFT = 1
    case MOVE_DIRCTION_RIGHT = 2
    case MOVE_DIRCTION_FONT = 3
    case MOVE_DIRCTION_BOTTOM = 4
    case MOVE_DIRCTION_STOP = 0
}

/**
 机器人当前状态
 
 - MOVE_AUTO:     自动导航
 - MOVE_ROCKER:   手柄柄制
 - MOVE_TASK:     巡逻作务
 - MOVE_WANDER:   自动漫游
 - MOVE_FREE:     闲置任务
 - MOVE_TOCHARGE: 前去充电
 - MOVE_CHARGING: 正在充电
 - MOVE_MEAL:     正在送餐
 - MOVE_LEVETRACK:脱离磁道
 - MOVE_WAITREADY:等待就位
 - MOVE_WAITBEGINMEAL: 等待送餐
 - MOVE_MEALARRIVE:送餐到达
 - MOVE_GOBACK:   正在返回
 - MOVE_MEALSTOP: 送餐终止
 */
public enum ROBOT_STATUS: Int {
    case MOVE_AUTO = 1
    case MOVE_ROCKER = 2
    case MOVE_TASK = 3
    case MOVE_WANDER = 4
    case MOVE_FREE = 5
    case MOVE_TOCHARGE = 6
    case MOVE_CHARGING = 7
    case MOVE_MEAL = 8
    case MOVE_TIMEOUT = 9
    case MOVE_LEVETRACK = 10
    case MOVE_WAITREADY = 8001
    case MOVE_WAITBEGINMEAL = 8002
    case MOVE_MEALARRIVE = 8004
    case MOVE_GOBACK = 8005
    case MOVE_MEALSTOP = 8006
    case MOVE_ERROR = -1
    case MOVE_ANKOWN = 0
    
    
    static func IntToStatus(value:Int) -> ROBOT_STATUS {
        switch value {
        case 0:
            return MOVE_FREE
        case 1:
            return MOVE_AUTO
        case 2:
            return MOVE_ROCKER
        case 3:
            return MOVE_TASK
        case 4:
            return MOVE_WANDER
        case 5:
            return MOVE_FREE
        case 6:
            return MOVE_TOCHARGE
        case 7:
            return MOVE_CHARGING
        case 8:
            return MOVE_MEAL
        case 9:
            return MOVE_TIMEOUT
        case 10:
            return MOVE_LEVETRACK
        case 8001:
            return MOVE_WAITREADY
        case 8002:
            return MOVE_WAITBEGINMEAL
        case 8004:
            return MOVE_MEALARRIVE
        case 8005:
            return MOVE_GOBACK
        case 8006:
            return MOVE_MEALSTOP
        default:
            return MOVE_ANKOWN
        }
    }
}


public class RotbotInfoManager{
    
    private var rotBotInfoMap:[String:RotbotInfo] = [:]
    
    var current_endpoint_id:String?
    var current_endpoin_name:String?
    
    class var sharedInstance : RotbotInfoManager {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : RotbotInfoManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = RotbotInfoManager()
        }
        return Static.instance!
    }
    
    func robotWithEndpointId(endpoint_id:String) -> RotbotInfo {
        let rotbotinfo = rotBotInfoMap[endpoint_id]
        if nil == rotbotinfo {
            let rotbotinfo1 = RotbotInfo(endpoint_id: endpoint_id)
            rotBotInfoMap[endpoint_id] = rotbotinfo1
        }
        return rotBotInfoMap[endpoint_id]!
    }
}

public class RotbotInfo{
    var online = true
    var status = ROBOT_STATUS.MOVE_ANKOWN
    var power = 100
    var local_x = 0 //单位毫米
    var local_y = 0 //单位毫米
    var angle = 0   //单位百分之一度  900表示90度
    var endpoint_id = ""
    var posLable = -1
    var errorDetail = ""
    var tableId = -1
    
    init(endpoint_id:String){
        self.endpoint_id = endpoint_id
    }
    
    func clearStatus() -> Void {
        status = ROBOT_STATUS.MOVE_ANKOWN
        power = 0
        local_x = 0
        local_y = 0
        angle = 0
        posLable = -1
    }
    
    func statusName() -> String {
        switch self.status {
        case ROBOT_STATUS.MOVE_AUTO:
            return "自动导航"
        case ROBOT_STATUS.MOVE_ROCKER:
            return "手柄柄制"
        case ROBOT_STATUS.MOVE_TASK:
            return "巡逻作务"
        case ROBOT_STATUS.MOVE_WANDER:
            return "自动漫游"
        case ROBOT_STATUS.MOVE_FREE:
            return "闲置任务"
        case ROBOT_STATUS.MOVE_TOCHARGE:
            return "前去充电"
        case ROBOT_STATUS.MOVE_CHARGING:
            return "正在充电"
        case ROBOT_STATUS.MOVE_MEAL:
            if self.tableId>0 {
                return "正在送餐" + "(" + self.tableId.description + "号桌)"
            }else{
                return "正在送餐"
            }
        case ROBOT_STATUS.MOVE_LEVETRACK:
            return "脱离磁道"
        case ROBOT_STATUS.MOVE_WAITREADY:
            return "等待就位"
        case ROBOT_STATUS.MOVE_WAITBEGINMEAL:
            return "等待送餐"
        case ROBOT_STATUS.MOVE_MEALARRIVE:
            return "送餐到达"
        case ROBOT_STATUS.MOVE_GOBACK:
            return "正在返回"
        case ROBOT_STATUS.MOVE_MEALSTOP:
            return "送餐终止"
        case ROBOT_STATUS.MOVE_TIMEOUT:
            return "超时停止"
        default:
            return "未知"
        }
    }
}

class EndPoint: EVObject {
    var registration_id = ""
    var login_user = ""
    var last_update = ""
    var registration_date = ""
    var endpoin_name = ""
    var battery_percent = ""
}

class SeatData:EVObject{
    var seat = ""
    var x = 0.0
    var y = 0.0
    var angle = 0
    var x0 = 0.0
    var y0 = 0.0
    var tag = 0
}


