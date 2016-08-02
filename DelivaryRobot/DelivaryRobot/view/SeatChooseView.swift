//
//  SeatChooseView.swift
//  DelivaryRobot
//
//  Created by huanglurong on 16/7/28.
//  Copyright © 2016年 ilikeido. All rights reserved.
//

import UIKit

class SeatChooseView: UIView {

    @IBOutlet weak var imgv_bg: UIImageView!
    @IBOutlet weak var v_seat: UIView!
    
    var selectTag = 0
    
    var waitSeat:SeatData?
   
    var seatList = Array<SeatData>(){
    
        didSet{
        
        self.clearTagStatus()
         self.setUpSeatView()
            

        }
    
    }
    
    func setUpSeatView(){
        
        let buttons = getTagButtons()
        for button in buttons {
            button.hidden = true;
        }
        
        for i in 0 ..< seatList.count  {
            
            let seatData : SeatData = self.seatList[i]
            let buttons = getTagButtons()
            
            for button in buttons {
                
                if seatData.tag == button.tag {
                    button.hidden = false;
                    break
                }
            }
        
        }
    
    }
    

    func showView() {
        
        self.clearTagStatus()
        
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
    
    func hideView() {
        
        UIView.animateWithDuration(0.2, animations: {
            
            self.alpha = 0
            }, completion: { finished in
                self.removeFromSuperview()
                
        })
    }
    

}


extension SeatChooseView {

    /**
     返回
     - parameter sender:
     */

    @IBAction func backSeatAction(sender: AnyObject) {
        
        self.hideView()
        
    }

    /**
     确定
     - parameter sender:
     */

    @IBAction func determineSeatAction(sender: AnyObject) {
       
        if self.selectTag != 0 {
            
            for i in 0 ..< seatList.count  {
                
                let seatData : SeatData = self.seatList[i]
                
                if self.selectTag == seatData.tag {
                    
                    self.waitSeat = seatData
                     self.sendCmd()
                    break
                }
            
            }
        
        }else{
            
            let alertView:UIAlertView = UIAlertView(title: "提示", message: "请选择桌号", delegate: nil, cancelButtonTitle: "确定")
            alertView.show()
            
        }
        
        
    }
    
    /**
     选中
     - parameter sender:
     */
    
    @IBAction func chooseSeatAction(sender: AnyObject) {
      
        let button = sender as! UIButton
        
        self.selectTag = button.tag
        
        self.clearTagStatus()

        button.setBackgroundImage(UIImage(named: "icon_seat_sd_ipad"), forState: UIControlState.Normal)
         button.setBackgroundImage(UIImage(named: "icon_seat_sd_ipad"), forState: UIControlState.Highlighted)
        button.titleLabel?.textColor = UIColor.whiteColor()
        
        
        
    }
    

}

extension SeatChooseView{

    func getTagButtons() -> [UIButton]{
        let tempviews = v_seat?.subviews
        var results = [UIButton]()
        for view in tempviews! {
            
            if view.isKindOfClass(UIButton) {
                let button = view as! UIButton
                if button.tag != 0 {
                    results.append(button)
                }
            }
           
            
        }
        return results
    }
    
    func clearTagStatus() -> Void{
        let buttons = getTagButtons()
        
        for button in buttons {
            button.setBackgroundImage(UIImage(named: "icon_seat_unsd_ipad"), forState: UIControlState.Normal)
             button.setBackgroundImage(UIImage(named: "icon_seat_sd_ipad"), forState: UIControlState.Highlighted)
            button.titleLabel?.textColor = UIColor(red: 202/255.0, green: 202/255.0, blue: 202/255.0, alpha: 1.0)
        }
    }
    
}


extension SeatChooseView{


    func sendCmd(){
        weak var weakself = self;
        RobotAPI.goSeat(RotbotInfoManager.sharedInstance.current_endpoint_id!, seat: self.waitSeat!, func: {
            weakself?.hideView()
        }) { (error) in
            
        }
    }
    


}
