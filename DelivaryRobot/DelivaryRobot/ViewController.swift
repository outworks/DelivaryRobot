/*********************************************************************
 * Copyright © 2016年 NetDragon. All rights reserved.
 * Date: 16/7/05
 * Name: ilikeido
 **********************************************************************
 * @文件名称: ViewController.swift
 * @文件描述: 登录场景
 * @补充说明: 无
 *********************************************************************/

import UIKit

class ViewController: UIViewController,UITextFieldDelegate {

    var storyBoard:UIStoryboard?
    
    @IBOutlet weak var btn_username: UITextField!
    @IBOutlet weak var btn_password: UITextField!
    @IBOutlet weak var btn_rememberPwd: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.btn_username.text = NSUserDefaults.standardUserDefaults().stringForKey("ACCOUNT_NAME")
        self.btn_password.text = NSUserDefaults.standardUserDefaults().stringForKey("ACCOUNT_PASSWORD")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
       
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginAction(sender: AnyObject) {
        if (btn_username.text!.isEmpty){
            let alert = UIAlertView(title: "提示", message: "请输入用户名", delegate: nil, cancelButtonTitle: "确定")
            alert.show()
            return
        }
        if (btn_password.text!.isEmpty){
            let alert = UIAlertView(title: "提示", message: "请输入密码", delegate: nil, cancelButtonTitle: "确定")
            alert.show()
            return
        }
        
        let loginParams = RobotAPI.LoginParams(username: btn_username.text!, password: btn_password.text!)
        weak var weakself = self
        RobotAPI.login(loginParams, func: { (result) in
            
            if weakself!.btn_rememberPwd.selected {
                
                NSUserDefaults.standardUserDefaults().setObject(loginParams.account_name, forKey: "ACCOUNT_NAME")
                NSUserDefaults.standardUserDefaults().setObject(loginParams.password, forKey:"ACCOUNT_PASSWORD")
                NSUserDefaults.standardUserDefaults().synchronize()
            }else{
            
                NSUserDefaults.standardUserDefaults().setObject("", forKey: "ACCOUNT_NAME")
                NSUserDefaults.standardUserDefaults().setObject("", forKey:"ACCOUNT_PASSWORD")
                NSUserDefaults.standardUserDefaults().synchronize()
            }
            
            var storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
               storyboard = UIStoryboard(name: "Main", bundle: nil)
            }else{
               storyboard = UIStoryboard(name: "Main_ipad", bundle: nil)
            }
            
            
            //let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let ctrlVC = storyboard.instantiateViewControllerWithIdentifier("RobotChooseVC")
            weakself!.navigationController?.pushViewController(ctrlVC, animated: true)
            }) { (error) in
                let alert = UIAlertView(title: "提示", message: error?.message, delegate: nil, cancelButtonTitle: "确定")
                alert.show()
                return
        }
        
        
    }
    
    
    @IBAction func rememberButtonAction(sender: AnyObject) {
        
        btn_rememberPwd.selected = !btn_rememberPwd.selected
        
    }
    

    func textFieldShouldReturn(textField: UITextField) -> Bool{
        textField.resignFirstResponder();
        return true
    }
    

    
}

