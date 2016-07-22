//
//  RobotChooseVC.swift
//  DelivaryRobot
//
//  Created by ilikeido on 16/7/15.
//  Copyright © 2016年 ilikeido. All rights reserved.
//

import Foundation
import SCLAlertView

class SeatChooseVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var lb_status: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var seatList = Array<SeatData>()
    
    var waitSeat:SeatData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.seatList = RobotAPI.getSeatList()
        self.tableView.reloadData()
        
        weak var weakself = self
        NSNotificationCenter.defaultCenter().addObserver(weakself!, selector: #selector(SeatChooseVC.updateStatus), name: RobotNotification.STATUS_CHANGE, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(weakself!, selector: #selector(SeatChooseVC.updateStatus), name: RobotNotification.POWER_CHANGE, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(weakself!, selector: #selector(SeatChooseVC.updateStatus), name: RobotNotification.ONLINE_CHANGE, object: nil)
        
        self.updateUI()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  
}

extension SeatChooseVC{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.seatList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let seatData = self.seatList[indexPath.row]
        var cell = tableView.dequeueReusableCellWithIdentifier("CELL")
        if nil == cell {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "CELL")
        }
        cell?.textLabel?.text = seatData.seat
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let seatData = self.seatList[indexPath.row]
        self.waitSeat = seatData
        let alertView = SCLAlertView()
        weak var weakself = self
        alertView.addButton("确定"){
            weakself!.sendCmd()
        }
        alertView.showInfo("提示", subTitle: "点击确定开始送餐")

    }
    
    func sendCmd(){
        
        RobotAPI.goSeat(RotbotInfoManager.sharedInstance.current_endpoint_id!, seat: self.waitSeat!, func: {
            
        }) { (error) in
            
        }
    }
    
    @objc func updateStatus(notification: NSNotification){
        let info = notification.userInfo!
        let endpoint_id:String = info["endpoint_id"] as! String
        if endpoint_id == RotbotInfoManager.sharedInstance.current_endpoint_id {
            self.updateUI()
        }
    }
    
    func updateUI(){
        if nil != RotbotInfoManager.sharedInstance.current_endpoint_id {
            let robotInfo = RotbotInfoManager.sharedInstance.robotWithEndpointId(RotbotInfoManager.sharedInstance.current_endpoint_id!)
            let online = robotInfo.online ? "在线":"断线"
            self.lb_status.text = "电量：" + String(robotInfo.power) + "\n状态:" + robotInfo.statusName() + "\n在线状态:" + online
        }
        
    }
    
}

