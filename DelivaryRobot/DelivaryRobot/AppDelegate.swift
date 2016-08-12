//
//  AppDelegate.swift
//  DelivaryRobot
//
//  Created by ilikeido on 16/7/11.
//  Copyright © 2016年 ilikeido. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
//        let params = RobotAPI.LoginParams(username: "886066",password: "123456")
//        RobotAPI.login(params, func: { (result) in
//            print(result.create_time)
            IQKeyboardManager.sharedManager().enable = true
            UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
            let navBar = UINavigationBar.appearance()
            navBar.barTintColor = UIColor.init(red: 62/255, green: 111/255, blue: 77/255, alpha: 1.0)
            var attrs = [String:AnyObject]()
            attrs[NSFontAttributeName] = UIFont.systemFontOfSize(21)
            attrs[NSForegroundColorAttributeName] = UIColor.whiteColor()
            navBar.titleTextAttributes = attrs
            navBar.translucent = false
        
        
            RobotAPI.getEndpoints(func: { (result) in
                for endPoint:EndPoint in result!{
                    print(endPoint.endpoin_name + endPoint.registration_id)
                }
                }, func: { (error) in
            })
//            }) { (error) in
//                print("error!")
//        }
        MQTTManager.sharedInstance.connect("FZ2h4sz1idwY8kUUR1jxF7L")
//        let globalQueueDefault = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0)
//        dispatch_async(globalQueueDefault) {
//            
//        }
        
        return true;
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        NSNotificationCenter.defaultCenter().postNotificationName("APPBACKGROUND", object: nil)
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        NSNotificationCenter.defaultCenter().postNotificationName(RobotNotification.APPBECOMEACTIVE, object: nil)
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

