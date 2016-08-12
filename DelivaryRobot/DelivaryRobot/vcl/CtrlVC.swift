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
import AudioToolbox

class CtrlVC: UIViewController {
    
    var timer:NSTimer? = nil
    
    var dirction:MOVE_DIRCTION = MOVE_DIRCTION.MOVE_DIRCTION_LEFT
    
    var endpoints = Array<EndPoint>()
    
    var alertView:UIAlertView? = nil;
    
    var isChangle:Bool?{
        
        didSet{
            
            if self.isChangle == true {
                
                self.v_jinye.hidden = true
                self.v_changle.hidden = false
                
            }else{
                self.v_jinye.hidden = false
                self.v_changle.hidden = true
            }
            
            self.clearTagStatus()
            
        }
        
    }
    
    
    
    @IBOutlet weak var btn_pause: UIButton!
    
    @IBOutlet weak var btn_ctrl: UIButton!
    
    @IBOutlet weak var view_ctrl: UIView!
    
    /************ 长乐地图 ************/
    @IBOutlet weak var v_changle: UIView!
    
    /************ 金业地图 ************/
    @IBOutlet weak var v_jinye: UIView!
    
    /************ 长乐地图开关 **********/
    
    @IBOutlet weak var switch_map: UISwitch!
    
    @IBOutlet weak var v_info: UIView!
    
    /************ 暂停和返回视图 **********/
    @IBOutlet weak var v_stop: UIView!
    
    
    
    
    var view_status: UIView?
    var imgv_status: UIImageView?
    var lb_status: UILabel?
    
    
    
    /**************** 显示电量的背景图片 *****************/
    @IBOutlet weak var img_powerbg: UIImageView!
    /**************** 显示电量多少图片 *****************/
    @IBOutlet weak var img_powerColoer: UIImageView!
    /**************** 显示电量距离上面的layout *****************/
    @IBOutlet weak var layout_height_power: NSLayoutConstraint!
    /**************** 显示电量多少 *****************/
    @IBOutlet weak var lb_power: UILabel!
    /**************** 显示机器名字 *****************/
    @IBOutlet weak var lb_nameRobit: UILabel!
    
    /**************** 送餐按钮 *****************/
    @IBOutlet weak var btn_songcan: UIButton!
    /**************** 控制按钮 *****************/
    @IBOutlet weak var btn_kongzhi: UIButton!
    /**************** 充电按钮 *****************/
    @IBOutlet weak var btn_chongdian: UIButton!
    
    
    
    var timer_sound:NSTimer!
    var v_showSeat:SeatChooseView!
    
    var arr_alert:NSMutableArray!
    
    var power:NSNumber?{
        
        /* 属性监视器方法
         * 1.willSet 在设置新的值之前调用
         * 2.didSet  在新的值被设置之后立即调用
         */
        
        didSet{
            
            if self.power?.intValue < 30 {
                img_powerbg.image = UIImage(named:"icon_lowPower_bg_ipad")
                img_powerColoer.image = UIImage(named: "icon_lowPower_color_ipad")
                lb_power.textColor = UIColor(red: 199.0/255.0, green: 2.0/255.0, blue: 1.0/255.0, alpha: 1.0)
                
            } else{
                
                img_powerbg.image = UIImage(named:"icon_commonPower_bg_ipad")
                img_powerColoer.image = UIImage(named: "icon_common_color_ipad")
                lb_power.textColor = UIColor.blackColor()
                
            }
            
            layout_height_power.constant = CGFloat(0.1 * (self.power?.floatValue)!)
            
            lb_power.text = (self.power?.stringValue)! + "%"
            
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //*************** 添加机器状态变化通知 *********************//
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CtrlVC.statusChanged), name: RobotNotification.STATUS_CHANGE, object: nil)
        //*************** 添加机器电量通知 *********************//
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CtrlVC.updateElectricity), name: RobotNotification.POWER_CHANGE, object: nil)
        //*************** 添加机器在线或离线通知 *********************//
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CtrlVC.updateStatus), name: RobotNotification.ONLINE_CHANGE, object: nil)
        //*************** 添加机器位置通知 *********************//
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CtrlVC.updatePosLable), name: RobotNotification.POSLABLE_CHANGE, object: nil)
        //*************** 设备故障通知 *********************//
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CtrlVC.updateStatus), name: RobotNotification.DEVICE_STATUS, object: nil)
        //*************** 添加机器送餐桌号通知 *********************//
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CtrlVC.updateStatus), name: RobotNotification.TABLEID_CHANGE, object: nil)
        //*************** 添加机器信息通知 *********************//
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CtrlVC.showNotice), name: RobotNotification.NOTICE_HAPPEN, object: nil)
        //*************** 添加从后台进入前台通知，所做的操作是从新去请求下机器状态 *********************//
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CtrlVC.appBecomeActive), name: RobotNotification.APPBECOMEACTIVE, object: nil)
        self.isChangle = true
        self.arr_alert = NSMutableArray()
        self.hideDirctionView()
        self.clearTagStatus()
        self.setUpTitleView()
        self.updateUI()
        self.addBackButton(self, action: #selector(self.backAction))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


// MARK: 初始化

extension CtrlVC{
    
    // ****************** 初始化视图 ******************//
    
    func updateUI(){
        
        if nil != RotbotInfoManager.sharedInstance.current_endpoint_id {
            
            // ****************** 判断机器是否是否在线 ******************//
            let robotInfo = RotbotInfoManager.sharedInstance.robotWithEndpointId(RotbotInfoManager.sharedInstance.current_endpoint_id!)
            let online = robotInfo.online ? "在线":"断线"
            
            if robotInfo.online == false {
                
                self.backAction()
                
            }
            
            self.power = NSNumber(int:(Int32(robotInfo.power)))
            
            self.lb_status!.text = robotInfo.statusName() + "(" + online + ")"
            self.updateTitleViewFrame(self.lb_status!.text!)
            if robotInfo.statusName() == "闲置任务" || robotInfo.statusName() == "等待就位" || robotInfo.statusName() == "挂起"{
                imgv_status?.image = UIImage(named: "icon_status_idle_ipad")
            }else if robotInfo.statusName() == "脱离磁道"{
                imgv_status?.image = UIImage(named: "icon_status_abnormal_ipad")
            } else {
                imgv_status?.image = UIImage(named: "icon_status_busy_ipad")
            }
            if robotInfo.statusName() == "挂起" {
                self.lb_status!.text = "(" + robotInfo.statusName() + ")" + robotInfo.preStatusName() + "(" + online + ")"
                //self.updateTitleViewFrame(self.lb_status!.text!)
            }
            
            
            self.updateTitleViewFrame(self.lb_status!.text!)
            
            if self.isChangle == true {
                let tag = self.getChangleTagFormLable(robotInfo.posLable)
                self.setTagHighter(tag)
            }else{
                
                let tag = self.getTagFormLable(robotInfo.posLable)
                self.setTagHighter(tag)
            }
            
            self.lb_nameRobit.text = RotbotInfoManager.sharedInstance.current_endpoin_name!
            
            self.switch_map.addTarget(self, action:#selector(CtrlVC.mapChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
            
            self.switch_map.setOn(self.isChangle!, animated: false)
            
            self.v_stop.hidden = true
            
            self.showNoticeView(robotInfo.noticeID)
            
        }
        
    }
    
    //*****************  初始化titleView视图 *****************//
    
    func setUpTitleView(){
        
        view_status = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 250, height: 44))
        view_status?.backgroundColor = UIColor.clearColor()
        imgv_status = UIImageView(frame: CGRect(x: 5.0, y: 22-4.5, width: 9, height: 9))
        view_status?.addSubview(imgv_status!)
        
        lb_status = UILabel(frame: CGRect(x: 20.0, y: 0.0, width: 230, height: 44))
        lb_status?.font = UIFont.systemFontOfSize(18.0)
        lb_status?.backgroundColor = UIColor.clearColor()
        lb_status?.textAlignment = NSTextAlignment.Center
        lb_status?.textColor = UIColor.whiteColor()
        view_status?.addSubview(lb_status!)
        
        self.navigationItem.titleView = view_status
        
    }
    
}

// MARK: 返回视图初始化

extension CtrlVC{
    
    //************ 添加返回按钮 ****************//
    
    func addBackButton(target:AnyObject, action:Selector){
        
        let image :UIImage = UIImage(named: "icon_back_unsd_ipad")!
        let buttonFrame :CGRect  = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: image.size.width + 10.0, height: self.navigationController!.navigationBar.frame.size.height))
        
        let button:UIButton = UIButton(type: UIButtonType.Custom)
        button.contentMode = UIViewContentMode.ScaleAspectFit;
        button.backgroundColor = UIColor.clearColor();
        button.frame = buttonFrame;
        button.setImage(image, forState: UIControlState.Normal)
        button.addTarget(target, action: action, forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(button)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView:button)
    }
    
    //************ 添加返回按钮事件处理 ****************//
    
    func backAction(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}


// MARK: 事件通知

extension CtrlVC{
    
    
    @objc func appBecomeActive(notification: NSNotification){
        
        weak var weakself = self
        RobotAPI.loginRobot(RotbotInfoManager.sharedInstance.current_endpoint_id!, func: {
            print("登录机器成功")
            
            
            let globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
            let mainQueue = dispatch_get_main_queue()
            
            let group = dispatch_group_create()
            
            dispatch_group_async(group, globalQueue, { () -> Void in
                
                let dispatchSemaphore = dispatch_semaphore_create(0)
                
                RobotAPI.getSeatTaskID(RotbotInfoManager.sharedInstance.current_endpoint_id!, func: { (tableId) in
                    
                    dispatch_semaphore_signal(dispatchSemaphore)
                    
                    }, func: { (error) in
                        
                        dispatch_semaphore_signal(dispatchSemaphore)
                })
                
                dispatch_semaphore_wait(dispatchSemaphore, DISPATCH_TIME_FOREVER)
                
            })
            
            dispatch_group_async(group, globalQueue, { () -> Void in
                
                let dispatchSemaphore = dispatch_semaphore_create(0)
                
                RobotAPI.getNoticeID(RotbotInfoManager.sharedInstance.current_endpoint_id!, func: { (noticeId) in
                    
                    dispatch_semaphore_signal(dispatchSemaphore)
                    
                    }, func: { (error) in
                        
                        dispatch_semaphore_signal(dispatchSemaphore)
                })
                
                dispatch_semaphore_wait(dispatchSemaphore, DISPATCH_TIME_FOREVER)
                
            })
            
            
            dispatch_group_async(group, globalQueue, { () -> Void in
                
                let dispatchSemaphore = dispatch_semaphore_create(0)
                
                RobotAPI.getSubStatus(RotbotInfoManager.sharedInstance.current_endpoint_id!, func: { (substatus) in
                    
                    dispatch_semaphore_signal(dispatchSemaphore)
                    
                    }, func: { (error) in
                        
                        dispatch_semaphore_signal(dispatchSemaphore)
                })
                
                dispatch_semaphore_wait(dispatchSemaphore, DISPATCH_TIME_FOREVER)
                
            })
            
            
            dispatch_group_notify(group, mainQueue, { () -> Void in
                
                let robotInfo = RotbotInfoManager.sharedInstance.robotWithEndpointId(RotbotInfoManager.sharedInstance.current_endpoint_id!)
                robotInfo.online = true
                self.updateUI()
                
            })
            
        }) { (error) in
            
            SCLAlertView().showError("提示", subTitle: ("机器离线"))
            weakself!.backAction()
        }
        
    }
    
    @objc func showNotice(notification:NSNotification){
        
        let info = notification.userInfo!
        let endpoint_id:String = info["endpoint_id"] as! String
        let notice_id:Int = info["noticeId"] as! Int
        if endpoint_id == RotbotInfoManager.sharedInstance.current_endpoint_id {
            let robotInfo = RotbotInfoManager.sharedInstance.robotWithEndpointId(endpoint_id)
            robotInfo.noticeID = notice_id
            
            self.showNoticeView(robotInfo.noticeID)
        }
        
    }
    
    @objc func updateStatus(notification: NSNotification){
        let info = notification.userInfo!
        let endpoint_id:String = info["endpoint_id"] as! String
        if endpoint_id == RotbotInfoManager.sharedInstance.current_endpoint_id {
            
            let robotInfo = RotbotInfoManager.sharedInstance.robotWithEndpointId(endpoint_id)
            let online = robotInfo.online ? "在线":"断线"
            
            if robotInfo.online == false {
                
                if nil != alertView {
                    alertView!.dismissWithClickedButtonIndex(0, animated: false)
                    alertView = nil
                }
                
                view_ctrl.hidden = true
                
                self.backAction()
                
            }
            
            
            
            if(robotInfo.errorDetail.isEmpty){
                
                self.lb_status!.text = robotInfo.statusName() + "(" + online + ")"
                //self.updateTitleViewFrame(self.lb_status!.text!)
                if robotInfo.statusName() == "闲置任务" || robotInfo.statusName() == "送餐准备" || robotInfo.statusName() == "挂起"{
                    imgv_status?.image = UIImage(named: "icon_status_idle_ipad")
                }else if robotInfo.statusName() == "脱离磁道" {
                    imgv_status?.image = UIImage(named: "icon_status_abnormal_ipad")
                } else {
                    imgv_status?.image = UIImage(named: "icon_status_busy_ipad")
                }
                
                if robotInfo.statusName() == "挂起" {
                    
                    self.lb_status!.text = "(" + robotInfo.statusName() + ")" + robotInfo.preStatusName() + "(" + online + ")"
                    
                }
                self.updateTitleViewFrame(self.lb_status!.text!)
                
            }else{
                
                self.lb_status!.text = robotInfo.errorDetail
                self.updateTitleViewFrame(self.lb_status!.text!)
                imgv_status?.image = UIImage(named: "icon_status_abnormal_ipad")
            }
        }
    }
    
    //**************** 更新机器状态通知 ***************//
    
    @objc func statusChanged(notification: NSNotification){
        self.updateStatus(notification);
        let info = notification.userInfo!
        let endpoint_id:String = info["endpoint_id"] as! String
        weak var weakself = self
        if endpoint_id == RotbotInfoManager.sharedInstance.current_endpoint_id {
            let robotInfo = RotbotInfoManager.sharedInstance.robotWithEndpointId(endpoint_id)
            if robotInfo.status == ROBOT_STATUS.MOVE_WAITREADY { //等待就位 弹出提示
                showMessage("请放入餐点")
                if nil != self.v_showSeat {
                    
                    self.v_showSeat.removeFromSuperview()
                    self.v_showSeat = nil
                    
                }
            }else if robotInfo.status == ROBOT_STATUS.MOVE_WAITBEGINMEAL{ //等待送餐 ，弹出选择框
                weakself?.showSeatChooseVC()
            }
        }
    }
    //**************** 更新机器电量信息 ***************//
    
    @objc func updateElectricity(notification: NSNotification){
        let info = notification.userInfo!
        let endpoint_id:String = info["endpoint_id"] as! String
        if endpoint_id == RotbotInfoManager.sharedInstance.current_endpoint_id {
            let robotInfo = RotbotInfoManager.sharedInstance.robotWithEndpointId(endpoint_id)
            self.power = NSNumber(int:(Int32(robotInfo.power)))
            
        }
    }
    //**************** 更新机器位置信息 ***************//
    
    @objc func updatePosLable(notification: NSNotification){
        let info = notification.userInfo!
        print(info)
        self.clearTagStatus()
        let endpoint_id:String = info["endpoint_id"] as! String
        if endpoint_id == RotbotInfoManager.sharedInstance.current_endpoint_id {
            let posLable:NSNumber = info["posLabel"] as! NSNumber
            
            if self.isChangle == true {
                let tag = self.getChangleTagFormLable(posLable.integerValue)
                self.setTagHighter(tag)
            }else{
                
                let tag = self.getTagFormLable(posLable.integerValue)
                self.setTagHighter(tag)
            }
            
        }
    }
    
}


// MARK: 视图相关

extension CtrlVC{
    
    //*****************  显示方向控制视图 *****************//
    func  showDirctionView() -> Void {
        btn_ctrl.tag = 1
        view_ctrl.hidden = false
    }
    
    
    //*****************  隐藏方向控制视图 *****************//
    
    func hideDirctionView()->Void{
        btn_ctrl.tag = 0
        view_ctrl.hidden = true
    }
    
    //***************** 显示座位选择视图 *****************//
    
    func showSeatChooseVC()->Void{
        
        self.hideMessage()
        
        if nil == self.v_showSeat {
            
            self.v_showSeat  = NSBundle.mainBundle().loadNibNamed("SeatChooseView", owner: nil, options: nil).first as? SeatChooseView
            self.v_showSeat?.seatList = RobotAPI.getSeatList()
            self.v_showSeat?.showView()
            
        }else{
            
            UIView.animateWithDuration(0.2, animations: {
                
                self.v_showSeat.alpha = 0
                }, completion: { finished in
                    self.v_showSeat.removeFromSuperview()
                    self.v_showSeat?.showView()
                    
            })
            
        }
        
    }
    
    
    //***************** 在界面上显示信息 *****************//
    
    func showMessage(msg:String)->Void{
        self.hideMessage()
        alertView = UIAlertView(title: "提示", message: msg, delegate: nil, cancelButtonTitle: "确定")
        alertView?.show()
    }
    
    //***************** 关闭显示的信息 *****************//
    
    func hideMessage()->Void{
        if alertView != nil {
            alertView?.dismissWithClickedButtonIndex(0, animated: false)
            alertView = nil
        }
        
    }
    
}


extension CtrlVC{
    
    //************ 地图切换处理 ****************//
    
    func mapChanged(switchState:UISwitch){
        
        if switchState.on {
            self.isChangle = true
        }else{
            self.isChangle = false
        }
        
        let robotInfo = RotbotInfoManager.sharedInstance.robotWithEndpointId(RotbotInfoManager.sharedInstance.current_endpoint_id!)
        
        if self.isChangle == true {
            let tag = self.getChangleTagFormLable(robotInfo.posLable)
            self.setTagHighter(tag)
        }else{
            
            let tag = self.getTagFormLable(robotInfo.posLable)
            self.setTagHighter(tag)
        }
        
    }
    
    //************ 更新titleView尺寸大小 ******************//
    
    func updateTitleViewFrame(text:String){
        
        let font:UIFont = (lb_status?.font)!
        let attributes = [NSFontAttributeName:font];
        let frame:CGRect = labelSize(text, attributes: attributes)
        lb_status?.frame.size.width = frame.size.width
        lb_status?.center = CGPoint(x:(view_status?.frame.size.width)!/2, y:(view_status?.frame.size.height)!/2)
        imgv_status?.frame.origin.x = (lb_status?.frame.origin.x)! - 20
    }
    
    func labelSize(text:String ,attributes : [String : UIFont]) -> CGRect{
        var size = CGRect();
        let size2 = CGSize(width: 210, height: 0);
        size = text.boundingRectWithSize(size2, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attributes , context: nil);
        return size
    }
    
}

// MARK: 提示框处理

let TAG_TARGET_CTRL = 101 //手动状态
let TAG_TARGET_CHARGE = 102 //充电
let TAG_TARGET_PAUSE = 103 //任务暂停
let TAG_TARGET_STOP = 104 //任务返回


var HAS_TARGET_PAUSE = false  //用来判断是否送餐任务挂起

extension CtrlVC:UIAlertViewDelegate{
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        weak var weakself = self;
        /**************** 主动操作如果机器在执行送餐任务时候的提醒 ****************/
        
        if(buttonIndex == 1 && alertView.tag == TAG_TARGET_CHARGE){
            RobotAPI.sendCMD(RotbotInfoManager.sharedInstance.current_endpoint_id!, cmd: MOVE_CTRL_ACTION.ACT_MOVE_CTRL_STOP_SLOW, func: {
                HAS_TARGET_PAUSE = false
                weakself?.sendChargeAction()
                }, func: { (error) in
                    
            })
            
        }else if(buttonIndex == 1 && alertView.tag == TAG_TARGET_PAUSE){
            weakself?.sendPauseAction()
        }else if(buttonIndex == 1 && alertView.tag == TAG_TARGET_STOP){
            weakself?.sendStopAction()
        }else if buttonIndex==1 && alertView.tag == TAG_TARGET_CTRL{
            
            RobotAPI.sendCMD(RotbotInfoManager.sharedInstance.current_endpoint_id!, cmd: MOVE_CTRL_ACTION.ACT_AUTOMOVE_SUSPEND, func: {
                HAS_TARGET_PAUSE = true
                weakself?.showDirctionView()
                }, func: { (error) in
                    
            })
        }
        //        }else if buttonIndex==2 && alertView.tag == TAG_TARGET_CTRL{
        //            RobotAPI.sendCMD(RotbotInfoManager.sharedInstance.current_endpoint_id!, cmd: MOVE_CTRL_ACTION.ACT_MOVE_CTRL_STOP_SLOW, func: {
        //                HAS_TARGET_PAUSE = false
        //                weakself?.showDirctionView()
        //                }, func: { (error) in
        //
        //            })
        //        }
        
        
        /**************** 显示消息通知的提醒处理 ****************/
        
        if alertView.tag == ALERTVIEW_NOTICE_FIRST {
            if buttonIndex == 0 {
                self.timer_sound.invalidate()
                self.timer_sound = nil
            }else{
                RobotAPI.sendCMD(RotbotInfoManager.sharedInstance.current_endpoint_id!, cmd: MOVE_CTRL_ACTION.ACT_MOVE_CTRL_GET_MEALS, func: {
                }) { (error) in
                    
                }
            }
        }else if alertView.tag == ALERTVIEW_NOTICE_THIRD {
            if self.timer_sound != nil{
                self.timer_sound.invalidate()
                self.timer_sound = nil
            }
        }else if alertView.tag == ALERTVIEW_NOTICE_FIFTH {
            if buttonIndex == 1 {
                RobotAPI.sendCMD(RotbotInfoManager.sharedInstance.current_endpoint_id!, cmd: MOVE_CTRL_ACTION.ACT_MOVE_CTRL_GET_MEALS, func: {
                }) { (error) in
                    
                }
            }
            
            if self.timer_sound != nil{
                self.timer_sound.invalidate()
                self.timer_sound = nil
            }
            
        }else if alertView.tag == ALERTVIEW_NOTICE_SEVENTH {
            if self.timer_sound != nil{
                self.timer_sound.invalidate()
                self.timer_sound = nil
            }
        }else if alertView.tag == ALERTVIEW_NOTICE_NINTH {
            
            if self.timer_sound != nil{
                self.timer_sound.invalidate()
                self.timer_sound = nil
            }
        }else if alertView.tag == ALERTVIEW_NOTICE_ELEVENTH {
            
            if self.timer_sound != nil{
                self.timer_sound.invalidate()
                self.timer_sound = nil
            }
            
        }
    }
}

// MARK: 按钮事件

extension CtrlVC{
    
    //***************** 点击送餐事件 *****************//
    
    @IBAction func chooseAction(sender: AnyObject) {
        
        let robotInfo = RotbotInfoManager.sharedInstance.robotWithEndpointId(RotbotInfoManager.sharedInstance.current_endpoint_id!)
        
        if robotInfo.substatus == 2 {
            
            SCLAlertView().showError("提示", subTitle: ("机器正在旋转，请稍等"))
            
            return
        }
        
        self.hideDirctionView()
        
        let flag = RobotAPI.canGoSeat(RotbotInfoManager.sharedInstance.current_endpoint_id!)
        if !flag.canGo {
            self.showMessage(flag.msg)
        }else{
            self.hideMessage()
            self.showSeatChooseVC()
        }
    }
    
    //***************** 点击控制事件 *****************//
    
    @IBAction func beginCtrlAction(sender: AnyObject) {
        weak var weakself = self
        
        let robotInfo = RotbotInfoManager.sharedInstance.robotWithEndpointId(RotbotInfoManager.sharedInstance.current_endpoint_id!)
        
        if robotInfo.substatus == 2 {
            
            SCLAlertView().showError("提示", subTitle: ("机器正在旋转，请稍等"))
            
            return
        }
        
        if btn_ctrl.tag == 0{
            
            alertView = UIAlertView(title: "确认消息", message: "机器人" + robotInfo.statusName() + "中,是否手控调整?", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确定");
            alertView!.tag = TAG_TARGET_CTRL
            alertView!.show()
            
            /*
             let robotInfo = RotbotInfoManager.sharedInstance.robotWithEndpointId(RotbotInfoManager.sharedInstance.current_endpoint_id!)
             if robotInfo.status == ROBOT_STATUS.MOVE_MEAL || robotInfo.status == ROBOT_STATUS.MOVE_MEALARRIVE || robotInfo.status == ROBOT_STATUS.MOVE_WAITBEGINMEAL {
             
             alertView = UIAlertView(title: "确认消息", message: "机器人处于［正在送餐］状态，请选择任务处理", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "暂停","中止");
             alertView!.tag = TAG_TARGET_CTRL
             alertView!.show()
             
             }else{
             
             RobotAPI.sendCMD(RotbotInfoManager.sharedInstance.current_endpoint_id!, cmd: MOVE_CTRL_ACTION.ACT_AUTOMOVE_SUSPEND, func: {
             HAS_TARGET_PAUSE = false
             weakself?.showDirctionView()
             
             }, func: { (error) in
             
             })
             
             }
             */
            
        }else{
            
            RobotAPI.sendCMD(RotbotInfoManager.sharedInstance.current_endpoint_id!, cmd: MOVE_CTRL_ACTION.ACT_FINDPATH_RESUME, func: {
                
                }, func: { (error) in
                    
            })
            weakself?.hideDirctionView()
            /*
             if HAS_TARGET_PAUSE {
             
             RobotAPI.sendCMD(RotbotInfoManager.sharedInstance.current_endpoint_id!, cmd: MOVE_CTRL_ACTION.ACT_FINDPATH_RESUME, func: {
             HAS_TARGET_PAUSE = false
             weakself?.hideDirctionView()
             }, func: { (error) in
             
             })
             
             }else{
             
             weakself?.hideDirctionView()
             
             }
             */
        }
        
    }
    
    //***************** 点击方向按下事件 *****************//
    
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
    
    //***************** 点击方向放开事件 *****************//
    
    @IBAction func upAction(sender: AnyObject) {
        dirction = MOVE_DIRCTION.MOVE_DIRCTION_STOP
        self.endDirctionCMD()
    }
    
    //***************** 点击暂停事件 *****************//
    
    @IBAction func pauseAction(sender: AnyObject) {
        
        let robotInfo = RotbotInfoManager.sharedInstance.robotWithEndpointId(RotbotInfoManager.sharedInstance.current_endpoint_id!)
        
        if robotInfo.substatus == 2 {
            
            SCLAlertView().showError("提示", subTitle: ("机器正在旋转，请稍等"))
            
            return
        }
        
        
        if btn_pause.tag == 0 {
            
            let robotInfo = RotbotInfoManager.sharedInstance.robotWithEndpointId(RotbotInfoManager.sharedInstance.current_endpoint_id!)
            if robotInfo.status == ROBOT_STATUS.MOVE_MEAL || robotInfo.status == ROBOT_STATUS.MOVE_MEALARRIVE || robotInfo.status == ROBOT_STATUS.MOVE_WAITBEGINMEAL {
                
                alertView = UIAlertView(title: "确认消息", message: "机器人处于" + robotInfo.statusName() + "状态，是否要暂停？", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "暂停");
                alertView!.tag = TAG_TARGET_PAUSE
                alertView!.show()
                
            }else{
                
                self.sendPauseAction()
            }
            
        }else{
            
            self.hideDirctionView()
            
            self.sendContinueAction()
            
        }
    }
    
    //***************** 点击停止事件 *****************//
    
    @IBAction func stopAction(sender: AnyObject) {
        
        self.hideDirctionView()
        
        let robotInfo = RotbotInfoManager.sharedInstance.robotWithEndpointId(RotbotInfoManager.sharedInstance.current_endpoint_id!)
        
        if robotInfo.substatus == 2 {
            
            SCLAlertView().showError("提示", subTitle: ("机器正在旋转，请稍等"))
            
            return
        }
        
        if robotInfo.status == ROBOT_STATUS.MOVE_MEAL || robotInfo.status == ROBOT_STATUS.MOVE_MEALARRIVE || robotInfo.status == ROBOT_STATUS.MOVE_WAITBEGINMEAL {
            
            alertView = UIAlertView(title: "确认消息", message: "机器人处于" + robotInfo.statusName() + "状态，是否要返回？", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "返回");
            alertView!.tag = TAG_TARGET_STOP
            alertView!.show()
            
        }else{
            self.sendStopAction()
        }
        
    }
    
    
    //***************** 点击充电事件 *****************//
    
    @IBAction func chargeAction(sender: AnyObject) {
        
        self.hideDirctionView()
        
        let robotInfo = RotbotInfoManager.sharedInstance.robotWithEndpointId(RotbotInfoManager.sharedInstance.current_endpoint_id!)
        
        if robotInfo.substatus == 2 {
            
            SCLAlertView().showError("提示", subTitle: ("机器正在旋转，请稍等"))
            
            return
        }
        
        if robotInfo.status == ROBOT_STATUS.MOVE_MEAL || robotInfo.status == ROBOT_STATUS.MOVE_MEALARRIVE || robotInfo.status == ROBOT_STATUS.MOVE_WAITBEGINMEAL {
            alertView = UIAlertView(title: "确认消息", message: "机器人处于" + robotInfo.statusName() + "状态，是否要去充电？", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确定");
            alertView!.tag = TAG_TARGET_CHARGE
            alertView!.show()
        }else{
            self.sendChargeAction()
        }
    }
    
    //***************** 点击机器人头像事件 *****************//
    
    @IBAction func btnShowOrHideStopViewAction(sender: AnyObject) {
        
        if self.v_stop.hidden == true {
            
            self.v_stop.alpha = 0.0
            
            UIView.animateWithDuration(0.2, animations: {
                
                () -> Void in
                
                self.v_stop.alpha = 1.0
                
                },completion: {
                    
                    (finished:Bool) -> Void in
                    
                    self.v_stop.hidden = false
                    
            })
            
        }else {
            
            self.v_stop.alpha = 1.0
            
            UIView.animateWithDuration(0.2, animations: {
                
                () -> Void in
                
                self.v_stop.alpha = 0.0
                
                },completion: {
                    
                    (finished:Bool) -> Void in
                    
                    self.v_stop.hidden = true
                    
            })
            
        }
        
    }
    
    
    func beginAction(){
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1,
                                                            target:self,selector:#selector(CtrlVC.sendDirctionCMD),
                                                            userInfo:nil,repeats:true)
        self.timer?.fire()
    }
    
}

// MARK: 显示消息通知

let ALERTVIEW_NOTICE_ZERO       = 1000      //无提示状态，收到这个id,提示框取消
let ALERTVIEW_NOTICE_FIRST      = 1001      //中途餐被取走，机器人挂起
let ALERTVIEW_NOTICE_SECOND     = 1002      //餐盘重新放回，机器人恢复任务
let ALERTVIEW_NOTICE_THIRD      = 1003      //前方有障碍物
let ALERTVIEW_NOTICE_FOURTH     = 1004      //障碍物取消
let ALERTVIEW_NOTICE_FIFTH      = 1005      //送餐到达长时间没被取走
let ALERTVIEW_NOTICE_SIXTH      = 1006      //餐被取走
let ALERTVIEW_NOTICE_SEVENTH    = 1007      //脱离磁道
let ALERTVIEW_NOTICE_EIGHTENTH  = 1008      //重新回磁道
let ALERTVIEW_NOTICE_NINTH      = 1009      //低电量
let ALERTVIEW_NOTICE_TENTH      = 1010      //低电量恢复
let ALERTVIEW_NOTICE_ELEVENTH   = 1011      //送餐到达后餐盘没被取走，机器人自动回吧台

extension CtrlVC{
    
    
    
    
    func playSound() -> Void{
        
        var soundID:SystemSoundID = 0
        let path = NSBundle.mainBundle().pathForResource("didi", ofType: "wav")
        let baseURL = NSURL(fileURLWithPath: path!)
        AudioServicesCreateSystemSoundID(baseURL, &soundID)
        AudioServicesPlaySystemSound(soundID)
        
    }
    
    func playSoundWithTime() -> Void{
        
        if self.timer_sound == nil {
            
            self.timer_sound = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(CtrlVC.playSound), userInfo: nil, repeats: true)
        }else{
            
            self.timer_sound.invalidate()
            self.timer_sound = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(CtrlVC.playSound), userInfo: nil, repeats: true)
            
        }
    }
    
    func dismissAlertView(alertViewTag:Int) -> Void{
        
        if self.timer_sound != nil {
            self.timer_sound.invalidate()
        }
        
        for alert in self.arr_alert {
            if alert.isKindOfClass(UIAlertView) {
                let t_alert :UIAlertView = alert as! UIAlertView
                if alert.tag == alertViewTag {
                    t_alert.dismissWithClickedButtonIndex(0, animated: false)
                }
            }
        }
        
    }
    
    func showNoticeView(noticeId:Int) -> Void {
        
        switch noticeId {
        case 0:
            
            //无提示状态，收到这个id,提示框取消
            
            for alert in self.arr_alert {
                
                if alert.isKindOfClass(UIAlertView) {
                    let t_alert :UIAlertView = alert as! UIAlertView
                    t_alert.dismissWithClickedButtonIndex(0, animated: false)
                }
            }
            
            break
        case 1:
            //中途餐被取走，机器人挂起
            
            let alert = UIAlertView(title: "提醒消息", message: "中途餐被取走，是否再返回取餐?", delegate: self, cancelButtonTitle: "取消", otherButtonTitles:"返回");
            alert.tag = ALERTVIEW_NOTICE_FIRST
            alert.show()
            self.arr_alert.addObject(alert)
            self.playSoundWithTime()
            
            break
            
        case 2:
            
            //餐盘重新放回，机器人恢复任务
            
            self.dismissAlertView(ALERTVIEW_NOTICE_FIRST)
            
            break
            
        case 3:
            
            //前方有障碍物
            let alert = UIAlertView(title: "提醒消息", message: "前方有固定障碍物", delegate: self, cancelButtonTitle: "确定");
            alert.tag = ALERTVIEW_NOTICE_THIRD
            alert.show()
            self.arr_alert.addObject(alert)
            self.playSoundWithTime()
            
            break
            
        case 4:
            //障碍物取消
            
            self.dismissAlertView(ALERTVIEW_NOTICE_THIRD)
            
            break
        case 5:
            //送餐到达长时间没被取走
            
            self.dismissAlertView(ALERTVIEW_NOTICE_FIFTH)
            
            let robotInfo = RotbotInfoManager.sharedInstance.robotWithEndpointId(RotbotInfoManager.sharedInstance.current_endpoint_id!)
            
            let alert = UIAlertView(title: "提醒消息", message: "餐已送达桌号"+"("+robotInfo.tableId.description + ")" + "是否返回？", delegate: self, cancelButtonTitle: "取消",otherButtonTitles:"返回");
            alert.tag = ALERTVIEW_NOTICE_FIFTH
            alert.show()
            self.arr_alert.addObject(alert)
            self.playSoundWithTime()
            
            break
            
        case 6:
            
            //餐被取走
            self.dismissAlertView(ALERTVIEW_NOTICE_FIFTH)
            
            break
        case 7:
            
            //脱离磁道
            let alert = UIAlertView(title: "提醒消息", message: "送餐侠不在磁道上，需要您的协助", delegate: self, cancelButtonTitle: "确定");
            alert.tag = ALERTVIEW_NOTICE_SEVENTH
            alert.show()
            self.arr_alert.addObject(alert)
            self.playSoundWithTime()
            
            break
        case 8:
            
            //重新回磁道
            self.dismissAlertView(ALERTVIEW_NOTICE_SEVENTH)
            
            break
        case 9:
            
            //低电量
            let alert = UIAlertView(title: "提醒消息", message: "电量过低,完成这次服务后会自动回到充电点，充电满后可继续服务", delegate: self, cancelButtonTitle: "确定");
            alert.tag = ALERTVIEW_NOTICE_NINTH
            alert.show()
            self.arr_alert.addObject(alert)
            self.playSoundWithTime()
            
            break
        case 10:
            
            //低电量恢复
            self.dismissAlertView(ALERTVIEW_NOTICE_NINTH)
            
            break
        case 11:
            
            //送餐到达后餐盘没被取走，机器人自动回吧台
            let alert = UIAlertView(title: "提醒消息", message: "长时间无人取餐，机器人自动返回", delegate: self, cancelButtonTitle: "确定");
            alert.tag = ALERTVIEW_NOTICE_ELEVENTH
            alert.show()
            self.arr_alert.addObject(alert)
            self.playSoundWithTime()
            
            break
            
        default:
            
            break
        }
        
    }
}



// MARK: 命令定义

extension CtrlVC{
    
    //***************** 停止控制方向命令 *****************//
    
    func endDirctionCMD(){
        
        timer?.invalidate()
        if (RotbotInfoManager.sharedInstance.current_endpoint_id != nil) {
            RobotAPI.ctrolDirection(RotbotInfoManager.sharedInstance.current_endpoint_id!, dirction: MOVE_DIRCTION.MOVE_DIRCTION_STOP)
        }
    }
    
    //***************** 发送控制方向命令 *****************//
    
    func sendDirctionCMD(){
        print("!!!!")
        if (RotbotInfoManager.sharedInstance.current_endpoint_id != nil) {
            RobotAPI.ctrolDirection(RotbotInfoManager.sharedInstance.current_endpoint_id!, dirction: dirction)
        }
    }
    
    //***************** 发送暂停命令 *****************//
    
    func sendPauseAction(){
        weak var weakself = self
        RobotAPI.sendCMD(RotbotInfoManager.sharedInstance.current_endpoint_id!, cmd: MOVE_CTRL_ACTION.ACT_AUTOMOVE_SUSPEND, func: {
            
            weakself!.btn_pause.tag = 1
            weakself!.btn_pause.setImage(UIImage(named: "icon_star_unsd_ipad"), forState: UIControlState.Normal)
            weakself!.btn_pause.setImage(UIImage(named: "icon_star_sd_ipad"), forState: UIControlState.Highlighted)
            
        }) { (error) in
            
        }
    }
    
    //***************** 发送停止命令 *****************//
    
    func sendStopAction(){
        //        weak var weakself = self
        
        RobotAPI.sendCMD(RotbotInfoManager.sharedInstance.current_endpoint_id!, cmd: MOVE_CTRL_ACTION.ACT_MOVE_CTRL_GET_MEALS, func: {
        }) { (error) in
            
        }
        
        //        RobotAPI.sendCMD(RotbotInfoManager.sharedInstance.current_endpoint_id!, cmd: MOVE_CTRL_ACTION.ACT_MOVE_CTRL_STOP_SLOW, func: {
        //
        ////            weakself!.btn_pause.enabled = false
        ////            weakself!.btn_pause.setTitle("暂停", forState: UIControlState.Normal)
        ////            weakself!.btn_pause.setImage(UIImage(named: "icon_pause_unsd_ipad"), forState: UIControlState.Normal)
        ////            weakself!.btn_pause.setImage(UIImage(named: "icon_pause_sd_ipad"), forState: UIControlState.Highlighted)
        //
        //            RobotAPI.sendCMD(RotbotInfoManager.sharedInstance.current_endpoint_id!, cmd: MOVE_CTRL_ACTION.ACT_MOVE_CTRL_GET_MEALS, func: {
        //            }) { (error) in
        //
        //            }
        //        }) { (error) in
        //
        //        }
    }
    
    //***************** 发送继续命令 *****************//
    
    func sendContinueAction(){
        weak var weakself = self
        RobotAPI.sendCMD(RotbotInfoManager.sharedInstance.current_endpoint_id!, cmd: MOVE_CTRL_ACTION.ACT_FINDPATH_RESUME, func: {
            weakself!.btn_pause.tag = 0
            weakself!.btn_pause.setImage(UIImage(named: "icon_pause_unsd_ipad"), forState: UIControlState.Normal)
            weakself!.btn_pause.setImage(UIImage(named: "icon_pause_sd_ipad"), forState: UIControlState.Highlighted)
            
        }) { (error) in
        }
    }
    
    
    //***************** 发送充电命令 *****************//
    
    func sendChargeAction(){
        RobotAPI.sendCMD(RotbotInfoManager.sharedInstance.current_endpoint_id!, cmd: MOVE_CTRL_ACTION.ACT_MOVE_CTRL_CHARGE, func: {
            
        }) { (error) in
            
        }
    }
    
}

// MARK: 获取地图地标以及定位地图地标

extension CtrlVC{
    
    func getTagLables() -> [UILabel]{
        
        if self.isChangle == true {
            
            let tagView = v_changle?.viewWithTag(119)
            let tempviews = tagView?.subviews
            var results = [UILabel]()
            for view in tempviews! {
                let lable = view as! UILabel
                
                results.append(lable)
            }
            return results
        }else{
            
            let tagView = v_jinye?.viewWithTag(111)
            let tempviews = tagView?.subviews
            var results = [UILabel]()
            for view in tempviews! {
                let lable = view as! UILabel
                results.append(lable)
            }
            return results
        }
    }
    
    func clearTagStatus() -> Void{
        let lables = getTagLables()
        
        for lable in lables {
            lable.backgroundColor = UIColor.lightGrayColor()
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
    
    
    func getChangleTagFormLable(lable:Int) -> Int{
        switch lable {
        case 0:
            return 1
        case 5:
            return 2
        case 1,2:
            return 3
        case 3,4:
            return 4
        case 6,7,8:
            return 5
        case 9:
            return 6
        case 10,11,12:
            return 7
        case 13:
            return 8
        case 14,15,16:
            return 9
        case 17:
            return 10
        case 18,19:
            return 11
        case 20,21:
            return 12
        case 22,23,24:
            return 13
        case 25:
            return 14
        case 26,27:
            return 15
        case 28,29:
            return 16
        case 30,31:
            return 17
        case 32,33,34:
            return 18
        case 35:
            return 19
        case 36,37:
            return 20
        case 38,39:
            return 21
        case 40,46:
            return 22
        case 41,47:
            return 23
        case 42,48:
            return 24
        case 43,49:
            return 25
        case 44,50:
            return 26
        case 45:
            return 27
        default:
            return -1
        }
    }
    
    
    
    func setTagHighter(tag:Int) -> Void{
        let lables = getTagLables()
        
        for lable in lables {
            if lable.tag == tag {
                lable.backgroundColor = UIColor(red: 62/255.0, green: 111/255.0, blue: 77/255.0, alpha: 1.0)
            }
        }
    }
    
    
}


