/*********************************************************************
 * Copyright © 2016年 NetDragon. All rights reserved.
 * Date: 16/7/25
 * Name: HCat
 **********************************************************************
 * @文件名称: RobotChooseCell.swift
 * @文件描述: 选择机器Cell
 * @补充说明: 无
 *********************************************************************/

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
    /**************** 显示电量多少 *****************/
    @IBOutlet weak var lb_power: UILabel!
    
    
    var power:NSNumber?{
    
        /* 属性监视器方法 
         * 1.willSet 在设置新的值之前调用
         * 2.didSet  在新的值被设置之后立即调用
         */
        
        didSet{
        
            if self.power?.intValue < 30 {
                img_powerbg.image = UIImage(named:"icon_lowPower_bg")
                img_powerColoer.image = UIImage(named: "icon_lowPower_color")
                lb_power.textColor = UIColor(red: 199.0/255.0, green: 2.0/255.0, blue: 1.0/255.0, alpha: 1.0)
                
            } else{
                img_powerbg.image = UIImage(named:"icon_commonPower_bg")
                img_powerColoer.image = UIImage(named: "icon_common_color")
                 lb_power.textColor = UIColor.blackColor()
            }
            
            layout_top_power.constant = CGFloat(17.0 - 0.17 * (self.power?.floatValue)! + 2)
            
            lb_power.text = (self.power?.stringValue)! + "%"
            
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
