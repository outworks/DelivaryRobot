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
    
    @IBOutlet weak var lb_electricity: UILabel!
    
    //@IBOutlet weak var lb_status: UILabel!
    
    @IBOutlet weak var lb_route: UILabel!
    
    @IBOutlet weak var btn_pause: UIButton!
    
    @IBOutlet weak var btn_ctrl: UIButton!
    
    @IBOutlet weak var view_ctrl: UIView!
    
    /************ 长乐地图 ************/
    @IBOutlet weak var v_changle: UIView!
    
    /************ 金业地图 ************/
    @IBOutlet weak var v_jinye: UIView!
    
    /************ 长乐地图开关**********/
    
    @IBOutlet weak var switch_map: UISwitch!
    
    
    
    var view_status: UIView?
    var imgv_status: UIImageView?
    var lb_status: UILabel?
    
    
    
    /****************  停止视图 *****************/
    @IBOutlet weak var view_stop: UIView!
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
        // Do any additional setup after loading the view, typically from a nib.
        
        self.addBackButton(self, action: #selector(self.backAction))
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CtrlVC.statusChanged), name: RobotNotification.STATUS_CHANGE, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CtrlVC.updateElectricity), name: RobotNotification.POWER_CHANGE, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CtrlVC.updateStatus), name: RobotNotification.ONLINE_CHANGE, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CtrlVC.updatePosLable), name: RobotNotification.POSLABLE_CHANGE, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CtrlVC.updateStatus), name: RobotNotification.DEVICE_STATUS, object: nil)
        self.hideDirctionView()
        self.clearTagStatus()
        self.setUpTitleView()
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
            if(robotInfo.errorDetail.isEmpty){
                self.lb_status!.text = robotInfo.statusName() + "(" + online + ")"
                
                if robotInfo.statusName() == "闲置任务" || robotInfo.statusName() == "等待就位"{
                    imgv_status?.image = UIImage(named: "icon_status_idle_ipad")
                }else if robotInfo.statusName() == "脱离磁道" {
                    imgv_status?.image = UIImage(named: "icon_status_abnormal_ipad")
                } else {
                    imgv_status?.image = UIImage(named: "icon_status_busy_ipad")
                }
                
            }else{
                self.lb_status!.text = robotInfo.errorDetail
                imgv_status?.image = UIImage(named: "icon_status_abnormal_ipad")
            }
        }
    }
    
    @objc func statusChanged(notification: NSNotification){
        self.updateStatus(notification);
        let info = notification.userInfo!
        let endpoint_id:String = info["endpoint_id"] as! String
        weak var weakself = self
        if endpoint_id == RotbotInfoManager.sharedInstance.current_endpoint_id {
            let robotInfo = RotbotInfoManager.sharedInstance.robotWithEndpointId(endpoint_id)
            if robotInfo.status == ROBOT_STATUS.MOVE_WAITREADY { //等待就位 弹出提示
                showMessage("请放让咖啡")
            }else if robotInfo.status == ROBOT_STATUS.MOVE_WAITBEGINMEAL{ //等待送餐 ，弹出选择框
                weakself?.showSeatChooseVC()
            }
        }
    }
    
    @objc func updateElectricity(notification: NSNotification){
        let info = notification.userInfo!
        let endpoint_id:String = info["endpoint_id"] as! String
        if endpoint_id == RotbotInfoManager.sharedInstance.current_endpoint_id {
            let robotInfo = RotbotInfoManager.sharedInstance.robotWithEndpointId(endpoint_id)
            
            self.power = NSNumber(int:(Int32(robotInfo.power)))
            
            //self.lb_electricity.text = "电量：" + String(robotInfo.power) + "/100"
        }
    }
    
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
    
    func updateUI(){
        if nil != RotbotInfoManager.sharedInstance.current_endpoint_id {
            let robotInfo = RotbotInfoManager.sharedInstance.robotWithEndpointId(RotbotInfoManager.sharedInstance.current_endpoint_id!)
            let online = robotInfo.online ? "在线":"断线"
            //self.lb_electricity.text = "电量：" + String(robotInfo.power)
            self.power = NSNumber(int:(Int32(robotInfo.power)))
            self.lb_status!.text = robotInfo.statusName() + "(" + online + ")"
            if robotInfo.statusName() == "闲置任务" || robotInfo.statusName() == "等待就位"{
                imgv_status?.image = UIImage(named: "icon_status_idle_ipad")
            }else if robotInfo.statusName() == "脱离磁道"{
                imgv_status?.image = UIImage(named: "icon_status_abnormal_ipad")
            } else {
                imgv_status?.image = UIImage(named: "icon_status_busy_ipad")
            }
            self.setTagHighter(robotInfo.posLable)
            self.lb_nameRobit.text = RotbotInfoManager.sharedInstance.current_endpoin_name!
            self.view_stop.hidden = true;
            
            self.switch_map.addTarget(self, action:#selector(CtrlVC.mapChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
            self.isChangle = false
            self.switch_map.setOn(self.isChangle!, animated: false)
        
        }
        
    }
    
    func setUpTitleView(){
        
        view_status = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 150, height: 44))
        view_status?.backgroundColor = UIColor.clearColor()
        imgv_status = UIImageView(frame: CGRect(x: 5.0, y: 22-4.5, width: 9, height: 9))
        view_status?.addSubview(imgv_status!)
        
        lb_status = UILabel(frame: CGRect(x: 19.0, y: 0.0, width: 150, height: 44))
        lb_status?.font = UIFont.systemFontOfSize(18.0)
        lb_status?.textColor = UIColor.whiteColor()
        view_status?.addSubview(lb_status!)
        
        self.navigationItem.titleView = view_status
    
    }

    
}


extension CtrlVC{
    //TODO:
    /**
     显示方向控制视图
     */
    func  showDirctionView() -> Void {
        btn_ctrl.tag = 1
        self.setCtrlBtnTitle("自动")
        view_ctrl.hidden = false
    }
    /**
     隐藏方向控制视图
     */
    func hideDirctionView()->Void{
        btn_ctrl.tag = 0
        self.setCtrlBtnTitle("手控")
        view_ctrl.hidden = true
    }
    
    /**
     显示座位选择视图
     */
    func showSeatChooseVC()->Void{
        if nil != alertView {
            alertView!.dismissWithClickedButtonIndex(0, animated: false)
            alertView = nil
        }
        //weak var weakself = self
        
        let myView = NSBundle.mainBundle().loadNibNamed("SeatChooseView", owner: nil, options: nil).first as? SeatChooseView
        myView?.seatList = RobotAPI.getSeatList()
        myView?.showView()
        
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let seatChooseVC = storyboard.instantiateViewControllerWithIdentifier("SeatChooseVC")
//        weakself!.navigationController?.presentViewController(seatChooseVC, animated: true, completion: {
//            
//        })
    }
    
    /**
     在界面上显示信息
     
     - parameter msg:
     */
    func showMessage(msg:String)->Void{
        self.hideMessage()
        alertView = UIAlertView(title: "提示", message: msg, delegate: nil, cancelButtonTitle: "确定")
        alertView?.show()
    }
    
    /**
     关闭显示的信息
     */
    func hideMessage()->Void{
        alertView?.dismissWithClickedButtonIndex(0, animated: false)
        alertView = nil
    }
    
    /**
     设置控制按钮的标题
     
     - parameter title: 标题
     */
    func setCtrlBtnTitle(title:String) -> Void{
        
    }
    
}

let TAG_TARGET_CTRL = 101 //手动状态
let TAG_TARGET_CHARGE = 102 //充电
let TAG_TARGET_PAUSE = 103 //任务挂起
let TAG_TARGET_STOP = 104 //任务中止

var HAS_TARGET_PAUSE = false  //用来判断是否送餐任务挂起


extension CtrlVC:UIAlertViewDelegate{
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        weak var weakself = self;
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
        }else if buttonIndex==2 && alertView.tag == TAG_TARGET_CTRL{
            RobotAPI.sendCMD(RotbotInfoManager.sharedInstance.current_endpoint_id!, cmd: MOVE_CTRL_ACTION.ACT_MOVE_CTRL_STOP_SLOW, func: {
                HAS_TARGET_PAUSE = false
                weakself?.showDirctionView()
                }, func: { (error) in
                    
            })
        }
    }
}

extension CtrlVC{
    
    /**
     送餐
     - parameter sender:
     */
    
    @IBAction func chooseAction(sender: AnyObject) {
        
//        self.hideMessage()
//        self.showSeatChooseVC()
//        return
        let flag = RobotAPI.canGoSeat(RotbotInfoManager.sharedInstance.current_endpoint_id!)
        if !flag.canGo {
            self.showMessage(flag.msg)
        }else{
            self.hideMessage()
            self.showSeatChooseVC()
        }
    }
    
    /**
     控制
     - parameter sender:
     */
    @IBAction func beginCtrlAction(sender: AnyObject) {
        weak var weakself = self
        if btn_ctrl.tag == 0{
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
        }else{
            if HAS_TARGET_PAUSE {
                RobotAPI.sendCMD(RotbotInfoManager.sharedInstance.current_endpoint_id!, cmd: MOVE_CTRL_ACTION.ACT_FINDPATH_RESUME, func: {
                    HAS_TARGET_PAUSE = false
                    weakself?.hideDirctionView()
                    }, func: { (error) in
                        
                })
            }else{
                weakself?.hideDirctionView()
            }
        }
        
    }
    
    /**
     方向按下
     - parameter sender:
     */
    
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
    
    /**
     方向放开
     - parameter sender:
     */
    
    @IBAction func upAction(sender: AnyObject) {
        dirction = MOVE_DIRCTION.MOVE_DIRCTION_STOP
        self.endDirctionCMD()
    }
    
    @IBAction func pauseAction(sender: AnyObject) {
        if btn_pause.tag == 0 {
            let robotInfo = RotbotInfoManager.sharedInstance.robotWithEndpointId(RotbotInfoManager.sharedInstance.current_endpoint_id!)
            if robotInfo.status == ROBOT_STATUS.MOVE_MEAL || robotInfo.status == ROBOT_STATUS.MOVE_MEALARRIVE || robotInfo.status == ROBOT_STATUS.MOVE_WAITBEGINMEAL {
                alertView = UIAlertView(title: "确认消息", message: "机器人处于［正在送餐］状态，是否要暂停？", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "暂停");
                alertView!.tag = TAG_TARGET_PAUSE
                alertView!.show()
            }else{
                self.sendPauseAction()
            }
        }else{
            self.sendContinueAction()
        }
    }
    
    @IBAction func stopAction(sender: AnyObject) {
        let robotInfo = RotbotInfoManager.sharedInstance.robotWithEndpointId(RotbotInfoManager.sharedInstance.current_endpoint_id!)
        if robotInfo.status == ROBOT_STATUS.MOVE_MEAL || robotInfo.status == ROBOT_STATUS.MOVE_MEALARRIVE || robotInfo.status == ROBOT_STATUS.MOVE_WAITBEGINMEAL {
            alertView = UIAlertView(title: "确认消息", message: "机器人处于［正在送餐］状态，是否要中止？", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "中止");
            alertView!.tag = TAG_TARGET_STOP
            alertView!.show()
        }else{
            self.sendStopAction()
        }
        
    }
    
    /**
     充电
     - parameter sender:
     */
    
    @IBAction func chargeAction(sender: AnyObject) {
        let robotInfo = RotbotInfoManager.sharedInstance.robotWithEndpointId(RotbotInfoManager.sharedInstance.current_endpoint_id!)
        if robotInfo.status == ROBOT_STATUS.MOVE_MEAL || robotInfo.status == ROBOT_STATUS.MOVE_MEALARRIVE || robotInfo.status == ROBOT_STATUS.MOVE_WAITBEGINMEAL {
            alertView = UIAlertView(title: "确认消息", message: "机器人处于［正在送餐］状态，是否要中止任务？", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "中止");
            alertView!.tag = TAG_TARGET_CHARGE
            alertView!.show()
        }else{
            self.sendChargeAction()
        }
    }
    
    func beginAction(){
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1,
                                                            target:self,selector:#selector(CtrlVC.sendDirctionCMD),
                                                            userInfo:nil,repeats:true)
        self.timer?.fire()
    }
    
    /**
      显示或者隐藏暂停视图
    */
    
    @IBAction func ShowOrHideStopView(sender: AnyObject) {
        
        if !self.view_stop.hidden {
          
            UIView.animateWithDuration(0.3, animations: {
                    () -> Void in
                
                self.view_stop.alpha = 0.0
                
                }, completion: {
                    
                    (finished:Bool) -> Void in
            
                    self.view_stop.hidden = true;
            })
            

        }else{
        
            UIView.animateWithDuration(0.3, animations: {
                () -> Void in
                
                self.view_stop.alpha = 1.0
                
                }, completion: {
                    
                    (finished:Bool) -> Void in
                    
                    self.view_stop.hidden = false;
                    
            })
            
        
        
        }
        
        
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
            //weakself!.btn_pause.setTitle("继续任务", forState:UIControlState.Normal)
            weakself!.btn_pause.setImage(UIImage(named: "icon_star_unsd_ipad"), forState: UIControlState.Normal)
            weakself!.btn_pause.setImage(UIImage(named: "icon_star_sd_ipad"), forState: UIControlState.Highlighted)
        }) { (error) in
            
        }
    }
    
    func sendStopAction(){
        weak var weakself = self
        RobotAPI.sendCMD(RotbotInfoManager.sharedInstance.current_endpoint_id!, cmd: MOVE_CTRL_ACTION.ACT_MOVE_CTRL_STOP_SLOW, func: {
            weakself!.btn_pause.enabled = false
            //weakself!.btn_pause.setTitle("已无任务", forState:UIControlState.Normal)
            weakself!.btn_pause.setImage(UIImage(named: "icon_pause_unsd_ipad"), forState: UIControlState.Normal)
            weakself!.btn_pause.setImage(UIImage(named: "icon_pause_sd_ipad"), forState: UIControlState.Highlighted)
            
            RobotAPI.sendCMD(RotbotInfoManager.sharedInstance.current_endpoint_id!, cmd: MOVE_CTRL_ACTION.ACT_MOVE_CTRL_GET_MEALS, func: {
            }) { (error) in
                
            }
        }) { (error) in
            
        }
    }
    
    func sendContinueAction(){
        weak var weakself = self
        RobotAPI.sendCMD(RotbotInfoManager.sharedInstance.current_endpoint_id!, cmd: MOVE_CTRL_ACTION.ACT_FINDPATH_RESUME, func: {
            weakself!.btn_pause.tag = 0
            //weakself!.btn_pause.setTitle("暂停任务", forState:UIControlState.Normal)
            
            weakself!.btn_pause.setImage(UIImage(named: "icon_pause_unsd_ipad"), forState: UIControlState.Normal)
            weakself!.btn_pause.setImage(UIImage(named: "icon_pause_sd_ipad"), forState: UIControlState.Highlighted)
            
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
        weak var weakself = self;
        RobotAPI.loginRobot(endpoint.registration_id, func: {
            print("登录机器成功")
            RobotAPI.addStatusListener(RotbotInfoManager.sharedInstance.current_endpoint_id!)
            RobotAPI.addOnlineListener(RotbotInfoManager.sharedInstance.current_endpoint_id!)
            RobotAPI.addPowerListener(RotbotInfoManager.sharedInstance.current_endpoint_id!)
            RobotAPI.getSeatTaskID(RotbotInfoManager.sharedInstance.current_endpoint_id!, func: { (tableId) in
                
                }, func: { (error) in
                    
            })
            RotbotInfoManager.sharedInstance.current_endpoint_id = endpoint.registration_id
            }) { (error) in
                weakself!.showMessage((error?.message)!)
        }
    }
    
}

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
            return 0
        case 5:
            return 1
        case 1,2:
            return 2
        case 3,4:
            return 3
        case 6,7,8:
            return 4
        case 9:
            return 5
        case 10,11,12:
            return 6
        case 13:
            return 7
        case 14,15,16:
            return 8
        case 17:
            return 9
        case 18,19:
            return 10
        case 20,21:
            return 11
        case 22,23,24:
            return 12
        case 25:
            return 13
        case 26,27:
            return 14
        case 28,29:
            return 15
        case 30,31:
            return 16
        case 32,33,34:
            return 17
        case 35:
            return 18
        case 36,37:
            return 19
        case 38,39:
            return 20
        case 40:
            return 21
        case 41:
            return 22
        case 42:
            return 23
        case 43:
            return 24
        case 44:
            return 25
        case 45,46:
            return 26
        case 47,48:
            return 27
        case 49:
            return 28
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

extension CtrlVC{
    
    
    func addBackButton(target:AnyObject, action:Selector){
        
        let image :UIImage = UIImage(named: "icon_back_unsd_ipad")!
        let buttonFrame :CGRect  = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: image.size.width + 10.0, height: self.navigationController!.navigationBar.frame.size.height))
        let button:UIButton = UIButton(type: UIButtonType.Custom)
        button.contentMode = UIViewContentMode.ScaleAspectFit;
        button.backgroundColor = UIColor.clearColor();
        button.frame = buttonFrame;
        button.setImage(image, forState: UIControlState.Normal)
        button.addTarget(target, action: action, forControlEvents: UIControlEvents.TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView:button)
    }
    
    func backAction(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}

extension CtrlVC{


    func mapChanged(switchState:UISwitch){
        
        if switchState.on {
            self.isChangle = true
        }else{
            self.isChangle = false
        }
        
    }

}


