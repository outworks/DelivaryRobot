//
//  RobotChooseVC.swift
//  DelivaryRobot
//
//  Created by ilikeido on 16/7/15.
//  Copyright © 2016年 ilikeido. All rights reserved.
//

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
        weak var weakself = self
        RobotAPI.loginRobot(endpoint.registration_id, func: {
            print("登录机器成功")
            RobotAPI.addStatusListener(RotbotInfoManager.sharedInstance.current_endpoint_id!)
            RobotAPI.addOnlineListener(RotbotInfoManager.sharedInstance.current_endpoint_id!)
            RobotAPI.addPowerListener(RotbotInfoManager.sharedInstance.current_endpoint_id!)
            RobotAPI.addLeaveSeatPointListener(RotbotInfoManager.sharedInstance.current_endpoint_id!)
            RotbotInfoManager.sharedInstance.current_endpoint_id = endpoint.registration_id
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let seatChooseVC = storyboard.instantiateViewControllerWithIdentifier("SeatChooseVC")
            weakself!.navigationController?.pushViewController(seatChooseVC, animated: true)
        }) { (error) in
            SCLAlertView().showError("提示", subTitle: (error?.message)!)
        }
    }
    
}



