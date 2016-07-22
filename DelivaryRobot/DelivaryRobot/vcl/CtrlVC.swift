//
//  CtrlVC.swift
//  DelivaryRobot
//
//  Created by ilikeido on 16/7/14.
//  Copyright © 2016年 ilikeido. All rights reserved.
//

import UIKit
import Foundation
import SCLAlertView

class CtrlVC: UIViewController {
    
    var timer:NSTimer? = nil
    
    var dirction:MOVE_DIRCTION = MOVE_DIRCTION.MOVE_DIRCTION_LEFT
    
    var endpoints = Array<EndPoint>()
    
    @IBOutlet weak var lb_electricity: UILabel!
    
    @IBOutlet weak var lb_status: UILabel!
    
    @IBOutlet weak var lb_route: UILabel!
    
    @IBOutlet weak var btn_pause: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CtrlVC.updateStatus), name: RobotNotification.STATUS_CHANGE, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CtrlVC.updateElectricity), name: RobotNotification.POWER_CHANGE, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CtrlVC.updateStatus), name: RobotNotification.ONLINE_CHANGE, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CtrlVC.updatePosLable), name: RobotNotification.POSLABLE_CHANGE, object: nil)
        
        self.clearTagStatus()
        self.updateUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


extension CtrlVC{
    @objc func updateStatus(notification: NSNotification){
        let info = notification.userInfo!
        let endpoint_id:String = info["endpoint_id"] as! String
        if endpoint_id == RotbotInfoManager.sharedInstance.current_endpoint_id {
            let robotInfo = RotbotInfoManager.sharedInstance.robotWithEndpointId(endpoint_id)
            let online = robotInfo.online ? "在线":"断线"
            self.lb_status.text = "状态:" + robotInfo.statusName() + "(" + online + ")"
        }
    }
    
    @objc func updateElectricity(notification: NSNotification){
        let info = notification.userInfo!
        let endpoint_id:String = info["endpoint_id"] as! String
        if endpoint_id == RotbotInfoManager.sharedInstance.current_endpoint_id {
            let robotInfo = RotbotInfoManager.sharedInstance.robotWithEndpointId(endpoint_id)
            self.lb_electricity.text = "电量：" + String(robotInfo.power) + "/100"
        }
    }
    
    @objc func updatePosLable(notification: NSNotification){
        let info = notification.userInfo!
        print(info)
        self.clearTagStatus()
        let endpoint_id:String = info["endpoint_id"] as! String
        if endpoint_id == RotbotInfoManager.sharedInstance.current_endpoint_id {
            let posLable:NSNumber = info["posLabel"] as! NSNumber
            let tag = self.getTagFormLable(posLable.integerValue)
            self.setTagHighter(tag)
        }
    }
    
    func updateUI(){
        if nil != RotbotInfoManager.sharedInstance.current_endpoint_id {
            let robotInfo = RotbotInfoManager.sharedInstance.robotWithEndpointId(RotbotInfoManager.sharedInstance.current_endpoint_id!)
            let online = robotInfo.online ? "在线":"断线"
            self.lb_electricity.text = "电量：" + String(robotInfo.power)
            self.lb_status.text = "状态:" + robotInfo.statusName() + "(" + online + ")"
        }
        
    }

    
}


extension CtrlVC{
    
    @IBAction func downAction(sender: AnyObject) {
        let btn:UIButton = sender as! UIButton
        switch btn.tag {
        case 1:
            dirction = MOVE_DIRCTION.MOVE_DIRCTION_FONT
        case 2:
            dirction = MOVE_DIRCTION.MOVE_DIRCTION_LEFT
        case 3:
            dirction = MOVE_DIRCTION.MOVE_DIRCTION_BOTTOM
        case 4:
            dirction = MOVE_DIRCTION.MOVE_DIRCTION_RIGHT
        default:
            break
        }
        self.beginAction()
    }
    
    
    @IBAction func upAction(sender: AnyObject) {
        dirction = MOVE_DIRCTION.MOVE_DIRCTION_STOP
        self.endDirctionCMD()
    }
    
    @IBAction func pauseAction(sender: AnyObject) {
        if btn_pause.tag == 0 {
            self.sendPauseAction()
        }else{
            self.sendContinueAction()
        }
    }
    
    @IBAction func stopAction(sender: AnyObject) {
        self.sendStopAction()
    }
    
    @IBAction func chargeAction(sender: AnyObject) {
        self.sendChargeAction()
    }
    
    func beginAction(){
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1,
                                                            target:self,selector:#selector(CtrlVC.sendDirctionCMD),
                                                            userInfo:nil,repeats:true)
        self.timer?.fire()
    }
    
    func endDirctionCMD(){
        timer?.invalidate()
        if (RotbotInfoManager.sharedInstance.current_endpoint_id != nil) {
            RobotAPI.ctrolDirection(RotbotInfoManager.sharedInstance.current_endpoint_id!, dirction: MOVE_DIRCTION.MOVE_DIRCTION_STOP)
        }
    }
    
    func sendDirctionCMD(){
        print("!!!!")
        if (RotbotInfoManager.sharedInstance.current_endpoint_id != nil) {
            RobotAPI.ctrolDirection(RotbotInfoManager.sharedInstance.current_endpoint_id!, dirction: dirction)
        }
    }
    
    func sendPauseAction(){
        weak var weakself = self
        RobotAPI.sendCMD(RotbotInfoManager.sharedInstance.current_endpoint_id!, cmd: MOVE_CTRL_ACTION.ACT_AUTOMOVE_SUSPEND, func: {
            weakself!.btn_pause.tag = 1
            weakself!.btn_pause.setTitle("继续任务", forState:UIControlState.Normal)
        }) { (error) in
            
        }
    }
    
    func sendStopAction(){
        weak var weakself = self
        RobotAPI.sendCMD(RotbotInfoManager.sharedInstance.current_endpoint_id!, cmd: MOVE_CTRL_ACTION.ACT_MOVE_CTRL_STOP_SLOW, func: {
            weakself!.btn_pause.enabled = false
            weakself!.btn_pause.setTitle("已无任务", forState:UIControlState.Normal)
        }) { (error) in
            
        }
    }
    
    func sendContinueAction(){
        weak var weakself = self
        RobotAPI.sendCMD(RotbotInfoManager.sharedInstance.current_endpoint_id!, cmd: MOVE_CTRL_ACTION.ACT_FINDPATH_RESUME, func: {
            weakself!.btn_pause.tag = 0
            weakself!.btn_pause.setTitle("暂停任务", forState:UIControlState.Normal)
            }) { (error) in
        }
    }
    
    
    func sendChargeAction(){
        RobotAPI.sendCMD(RotbotInfoManager.sharedInstance.current_endpoint_id!, cmd: MOVE_CTRL_ACTION.ACT_MOVE_CTRL_CHARGE, func: {
            
        }) { (error) in
            
        }
    }
    
}

extension CtrlVC{

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.endpoints.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("CELL")
        if nil == cell {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "CELL")
        }
        let endpoint = self.endpoints[indexPath.row]
        cell?.textLabel?.text = endpoint.endpoin_name
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let endpoint = self.endpoints[indexPath.row]
        RotbotInfoManager.sharedInstance.current_endpoint_id = endpoint.registration_id
        print(endpoint.endpoin_name + "_" + endpoint.registration_id)
        let robotInfo = RotbotInfoManager.sharedInstance.robotWithEndpointId(endpoint.registration_id)
        robotInfo.clearStatus()
        RobotAPI.loginRobot(endpoint.registration_id, func: {
            print("登录机器成功")
            RobotAPI.addStatusListener(RotbotInfoManager.sharedInstance.current_endpoint_id!)
            RobotAPI.addOnlineListener(RotbotInfoManager.sharedInstance.current_endpoint_id!)
            RobotAPI.addPowerListener(RotbotInfoManager.sharedInstance.current_endpoint_id!)
            RotbotInfoManager.sharedInstance.current_endpoint_id = endpoint.registration_id
            }) { (error) in
                SCLAlertView().showError("提示", subTitle: (error?.message)!)
        }
    }
    
}

extension CtrlVC{
    
    func getTagLables() -> [UILabel]{
        let mapview = self.view.viewWithTag(110)
        let tagView = mapview?.viewWithTag(111)
        let tempviews = tagView?.subviews
        var results = [UILabel]()
        for view in tempviews! {
            let lable = view as! UILabel
            results.append(lable)
        }
        return results
    }
    
    func clearTagStatus() -> Void{
        let lables = getTagLables()
        
        for lable in lables {
            lable.backgroundColor = UIColor.whiteColor()
            lable.textColor = UIColor.darkTextColor()
        }
    }
    
    func getTagFormLable(lable:Int) -> Int{
        switch lable {
        case 0:
            return 0
        case 1,2:
            return 1
        case 3,4:
            return 2
        case 20,21,22:
            return 3
        case 23:
            return 4
        case 5,6,7:
            return 5
        case 8:
            return 6
        case 9,10:
            return 7
        case 11,12:
            return 8
        case 13,14:
            return 9
        case 15,16,17:
            return 10
        case 18:
            return 11
        case 19:
            return 12
        default:
            return -1
        }
    }
    
    func setTagHighter(tag:Int) -> Void{
        let lables = getTagLables()
        
        for lable in lables {
            if lable.tag == tag {
                lable.backgroundColor = UIColor.blueColor()
            }
        }
    }
    
    
}

