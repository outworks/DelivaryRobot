/*********************************************************************
 * Copyright © 2016年 NetDragon. All rights reserved.
 * Date: 16/7/05
 * Name: ilikeido
 **********************************************************************
 * @文件名称: RobotSettingView.swift
 * @文件描述: 机器人设置视图
 * @补充说明: 无
 *********************************************************************/

import UIKit

class RobotSettingView: UIView {

    @IBOutlet weak var imgv_bg: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    var actValue : Int = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        weak var weakSelf = self
       
        
        RobotAPI.getRobotAction(RotbotInfoManager.sharedInstance.current_endpoint_id!, usAct:2, nParamType:2, nValue:0, func: { (actValue) in
            weakSelf!.actValue = actValue
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.reloadData()
            
            }, func: { (error) in
                
        })
       
        
//        fatalError("init(coder:) has not been implemented")
    }
    
    
    func showView() {
        
        imgv_bg.alpha = 0
        self.alpha = 1
        
        let rv = UIApplication.sharedApplication().windows.first! as UIWindow
        rv.addSubview(self)
        self.frame = rv.bounds
        
        UIView.animateWithDuration(0.2, animations: {
            self.imgv_bg.alpha = 0.65
            self.sendSubviewToBack(self.imgv_bg)
            
            }, completion: { finished in
                
        })
        
    }
    
    
    
    func hideView(animate:Bool) {
        
        if animate == true {
            
            UIView.animateWithDuration(0.2, animations: {
    
                self.alpha = 0
                }, completion: { finished in
                    self.removeFromSuperview()
                    
            })

        }else {
            self.alpha = 0
            self.removeFromSuperview()
            
        }
        
    }
    
    

}


// MARK : 按钮事件

extension RobotSettingView{

    /**
     返回
     - parameter sender:
     */
    
    @IBAction func backSeatAction(sender: AnyObject) {
        
       self.hideView(true)
        
    }

}

// MARK: tableView协议

extension RobotSettingView:UITableViewDelegate,UITableViewDataSource{

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        return 60
    
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("CELL")
        if nil == cell {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "CELL")
            
            let slider:UISlider  = UISlider(frame: CGRect(x: 0, y: 0, width: 150, height: 50))
            slider.center = CGPoint(x: 250, y: 30)
            slider.minimumValue = 0
            slider.maximumValue = 100
            slider.value = Float(self.actValue)
            cell?.contentView.addSubview(slider)
            slider.minimumTrackTintColor = UIColor(red: 62/255.0, green: 111/255.0, blue: 77/255.0, alpha: 1.0)
            slider.maximumTrackTintColor = UIColor.lightGrayColor()
            slider.tag = 100
            slider.addTarget(self, action:#selector(RobotSettingView.sliderDidChange(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            let image_line:UIImageView = UIImageView(frame: CGRect(x: 10, y: 59, width: 355, height: 1))
            image_line.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
            cell?.contentView.addSubview(image_line)
            
            
        }
        
        cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        let slider = cell?.viewWithTag(100) as? UISlider
        
        if indexPath.row == 0 {
            cell?.textLabel?.text = "机器人名称"
            print(RotbotInfoManager.sharedInstance.current_endpoin_name!)
            cell?.detailTextLabel?.text = RotbotInfoManager.sharedInstance.current_endpoin_name!
            slider?.hidden = true
            
            
        }else{
            cell?.textLabel?.text = "播放音量"
            slider?.hidden = false
            slider!.value = Float(self.actValue)
            
            
        }
        
    
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    
    }


    func sliderDidChange(slider:UISlider){
    
        print(slider.value)
        self.actValue = Int(slider.value)
        
        RobotAPI.getRobotAction(RotbotInfoManager.sharedInstance.current_endpoint_id!, usAct:1, nParamType:2, nValue:self.actValue, func: { (actValue) in
           
            self.tableView.reloadData()
            
            }, func: { (error) in
                
        })
        
    }


    


}
