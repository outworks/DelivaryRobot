//
//  MQTTManager.swift
//  DelivaryRobot
//
//  Created by ilikeido on 16/7/12.
//  Copyright © 2016年 ilikeido. All rights reserved.
//

import Foundation
import CocoaMQTT
import EVReflection
import SwiftyJSON

class MQTTManager :CocoaMQTTDelegate {
    
    let DEFIND_MQTTHOST = "172.24.132.20"
//    let DEFIND_MQTTHOST = "172.24.132.20"
    
    let DEFIND_MQTTPORT: UInt16 = 1883
    
    var mqtt :CocoaMQTT
    
    var clientIdPid = ""
    
    class var sharedInstance : MQTTManager {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : MQTTManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = MQTTManager()
        }
        return Static.instance!
    }
    
    init(){
        mqtt = CocoaMQTT(clientId: clientIdPid, host: DEFIND_MQTTHOST, port: DEFIND_MQTTPORT)
        mqtt.keepAlive = UInt16.max
        mqtt.delegate = self
    }
    
    func connect(clientId:String){
        self.clientIdPid = clientId
        mqtt.connect()
//        dispatch_main()
    }
    
    func connect()->Bool{
        mqtt.clientId = self.clientIdPid
        mqtt.delegate = self
        mqtt.secureMQTT = true
        return mqtt.connect()
    }

    func sendTopic(topic:String,data:EVObject?){
        var jsonString = data?.toJsonString()
        jsonString = jsonString?.stringByReplacingOccurrencesOfString("\n", withString: "")
        mqtt.publish(topic, withString: jsonString!);
    }
    
    func sendTopic(topic:String,data:NSDictionary?){
        let jsonData = try! NSJSONSerialization.dataWithJSONObject(data!, options: NSJSONWritingOptions.PrettyPrinted)
        let jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as? String
        mqtt.publish(topic, withString: jsonString!);
    }
    
    func listenTopic(topic:String){
        mqtt.subscribe(topic, qos:.QOS1 )
        print("subscribe" + topic)
    }
    
    func unListenTopic(topic:String){
        mqtt.unsubscribe(topic)
    }
    
    //CocoaMQTTDelegate
    func mqtt(mqtt: CocoaMQTT, didConnect host: String, port: Int){
//        mqtt.ping()
        NSNotificationCenter.defaultCenter().postNotificationName(RobotNotification.MQTTRECONNETED, object: nil)
    }
    
    func mqtt(mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck){
        
    }
    
    func mqtt(mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16){
        
    }
    
    func mqtt(mqtt: CocoaMQTT, didPublishAck id: UInt16){
        
    }
    
    func mqtt(mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ){
        let topic = message.topic
        print(message.string)
        let messageString = message.string
        let jsonDict = JSON.parse(messageString!)
        print(jsonDict)
        let userInfo = jsonDict.dictionaryObject
        print(userInfo)
        NSNotificationCenter.defaultCenter().postNotificationName(topic, object: nil, userInfo: userInfo)
    }
    
    func mqtt(mqtt: CocoaMQTT, didSubscribeTopic topic: String){
        print("%@ subscribe success!",topic)
    }
    
    func mqtt(mqtt: CocoaMQTT, didUnsubscribeTopic topic: String){
        print("%@ unsubscribe success!",topic)
    }
    
    func mqttDidPing(mqtt: CocoaMQTT){
        
    }
    
    func mqttDidReceivePong(mqtt: CocoaMQTT){
        
    }
    
    func mqttDidDisconnect(mqtt: CocoaMQTT, withError err: NSError?){
        print(err?.localizedDescription)
        MQTTManager.sharedInstance.connect("FZ2h4sz1idwY8kUUR1jxF7L")
    }
    
}