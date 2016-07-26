/*********************************************************************
 * Copyright © 2016年 NetDragon. All rights reserved.
 * Date: 16/7/05
 * Name: ilikeido
 **********************************************************************
 * @文件名称: RobotChooseVC.swift
 * @文件描述: 选择机器场景
 * @补充说明: 无
 *********************************************************************/

import UIKit
import Foundation
import SCLAlertView

class RobotChooseVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var endpoints = Array<EndPoint>()
    
    @IBOutlet weak var tableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        weak var weakself = self
    
        RobotAPI.getEndpoints(func: { (result) in
            weakself!.endpoints =  self.endpoints + result!
            weakself!.tableView.reloadData()
        }) { (error) in
            
        }
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension RobotChooseVC{
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.endpoints.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let CellIndentifier:String = "RobotChooseCell"
        
        let cell:RobotChooseCell = tableView.dequeueReusableCellWithIdentifier(CellIndentifier, forIndexPath: indexPath) as! RobotChooseCell
       
        let endpoint:EndPoint = self.endpoints[indexPath.row]
        cell.lb_title.text = endpoint.endpoin_name
        let i = NSNumber(int:(Int32(endpoint.battery_percent))!)
       
        cell.power = i
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let endpoint = self.endpoints[indexPath.row]
        RotbotInfoManager.sharedInstance.current_endpoint_id = endpoint.registration_id
        print(endpoint.endpoin_name + "_" + endpoint.registration_id)
        weak var weakself = self
        RobotAPI.loginRobot(endpoint.registration_id, func: {
            print("登录机器成功")
            RobotAPI.addStatusListener(RotbotInfoManager.sharedInstance.current_endpoint_id!)
            RobotAPI.addOnlineListener(RotbotInfoManager.sharedInstance.current_endpoint_id!)
            RobotAPI.addPowerListener(RotbotInfoManager.sharedInstance.current_endpoint_id!)
            RobotAPI.addLeaveSeatPointListener(RotbotInfoManager.sharedInstance.current_endpoint_id!)
            RobotAPI.addDeviceStatusListener(RotbotInfoManager.sharedInstance.current_endpoint_id!)
            RotbotInfoManager.sharedInstance.current_endpoint_id = endpoint.registration_id
            
            var storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
                storyboard = UIStoryboard(name: "Main", bundle: nil)
            }else{
                storyboard = UIStoryboard(name: "Main_ipad", bundle: nil)
            }
            
            let ctrlVC = storyboard.instantiateViewControllerWithIdentifier("CtrlVC")
            weakself!.navigationController?.pushViewController(ctrlVC, animated: true)
        }) { (error) in
            SCLAlertView().showError("提示", subTitle: (error?.message)!)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
    
        return 70.0
    }
    
}



