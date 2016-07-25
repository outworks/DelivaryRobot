//
//  RobotChooseCell.swift
//  DelivaryRobot
//
//  Created by huanglurong on 16/7/25.
//  Copyright © 2016年 ilikeido. All rights reserved.
//

import UIKit


class RobotChooseCell: UITableViewCell {

    /**************** 显示机器号 *****************/
    @IBOutlet weak var lb_title: UILabel!
    
    /**************** 显示电量的背景图片 *****************/
    @IBOutlet weak var img_powerbg: UIImageView!
    /**************** 显示电量多少图片 *****************/
    @IBOutlet weak var img_powerColoer: UIImageView!
    /**************** 显示电量距离上面的layout *****************/
    @IBOutlet weak var layout_top_power: NSLayoutConstraint!
    
    var power:NSNumber?{
    
        /* 属性监视器方法 
         * 1.willSet 在设置新的值之前调用
         * 2.didSet  在新的值被设置之后立即调用
         */
        
        didSet{
        
            if self.power?.intValue < 30 {
                img_powerbg.image = UIImage(named:"icon_lowPower_bg")
                img_powerColoer.image = UIImage(named: "icon_lowPower_color")
                
                
            } else{
                img_powerbg.image = UIImage(named:"icon_commonPower_bg")
                img_powerColoer.image = UIImage(named: "icon_common_color")
            }
            
            layout_top_power.constant = CGFloat(17.0 - 0.17 * (self.power?.floatValue)! + 2)
            
        }
    
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
       
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
