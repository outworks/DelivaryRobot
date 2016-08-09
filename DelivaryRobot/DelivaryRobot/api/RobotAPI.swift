//
//  RobotAPI.swift
//  DelivaryRobot
//
//  Created by ilikeido on 16/7/11.
//  Copyright © 2016年 ilikeido. All rights reserved.
//

import Foundation
import Alamofire
import EVReflection
import SwiftyJSON


class RobotAPI :BaseHttpAPI{
    
    static let DEFIND_HOST = "http://172.24.132.20"
    //    static let DEFIND_HOST = "http://172.24.132.20"
    static var user_key = "4bf5772289cd701bc29486f0e87aee27"
    static var user_login = false
    static var notificationHandler = TopicNotificationHandler()
    
    class LoginParams: EVObject {
        var account_name = ""
        var password = ""
        init(username:String,password:String) {
            super.init()
            self.account_name = username
            self.password = password
        }
        
        required init() {
            super.init()
        }
        
    }
    
    class LoginResult: EVObject {
        var user_name = ""
        var user_id = ""
        var user_key = ""
        var create_time = ""
        var encrypt_key = ""
        var account_name = ""
    }
    
    
    class MQTTClientIDResult:EVObject {
        var client_id = ""
    }
    
    class RockerCtrlCMD: EVObject {
        var moveMode = 1
        var lineSpd = 0
        var angSpd = 1
        var timeStam = NSDate().timeIntervalSince1970 * 1000
    }
    
    class RobotStatusResult{
        
    }
    
    /**
     登录
     
     - parameter params:        登录参数
     - parameter successHandle: 成功回调
     - parameter errorHandler:  错误回调
     */
    static func login(params:LoginParams,func successHandle:(result:LoginResult)->Void,func errorHandler:(error:BaseError?) ->Void)->Void{
        let params = LoginParams(username:params.account_name,password:params.password )
        request(.POST, path: "/v0.1/tokens", params: params, serverPort: "8081", func: { (result:LoginResult?) in
            if nil != result{
                user_login = true
                user_key = result!.user_key
            }
            successHandle(result: result!)
        }) { (error) in
            errorHandler(error: error)
        }
    }
    
    /**
     获取机器节点
     
     - parameter successHandle: 成功回调
     - parameter errorHandler:  错误回调
     */
    static func getEndpoints(func successHandle:(result:[EndPoint]?)->Void,func errorHandler:(error:BaseError?) ->Void)->Void{
        request(.GET, path: "/v0.1/endpoints", func: { (result:[EndPoint]?) in
            successHandle(result: result)
        }) { (error) in
            errorHandler(error: error)
        }
    }
    
    
    /**
     登录机器
     - parameter endpoint_id:   编号
     - parameter successHandle: 成功回调
     - parameter errorHandler:  错误回调
     */
    static func loginRobot(endpoint_id:String,func successHandle:()->Void,func errorHandler:(error:BaseError?) ->Void)->Void{
        let path = String(format: "/v0.1/endpoints/%@/robot/login/", endpoint_id)
        let dict = ["prior":"true"]
        request(.POST, path: path, paramsdict: dict, serverPort: nil, func: { (result:OKResult?) in
            let path1 = String(format: "/v0.1/endpoints/%@/robot/ctrlapp_login", endpoint_id)
            let dict1 = [:]
            request(.POST, path: path1, paramsdict: dict1,serverPort: nil,func: { (result1:NSDictionary?) in
                let robotinfo = RotbotInfoManager.sharedInstance.robotWithEndpointId(endpoint_id)
                let message = (result1?["message"]) as? NSString
                if nil != message{
                    let messageJson = JSON.parse(message! as String)
                    let array:Array<JSON> = messageJson.arrayValue
                    for dic:JSON in array {
                        let idstr = dic["id"].intValue
                        if 10004 == idstr{
                            let infodict = dic["info"].dictionary!
                            let status = infodict["status"]!.intValue
                            let preStatus = infodict["preStatus"]!.intValue
                            robotinfo.status = ROBOT_STATUS.IntToStatus(status)
                            robotinfo.preStatus = ROBOT_STATUS.IntToStatus(preStatus)
                        }
                        if 10005 == idstr{
                            let infodict = dic["info"].dictionary
                            let value = infodict!["percent"]!.intValue
                            robotinfo.power = value
                        }
                        if 10003 == idstr{
                            let infodict = dic["info"].dictionary
                            let value = infodict!["percent"]!.intValue
                            robotinfo.power = value
                        }
                        
                    }
                }
                getRobotposLable(endpoint_id, func: { (posLable) in
                    successHandle()
                    }, func: { (error1) in
                        errorHandler(error: error1)
                })
                }, func: { (error) in
                    errorHandler(error: error)
            })
            
        }) { (error) in
            errorHandler(error: error)
        }
    }
    
    static func getSeatList() -> [SeatData]{
        let array = [
            ["seat":"A-002","x":3.6,"y":0.0,"angle":180,"x0":3.6,"y0":-1,"tag":2],
            ["seat":"A-003","x":7.1,"y":0.0,"angle":180,"x0":7.1,"y0":-1,"tag":3],
            ["seat":"A-004","x":10.1,"y":0.0,"angle":180,"x0":10.1,"y0":-1,"tag":4],
            ["seat":"B-005","x":12.3,"y":1.0,"angle":180,"x0":13,"y0":0.5,"tag":5],
            ["seat":"C-006","x":20.0,"y":2.0,"angle":90,"x0":21.3,"y0":1.6,"tag":6],
            ["seat":"C-007","x":21.3,"y":0.6,"angle":180,"x0":21.3,"y0":-0.4,"tag":7],
            ["seat":"C-008","x":23.5,"y":0.6,"angle":0,"x0":24.0,"y0":1.6,"tag":8],
            ["seat":"C-009","x":24.0,"y":0.6,"angle":180,"x0":24.0,"y0":-0.4,"tag":9],
            ["seat":"C-010","x":26.1,"y":0.6,"angle":0,"x0":26.7,"y0":1.6,"tag":10],
            ["seat":"C-011","x":26.7,"y":0.6,"angle":180,"x0":26.7,"y0":-0.4,"tag":11],
            ["seat":"D-012","x":29.7,"y":0.8,"angle":180,"x0":29.7,"y0":0,"tag":12],
            ["seat":"D-013","x":31.1,"y":0.8,"angle":0,"x0":31.5,"y0":1.8,"tag":13],
            ["seat":"D-014","x":32.1,"y":0.8,"angle":180,"x0":32.1,"y0":0,"tag":14],
            ["seat":"E-015","x":34.0,"y":0.8,"angle":90,"x0":35.0,"y0":0.8,"tag":15]
        ]
        var list = [SeatData]()
        for seatDict in array{
            let seat = SeatData()
            EVReflection.setPropertiesfromDictionary(seatDict, anyObject: seat)
            list.append(seat)
        }
        return list
    }
    
        
    /**
     送餐到某个位置去
     
     - parameter registration_id: 机器节点的编号
     - parameter seat:            位置信息
     - parameter successHandle:   成功回调
     - parameter errorHandler:    错误回调
     */
    static func goSeat(registration_id:String,seat:SeatData,func successHandle:()->Void,func errorHandler:(error:BaseError?) ->Void)->Void{
        let path = String(format: "/v0.1/endpoints/%@/robot/patrolpath/", registration_id)
        let dict = ["pathAction":7,"nPathID":0,"nPathType":3,"nSpeedLevel":2,"bEndMsg":1,"node":[["x":(seat.x*1000),"y":(seat.y*1000),"nNodeIndex":1,"eAction":3,"nActionVal":(seat.angle/45),"nAnimateId":0,"nVoiceId":0,"nLightId":0,"nVideoId":0]],"nIndex":0]
        request(.POST, path: path, paramsdict: dict, serverPort: nil, func: { (result:NSDictionary?) in
            //************** 不用主动设置所送餐号 **************//
            //let robotInfo:RotbotInfo = RotbotInfoManager.sharedInstance.robotWithEndpointId(registration_id)
            //robotInfo.tableId = seat.tag
            successHandle()
        }) { (error) in
            errorHandler(error: error)
        }
    }
    
    /**
     判断是否可以执行送餐指令
     
     - parameter registration_id: 机器节点的编号
     
     - returns: (是否可以执行送餐指令，相关提示信息)
     */
    static func canGoSeat(registration_id:String)->(canGo:Bool,msg:String){
        let robotInfo:RotbotInfo = RotbotInfoManager.sharedInstance.robotWithEndpointId(registration_id)
        if !robotInfo.errorDetail.isEmpty {
            return (false,robotInfo.errorDetail)
        }
        if robotInfo.status == ROBOT_STATUS.MOVE_LEVETRACK {
            return (false,"脱离磁道,请启用手动控制")
        }
        if robotInfo.status == ROBOT_STATUS.MOVE_MEAL {
            return (false,"正在送餐，请稍候")
        }
        if robotInfo.status == ROBOT_STATUS.MOVE_MEALSTOP {
            return (false,"正在送餐，请稍候")
        }
        if robotInfo.status == ROBOT_STATUS.MOVE_MEALARRIVE {
            return (false,"正在送餐，请稍候")
        }
        if robotInfo.status == ROBOT_STATUS.MOVE_GOBACK {
            if(robotInfo.power <= 20){
                return (false,"电量不足，正在前往充电，请稍候")
            }else{
                RobotAPI.toGetMeals(registration_id)
                return (false,"正在返回取餐点，请稍候")
            }
        }
        if robotInfo.status == ROBOT_STATUS.MOVE_TOCHARGE {
            if(robotInfo.power <= 20){
                return (false,"正在充电，请稍候")
            }
            //ToDo: 发送就位指令
            RobotAPI.toGetMeals(registration_id)
            return (false,"正在返回取餐点，请稍候")
        }
        if robotInfo.status == ROBOT_STATUS.MOVE_CHARGING {
            if(robotInfo.power <= 20){
                return (false,"正在充电，请稍候")
            }
            //ToDo: 发送就位指令
            RobotAPI.toGetMeals(registration_id)
            return (false,"正在返回取餐点，请稍候")
        }
        if robotInfo.status == ROBOT_STATUS.MOVE_CHARGING {
            if(robotInfo.power <= 20){
                return (false,"正在充电，请稍候")
            }
        }
        if robotInfo.status == ROBOT_STATUS.MOVE_WAITREADY {
            //ToDo: 发送就位指令
            return (false,"请放入咖啡")
        }
        if robotInfo.status == ROBOT_STATUS.MOVE_WAITBEGINMEAL {
            return (true,"")
        }
        RobotAPI.toGetMeals(registration_id)
        //ToDo: 发送就位指令
        return (false,"机器人前往取餐，请稍候")
    }
    
    /**
     获取机器人当前的rfid标答
     
     - parameter registration_id: 编号
     - parameter successHand:     成功回调
     - parameter errorHandler:    错误回调
     */
    static func getRobotposLable(registration_id:String,func successHand:(posLable:Int)->Void,func errorHandler:(error:BaseError?) -> Void) -> Void{
        let path = String(format: "/v0.1/endpoints/%@/robot/robotposlabel/", registration_id)
        let params = ["posAction":0,"posType":0]
        request(.POST, path: path, paramsdict: params, serverPort: nil, func: { (result:NSDictionary?) in
            if nil != result{
                let message:NSString? = result!["message"] as? NSString
                if nil != message{
                    let messageJson = JSON.parse(message! as String)
                    let array:Array<JSON> = messageJson.arrayValue
                    if array.count > 0{
                        let messageDict = array[0]
                        let infodict:NSDictionary? = messageDict["info"].dictionaryObject
                        if nil != infodict{
                            let posLable:NSNumber? = infodict!["posLabel"] as? NSNumber
                            if nil != posLable{
                                let robotInfo = RotbotInfoManager.sharedInstance.robotWithEndpointId(registration_id)
                                robotInfo.posLable = posLable!.integerValue
                                successHand(posLable:posLable!.integerValue)
                                return
                            }
                        }
                    }
                }
            }
            successHand(posLable:-1)
        }) { (error) in
            errorHandler(error: error)
        }
    }
    
    /**
     获取机器人正在送菜的桌号
     
     - parameter registration_id: 编号
     - parameter successHand:     成功回调
     - parameter errorHandler:    错误回调
     */
    static func getSeatTaskID(registration_id:String,func successHand:(tableId:Int)->Void,func errorHandler:(error:BaseError?) -> Void) -> Void{
        let path = String(format: "/v0.1/endpoints/%@/robot/tableid/", registration_id)
        request(.POST, path: path, paramsdict: [:], serverPort: nil, func: { (result:NSDictionary?) in
            if nil != result{
                let message:NSString? = result!["message"] as? NSString
                if nil != message{
                    let messageJson = JSON.parse(message! as String)
                    let array:Array<JSON> = messageJson.arrayValue
                    if array.count > 0{
                        let messageDict = array[0]
                        let infodict:NSDictionary? = messageDict["info"].dictionaryObject
                        if nil != infodict{
                            let tableId:NSNumber? = infodict!["nTableId"] as? NSNumber
                            if nil != tableId{
                                let robotInfo = RotbotInfoManager.sharedInstance.robotWithEndpointId(registration_id)
                                robotInfo.tableId = tableId!.integerValue
                                successHand(tableId: tableId!.integerValue)
                                return
                            }
                        }
                    }
                }
            }
            successHand(tableId: -1)
        }) { (error) in
            errorHandler(error: error)
        }

    }
    
    /**
     获取是否有通知
     
     - parameter registration_id: 编号
     - parameter successHand:     成功回调
     - parameter errorHandler:    失败回调
     */
    static func getNoticeID(registration_id:String,func successHand:(noticeId:Int)->Void,func errorHandler:(error:BaseError?) -> Void) -> Void{
        let path = String(format: "/v0.1/endpoints/%@/robot/notice/", registration_id)
        request(.POST, path: path, paramsdict: [:], serverPort: nil, func: { (result:NSDictionary?) in
            if nil != result{
                let message:NSString? = result!["message"] as? NSString
                if nil != message{
                    let messageJson = JSON.parse(message! as String)
                    let array:Array<JSON> = messageJson.arrayValue
                    if array.count > 0{
                        let messageDict = array[0]
                        let infodict:NSDictionary? = messageDict["info"].dictionaryObject
                        if nil != infodict{
                            let noticeId:NSNumber? = infodict!["noticeId"] as? NSNumber
                            if nil != noticeId{
                                let robotInfo = RotbotInfoManager.sharedInstance.robotWithEndpointId(registration_id)
                                robotInfo.noticeID = noticeId!.integerValue
                                successHand(noticeId: noticeId!.integerValue)
                                return
                            }
                        }
                    }
                }
            }
            successHand(noticeId: -1)
        }) { (error) in
            errorHandler(error: error)
        }
        
    }
    
    
    /**
     获取机器人是否正旋转
     
     - parameter registration_id: 编号
     - parameter successHand:     成功回调
     - parameter errorHandler:    错误回调
     */
    static func getSubStatus(registration_id:String,func successHand:(substatus:Int)->Void,func errorHandler:(error:BaseError?) -> Void) -> Void{
        let path = String(format: "/v0.1/endpoints/%@/robot/substatus/", registration_id)
        request(.POST, path: path, paramsdict: [:], serverPort: nil, func: { (result:NSDictionary?) in
            if nil != result{
                let message:NSString? = result!["message"] as? NSString
                if nil != message{
                    let messageJson = JSON.parse(message! as String)
                    let array:Array<JSON> = messageJson.arrayValue
                    if array.count > 0{
                        let messageDict = array[0]
                        let infodict:NSDictionary? = messageDict["info"].dictionaryObject
                        if nil != infodict{
                            let substatus:NSNumber? = infodict!["substatus"] as? NSNumber
                            if nil != substatus{
                                let robotInfo = RotbotInfoManager.sharedInstance.robotWithEndpointId(registration_id)
                                robotInfo.substatus = substatus!.integerValue
                                successHand(substatus: substatus!.integerValue)
                                return
                            }
                        }
                    }
                }
            }
            successHand(substatus: -1)
        }) { (error) in
            errorHandler(error: error)
        }
        
    }
    
    /**
     发送指令
     
     - parameter registration_id: 机器节点的编号
     - parameter cmd:             位置信息
     - parameter successHandle:   成功回调
     - parameter errorHandler:    错误回调
     */
    static func sendCMD(registration_id:String,cmd:MOVE_CTRL_ACTION,func successHandle:()->Void,func errorHandler:(error:BaseError?) ->Void)->Void{
        let path = String(format: "/v0.1/endpoints/%@/robot/movecontrol/", registration_id)
        let dict = ["ctrlAction":cmd.rawValue]
        request(.POST, path: path, paramsdict: dict, serverPort: nil, func: { (result:NSDictionary?) in
            successHandle()
        }) { (error) in
            errorHandler(error: error)
        }
    }
    
    /**
     获取MQTT的客户端ID
     
     - parameter successHandle: 成功回调
     - parameter errorHandler:  错误回调
     */
    static func getMQTTClient(func successHandle:(result:MQTTClientIDResult)->Void,func errorHandler:(error:BaseError?) ->Void)->Void{
        let path = "/v0.1/mqtt/client_id"
        request(.GET, path: path, func: { (result:MQTTClientIDResult?) in
            successHandle(result: result!)
        }) { (error) in
            errorHandler(error: error)
        }
    }
    
    /**
     控制机器人的方向
     
     - parameter registration_id: 机器人的id
     - parameter dirction:        方向
     */
    static func ctrolDirection(endpoint_id:String,dirction:MOVE_DIRCTION){
        let topic = String(format: "/Robot/%@/move/RockerCtrl", endpoint_id)
        let sendData =  RockerCtrlCMD()
        switch dirction {
        case .MOVE_DIRCTION_FONT:
            sendData.lineSpd = 1
            sendData.angSpd = 0
            break
        case .MOVE_DIRCTION_BOTTOM:
            sendData.lineSpd = -1
            sendData.angSpd = 0
            break
        case .MOVE_DIRCTION_LEFT:
            sendData.lineSpd = 0
            sendData.angSpd = -1
            break
        case .MOVE_DIRCTION_RIGHT:
            sendData.lineSpd = 0
            sendData.angSpd = 1
            break
        case .MOVE_DIRCTION_STOP:
            sendData.lineSpd = 0
            sendData.angSpd = 0
            break
        }
        MQTTManager.sharedInstance.sendTopic(topic, data: sendData)
    }
    
    /**
     添加机器人状态监听
     - parameter registration_id: 编号
     */
    static func addStatusListener(endpoint_id:String){
        let topic = String(format: "/Robot/%@/info/Status", endpoint_id)
        TopicTools.pushNotification(topic, endpoint_id: endpoint_id)
        MQTTManager.sharedInstance.listenTopic(topic);
        NSNotificationCenter.defaultCenter().addObserver(RobotAPI.notificationHandler, selector: #selector(TopicNotificationHandler.statusHandler(_:)), name: topic, object: nil)
    }
    
    /**
     添加机器人电量监听
     - parameter registration_id: 编号
     */
    static func addPowerListener(endpoint_id:String){
        let topic = String(format: "/Robot/%@/info/BatteryInfo", endpoint_id)
        TopicTools.pushNotification(topic, endpoint_id: endpoint_id)
        MQTTManager.sharedInstance.listenTopic(topic);
        NSNotificationCenter.defaultCenter().addObserver(RobotAPI.notificationHandler, selector: #selector(TopicNotificationHandler.powerHandler(_:)), name: topic, object: nil)
    }
    
    /**
     添加机器人位置监听
     - parameter registration_id: 编号
     */
    static func addPositionListener(endpoint_id:String){
        let topic = String(format: "/Robot/%@/info/RobotPos", endpoint_id)
        TopicTools.pushNotification(topic, endpoint_id: endpoint_id)
        MQTTManager.sharedInstance.listenTopic(topic);
        NSNotificationCenter.defaultCenter().addObserver(RobotAPI.notificationHandler, selector: #selector(TopicNotificationHandler.positionHandler(_:)), name: topic, object: nil)
    }
    
    
    /**
     添加机器人送餐经过点监听
     - parameter registration_id: 编号
     */
    static func addLeaveSeatPointListener(endpoint_id:String){
        let topic = String(format: "/Robot/%@/info/RobotPosLabel", endpoint_id)
        TopicTools.pushNotification(topic, endpoint_id: endpoint_id)
        MQTTManager.sharedInstance.listenTopic(topic);
        NSNotificationCenter.defaultCenter().addObserver(RobotAPI.notificationHandler, selector: #selector(TopicNotificationHandler.positionLableHandler(_:)), name: topic, object: nil)
    }
    
    /**
     添加机器人的在线和断线监听
     
     - parameter registration_id: 编号
     */
    static func addOnlineListener(endpoint_id:String){
        let topic = String(format: "/endpoints/%@/alive", endpoint_id)
        TopicTools.pushNotification(topic, endpoint_id: endpoint_id)
        MQTTManager.sharedInstance.listenTopic(topic);
        NSNotificationCenter.defaultCenter().addObserver(RobotAPI.notificationHandler, selector: #selector(TopicNotificationHandler.onlineHandler(_:)), name: topic, object: nil)
    }
    
    /**
     添加机器人的在线和断线监听
     
     - parameter registration_id: 编号
     */
    static func addDeviceStatusListener(endpoint_id:String){
        let topic = String(format: "/Robot/%@/info/devicestatus", endpoint_id)
        TopicTools.pushNotification(topic, endpoint_id: endpoint_id)
        MQTTManager.sharedInstance.listenTopic(topic);
        NSNotificationCenter.defaultCenter().addObserver(RobotAPI.notificationHandler, selector: #selector(TopicNotificationHandler.deviceStatusHandler(_:)), name: topic, object: nil)
    }
    
    /**
     添加机器人送餐餐号
     
     - parameter registration_id: 编号
     */
    static func addTableIdListener(endpoint_id:String){
        let topic = String(format: "/Robot/%@/info/tableid", endpoint_id)
        TopicTools.pushNotification(topic, endpoint_id: endpoint_id)
        MQTTManager.sharedInstance.listenTopic(topic);
        NSNotificationCenter.defaultCenter().addObserver(RobotAPI.notificationHandler, selector: #selector(TopicNotificationHandler.tableIdHandler(_:)), name: topic, object: nil)
    }
    
    /**
     添加机器人旋转监听
     
     - parameter registration_id: 编号
     */
    static func addSubstatusListener(endpoint_id:String){
        let topic = String(format: "/Robot/%@/info/substatus", endpoint_id)
        TopicTools.pushNotification(topic, endpoint_id: endpoint_id)
        MQTTManager.sharedInstance.listenTopic(topic);
        NSNotificationCenter.defaultCenter().addObserver(RobotAPI.notificationHandler, selector: #selector(TopicNotificationHandler.substatusHandler(_:)), name: topic, object: nil)
    }
    
    
    /**
     机器人取餐
     
     - parameter endpoint_id: 编
     */
    static func toGetMeals(endpoint_id:String){
        
        RobotAPI.sendCMD(endpoint_id, cmd: MOVE_CTRL_ACTION.ACT_MOVE_CTRL_GET_MEALS, func: {
            
            }, func: { (error) in
                
        })
        // ******** 去掉停止指令 ********//
//        RobotAPI.sendCMD(endpoint_id, cmd: MOVE_CTRL_ACTION.ACT_MOVE_CTRL_STOP_SLOW, func: {
//           
//            }) { (error) in
//                
//        }
    }
    
    /// 消息分发
    class TopicNotificationHandler: NSObject {
        @objc func statusHandler(notification: NSNotification){
            let info = notification.userInfo!
            let status:NSNumber = (info["status"] as? NSNumber)!
            let preStatus:NSNumber? = info["preStatus"] as? NSNumber
            let endpoint_id = TopicTools.getEndpoint_id(notification.name)
            if nil == endpoint_id {
                return
            }
            let robotInfo = RotbotInfoManager.sharedInstance.robotWithEndpointId(endpoint_id!)
            switch status.integerValue {
            case 1:
                robotInfo.status = ROBOT_STATUS.MOVE_AUTO
                break
            case 2:
                robotInfo.status = ROBOT_STATUS.MOVE_ROCKER
                break
            case 3:
                robotInfo.status = ROBOT_STATUS.MOVE_TASK
                break
            case 4:
                robotInfo.status = ROBOT_STATUS.MOVE_WANDER
                break
            case 5:
                robotInfo.status = ROBOT_STATUS.MOVE_FREE
                break
            case 6:
                robotInfo.status = ROBOT_STATUS.MOVE_TOCHARGE
                break
            case 7:
                robotInfo.status = ROBOT_STATUS.MOVE_CHARGING
                break
            case 8:
                robotInfo.status = ROBOT_STATUS.MOVE_MEAL
                break
            case 9:
                robotInfo.status = ROBOT_STATUS.MOVE_TIMEOUT
                break
            case 10:
                robotInfo.status = ROBOT_STATUS.MOVE_LEVETRACK
                break
            case 11:
                robotInfo.status = ROBOT_STATUS.MOVE_SUSPENDED
                break
            case 8001:
                robotInfo.status = ROBOT_STATUS.MOVE_WAITREADY
                break
            case 8002:
                robotInfo.status = ROBOT_STATUS.MOVE_WAITBEGINMEAL
                break
            case 8004:
                robotInfo.status = ROBOT_STATUS.MOVE_MEALARRIVE
                break
            case 8005:
                robotInfo.status = ROBOT_STATUS.MOVE_GOBACK
                break
            case 8006:
                robotInfo.status = ROBOT_STATUS.MOVE_MEALSTOP
                break
            default:
                break
            }
            
            
            switch preStatus!.integerValue {
            case 1:
                robotInfo.preStatus = ROBOT_STATUS.MOVE_AUTO
                break
            case 2:
                robotInfo.preStatus = ROBOT_STATUS.MOVE_ROCKER
                break
            case 3:
                robotInfo.preStatus = ROBOT_STATUS.MOVE_TASK
                break
            case 4:
                robotInfo.preStatus = ROBOT_STATUS.MOVE_WANDER
                break
            case 5:
                robotInfo.preStatus = ROBOT_STATUS.MOVE_FREE
                break
            case 6:
                robotInfo.preStatus = ROBOT_STATUS.MOVE_TOCHARGE
                break
            case 7:
                robotInfo.preStatus = ROBOT_STATUS.MOVE_CHARGING
                break
            case 8:
                robotInfo.preStatus = ROBOT_STATUS.MOVE_MEAL
                break
            case 9:
                robotInfo.preStatus = ROBOT_STATUS.MOVE_TIMEOUT
                break
            case 10:
                robotInfo.preStatus = ROBOT_STATUS.MOVE_LEVETRACK
                break
            case 11:
                robotInfo.preStatus = ROBOT_STATUS.MOVE_SUSPENDED
                break
            case 8001:
                robotInfo.preStatus = ROBOT_STATUS.MOVE_WAITREADY
                break
            case 8002:
                robotInfo.preStatus = ROBOT_STATUS.MOVE_WAITBEGINMEAL
                break
            case 8004:
                robotInfo.preStatus = ROBOT_STATUS.MOVE_MEALARRIVE
                break
            case 8005:
                robotInfo.preStatus = ROBOT_STATUS.MOVE_GOBACK
                break
            case 8006:
                robotInfo.preStatus = ROBOT_STATUS.MOVE_MEALSTOP
                break
            default:
                break
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName(RobotNotification.STATUS_CHANGE, object: nil,userInfo: ["endpoint_id":endpoint_id!])
        }
        
        @objc func powerHandler(notification: NSNotification){
            let info = notification.userInfo!
            let percent:NSNumber = (info["percent"] as? NSNumber)!
            let endpoint_id = TopicTools.getEndpoint_id(notification.name)
            if nil == endpoint_id {
                return
            }
            let robotInfo = RotbotInfoManager.sharedInstance.robotWithEndpointId(endpoint_id!)
            robotInfo.power = percent.integerValue
            NSNotificationCenter.defaultCenter().postNotificationName(RobotNotification.POWER_CHANGE, object: nil,userInfo: ["endpoint_id":endpoint_id!])
        }
        
        @objc func positionHandler(notification: NSNotification){
            let info = notification.userInfo!
            let cellX:NSNumber = (info["cellX"] as? NSNumber)!
            let cellY:NSNumber = (info["cellY"] as? NSNumber)!
            let angle:NSNumber = (info["angle"] as? NSNumber)!
            let endpoint_id = TopicTools.getEndpoint_id(notification.name)
            if nil == endpoint_id {
                return
            }
            let robotInfo = RotbotInfoManager.sharedInstance.robotWithEndpointId(endpoint_id!)
            robotInfo.local_x = cellX.integerValue
            robotInfo.local_y = cellY.integerValue
            robotInfo.angle = angle.integerValue
            NSNotificationCenter.defaultCenter().postNotificationName(RobotNotification.LOCATION_CHANGE, object: nil,userInfo: ["endpoint_id":endpoint_id!])
        }
        
        @objc func positionLableHandler(notification: NSNotification){
            print(notification.name)
            let endpoint_id = TopicTools.getEndpoint_id(notification.name)
            if nil != endpoint_id {
                let userinfo = notification.userInfo
                if nil != userinfo {
                    let posLable:NSNumber? = (userinfo!["posLabel"] as? NSNumber)
                    if nil != posLable {
                        let robotInfo = RotbotInfoManager.sharedInstance.robotWithEndpointId(endpoint_id!)
                        robotInfo.posLable = posLable!.integerValue
                        NSNotificationCenter.defaultCenter().postNotificationName(RobotNotification.POSLABLE_CHANGE, object: nil,userInfo: ["endpoint_id":endpoint_id!,"posLabel":posLable!])
                    }
                }
            }
        }
        
        @objc func onlineHandler(notification: NSNotification){
            let info = notification.userInfo!
            let online:String = info["alive"] as! String
            let endpoint_id:String = info["endpoint_id"] as! String
            let robotInfo = RotbotInfoManager.sharedInstance.robotWithEndpointId(endpoint_id)
            switch online {
            case "T":
                robotInfo.online = true
                break
            case "F":
                robotInfo.online = false
                break
            default:
                break
            }
            NSNotificationCenter.defaultCenter().postNotificationName(RobotNotification.ONLINE_CHANGE, object: nil,userInfo: ["endpoint_id":endpoint_id])
        }
        
        @objc func deviceStatusHandler(notification: NSNotification){
            let info = notification.userInfo!
            let endpoint_id = TopicTools.getEndpoint_id(notification.name)!
            let importantDevice:NSArray = info["importantDevice"] as! NSArray
            if importantDevice.count>0 {
                let dict:NSDictionary = importantDevice[0] as! NSDictionary
                let statusType:NSNumber = dict["statusType"] as! NSNumber
                let robotInfo = RotbotInfoManager.sharedInstance.robotWithEndpointId(endpoint_id)
                if statusType.integerValue == 2 {
                    robotInfo.errorDetail = "未启动"
                }
                if statusType.integerValue == 3 {
                    let errordetail:String = dict["errordetail"] as! String
                    robotInfo.errorDetail = errordetail
                }
                if statusType.integerValue < 2 {
                    robotInfo.errorDetail = ""
                }
                NSNotificationCenter.defaultCenter().postNotificationName(RobotNotification.DEVICE_STATUS, object: nil,userInfo: ["endpoint_id":endpoint_id])
            }
        }
        
        @objc func tableIdHandler(notification: NSNotification){
            let endpoint_id = TopicTools.getEndpoint_id(notification.name)
            if nil != endpoint_id {
                let userinfo = notification.userInfo
                if nil != userinfo {
                    let nTableId:NSNumber? = (userinfo!["nTableId"] as? NSNumber)
                    if nil != nTableId {
                        let robotInfo = RotbotInfoManager.sharedInstance.robotWithEndpointId(endpoint_id!)
                        robotInfo.tableId = nTableId!.integerValue
                        NSNotificationCenter.defaultCenter().postNotificationName(RobotNotification.TABLEID_CHANGE, object: nil,userInfo: ["endpoint_id":endpoint_id!,"tableid":nTableId!])
                    }
                }
            }
        }
        
        
        @objc func substatusHandler(notification: NSNotification){
            let endpoint_id = TopicTools.getEndpoint_id(notification.name)
            if nil != endpoint_id {
                let userinfo = notification.userInfo
                if nil != userinfo {
                    let substatus:NSNumber? = (userinfo!["substatus"] as? NSNumber)
                    if nil != substatus {
                        let robotInfo = RotbotInfoManager.sharedInstance.robotWithEndpointId(endpoint_id!)
                        robotInfo.substatus = substatus!.integerValue
                        NSNotificationCenter.defaultCenter().postNotificationName(RobotNotification.SUBSTATUS_CHANGE, object: nil,userInfo: ["endpoint_id":endpoint_id!,"tableid":substatus!])
                    }
                }
            }
        }
        
        
        
        
        @objc func noticeHandler(notification: NSNotification){
            let endpoint_id = TopicTools.getEndpoint_id(notification.name)
            if nil != endpoint_id {
                let userinfo = notification.userInfo
                if nil != userinfo {
                    let nNoticeId:NSNumber? = (userinfo!["nNoticeId"] as? NSNumber)
                    if nil != nNoticeId {
                        let robotInfo = RotbotInfoManager.sharedInstance.robotWithEndpointId(endpoint_id!)
                        robotInfo.noticeID = nNoticeId!.integerValue
                        NSNotificationCenter.defaultCenter().postNotificationName(RobotNotification.NOTICE_HAPPEN, object: nil,userInfo: ["endpoint_id":endpoint_id!,"noticeId":nNoticeId!])
                    }
                }
            }
        }
        
    }
    
    
}

