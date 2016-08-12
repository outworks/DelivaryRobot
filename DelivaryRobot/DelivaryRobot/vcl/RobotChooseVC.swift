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
        //        weak var weakself = self
        
        //***************  监听设备在线变化，如果某个设备在线变化了则刷新列表 *************//
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.updateListStatus), name: RobotNotification.ONLINE_CHANGE, object: nil)
        
        self.addBackButton(self, action: #selector(self.backAction))
        
        //        RobotAPI.getEndpoints(func: { (result) in
        //            weakself!.endpoints =  self.endpoints + result!
        //            weakself!.tableView.reloadData()
        //        }) { (error) in
        //
        //        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        weak var weakself = self
        
        RobotAPI.getEndpoints(func: { (result) in
            weakself!.endpoints.removeAll()
            weakself!.endpoints =  self.endpoints + result!
            weakself!.tableView.reloadData()
        }) { (error) in
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func updateListStatus(notification: NSNotification){
        
        weak var weakself = self
        RobotAPI.getEndpoints(func: { (result) in
            weakself!.endpoints.removeAll()
            weakself!.endpoints =  self.endpoints + result!
            weakself!.tableView.reloadData()
        }) { (error) in
            
        }
        
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
            RobotAPI.addTableIdListener(RotbotInfoManager.sharedInstance.current_endpoint_id!)
            RobotAPI.addSubstatusListener(RotbotInfoManager.sharedInstance.current_endpoint_id!)
            RobotAPI.addNoticeListener(RotbotInfoManager.sharedInstance.current_endpoint_id!)
            RotbotInfoManager.sharedInstance.current_endpoint_id = endpoint.registration_id
            RotbotInfoManager.sharedInstance.current_endpoin_name = endpoint.endpoin_name
            
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
                
                var storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
                    storyboard = UIStoryboard(name: "Main", bundle: nil)
                }else{
                    storyboard = UIStoryboard(name: "Main_ipad", bundle: nil)
                }
                
                let ctrlVC = storyboard.instantiateViewControllerWithIdentifier("CtrlVC")
                weakself!.navigationController?.pushViewController(ctrlVC, animated: true)
            })
            
            
            //            RobotAPI.getSeatTaskID(RotbotInfoManager.sharedInstance.current_endpoint_id!, func: { (tableId) in
            //
            //                }, func: { (error) in
            //
            //            })
            //            var storyboard = UIStoryboard(name: "Main", bundle: nil)
            //
            //            if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
            //                storyboard = UIStoryboard(name: "Main", bundle: nil)
            //            }else{
            //                storyboard = UIStoryboard(name: "Main_ipad", bundle: nil)
            //            }
            //
            //            let ctrlVC = storyboard.instantiateViewControllerWithIdentifier("CtrlVC")
            //            weakself!.navigationController?.pushViewController(ctrlVC, animated: true)
        }) { (error) in
            SCLAlertView().showError("提示", subTitle: ("机器离线"))
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        
        return 70.0
    }
    
}

extension RobotChooseVC{
    
    
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

