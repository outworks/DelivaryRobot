//
//  BaseHttpAPI.swift
//  DelivaryRobot
//
//  Created by ilikeido on 16/7/13.
//  Copyright © 2016年 ilikeido. All rights reserved.
//

import Foundation
import Alamofire
import EVReflection
import SwiftyJSON

class BaseHttpAPI{
    
    class OKResult:EVObject{
        var message = ""
        var code = ""
    }
    
    class BaseError: EVObject {
        var message = ""
        var code = ""
        var server_time = ""
        var host_id = ""
    }
    
    static func request<T:NSObject>(method:Alamofire.Method,path:String,params:EVObject?,serverPort:String?,func successHandler:(result:T?)->Void,func errorHandler:(error:BaseError?)-> Void) -> Void {
        let dict = params?.toDictionary();
        request(method, path: path, paramsdict: dict, serverPort: serverPort, func: { (result:T?) in
            successHandler(result: result)
        }) { (error) in
            errorHandler(error: error)
        }
    }
    
    static func request<T:NSObject>(method:Alamofire.Method,path:String,params:EVObject?,func successHandler:(result:T?)->Void,func errorHandler:(error:BaseError?)-> Void) -> Void{
        request(method, path: path, params: params, serverPort: nil, func: { (result:T?) in
            successHandler(result: result)
        }) { (error) in
            errorHandler(error: error)
        }
    }
    
    static func request<T:NSObject>(method:Alamofire.Method,path:String,func successHandler:(result:T?)->Void,func errorHandler:(error:BaseError?)-> Void) -> Void{
        request(method, path: path, params: nil, serverPort: nil, func: { (result:T?) in
            successHandler(result: result)
        }) { (error) in
            errorHandler(error: error)
        }
    }
    
    static func request<T:NSObject>(method:Alamofire.Method,path:String,serverPort:String,func successHandler:(result:T?)->Void,func errorHandler:(error:BaseError?)-> Void) -> Void{
        request(method, path: path, params: nil, serverPort: serverPort, func: { (result:T?) in
            successHandler(result: result)
        }) { (error) in
            errorHandler(error: error)
        }
    }
    
    static func request<T:NSObject>(method:Alamofire.Method,path:String,params:EVObject?,serverPort:String?,func successHandler:(result:[T]?)->Void,func errorHandler:(error:BaseError?)-> Void) -> Void {
        let dict = params?.toDictionary();
        request(method, path: path, paramsdict: dict, serverPort: serverPort, func: { (result:[T]?) in
            successHandler(result: result)
        }) { (error) in
            errorHandler(error: error)
        }
    }
    
    
    static func request<T:NSObject>(method:Alamofire.Method,path:String,paramsdict:NSDictionary?,serverPort:String?,func successHandler:(result:T?)->Void,func errorHandler:(error:BaseError?)-> Void) -> Void {
        let dict = paramsdict;
        var port = "8092"
        if nil != serverPort {
            port = serverPort!
        }
        var headers = [
            "Content-Type": "application/json;charset=UTF-8"
        ]
        if port == "8092" {
            headers = [
                "Content-Type": "application/json;charset=UTF-8",
                "USER_KEY":RobotAPI.user_key
            ]
        }
        if nil != serverPort {
            port = serverPort!
        }
        Alamofire.request(method, String (format: "%@:%@%@", RobotAPI.DEFIND_HOST,port,path), parameters: dict as? [String : AnyObject],encoding:.JSON,headers:headers)
            .responseJSON { response in
                print(response.request)  // original URL request
                print(response.response) // URL response
                print(response.data)     // server data
                print(response.result)   // result of response serialization
                switch response.result {
                case .Success(let json):
                    print(json)
                    if let jsonDict = json as? NSDictionary{
                        if( nil == jsonDict["host_id"]){
                            let t = T()
                            if t.isKindOfClass(NSDictionary){
                                let t:T = jsonDict as! T
                                successHandler(result: t)
                                return
                            }
                            EVReflection.setPropertiesfromDictionary(jsonDict, anyObject: t)
                            successHandler(result: t)
                        }else{
                            let t = BaseError()
                            EVReflection.setPropertiesfromDictionary(jsonDict, anyObject: t)
                            errorHandler(error: t)
                        }
                    }else if let jsonArray = json as? NSArray{
                        let jsonDict = jsonArray[0] as! NSDictionary
                        if( nil == jsonDict["code"]){
                            let t = T()
                            if t.isKindOfClass(NSDictionary){
                                let t:T = jsonDict as! T
                                successHandler(result: t)
                                return
                            }
                            EVReflection.setPropertiesfromDictionary(jsonDict, anyObject: t)
                            successHandler(result: t)
                        }else{
                            let t = BaseError()
                            EVReflection.setPropertiesfromDictionary(jsonDict, anyObject: t)
                            errorHandler(error: t)
                        }
                    }else{
                        successHandler(result: nil)
                    }
                case .Failure(let error):
                    error.code;
                    let t = BaseError()
                    t.code = String("%d",error.code)
                    t.message = error.localizedDescription
                    errorHandler(error: t)
                }
        }
    }
    
    
    
    
    static func request<T:NSObject>(method:Alamofire.Method,path:String,paramsdict:NSDictionary?,serverPort:String?,func successHandler:(result:[T]?)->Void,func errorHandler:(error:BaseError?)-> Void) -> Void {
        let dict = paramsdict
        var port = "8092"
        if nil != serverPort {
            port = serverPort!
        }
        var headers = [
            "Content-Type": "application/json;charset=UTF-8"
        ]
        if port == "8092" {
            headers = [
                "Content-Type": "application/json;charset=UTF-8",
                "USER_KEY":RobotAPI.user_key
            ]
        }
        if nil != serverPort {
            port = serverPort!
        }
        Alamofire.request(method, String (format: "%@:%@%@", RobotAPI.DEFIND_HOST,port,path), parameters: dict as? [String : AnyObject],encoding:.JSON,headers:headers)
            .responseJSON { response in
                print(response.request)  // original URL request
                print(response.response) // URL response
                print(response.data)     // server data
                print(response.result)   // result of response serialization
                switch response.result {
                case .Success(let json):
                    print(json)
                    if let jsonDict = json as? NSDictionary{
                        if( nil == jsonDict["host_id"]){
                            let t = T()
                            if t.isKindOfClass(NSDictionary){
                                let t:T = jsonDict as! T
                                successHandler(result: [t])
                                return
                            }
                            EVReflection.setPropertiesfromDictionary(jsonDict, anyObject: t)
                            successHandler(result: [t])
                        }else{
                            let t = BaseError()
                            EVReflection.setPropertiesfromDictionary(jsonDict, anyObject: t)
                            errorHandler(error: t)
                        }
                    }else if let jsonArray = json as? NSArray{
                        var arrayResult:[T] = []
                        let t = T()
                        if t.isKindOfClass(NSDictionary){
                            let t:[T] = jsonArray as! [T]
                            successHandler(result:t)
                            return
                        }
                        for datadict in jsonArray{
                            let t = T()
                            EVReflection.setPropertiesfromDictionary(datadict as! NSDictionary, anyObject: t)
                            arrayResult.append(t)
                        }
                        successHandler(result:arrayResult)
                    }else{
                        successHandler(result: [])
                    }
                case .Failure(let error):
                    if nil != response.data {
                        let dataString = NSString(data: response.data!, encoding: NSUTF8StringEncoding)
                        print(dataString)
                    }
                    error.code;
                    let t = BaseError()
                    t.code = String("%d",error.code)
                    t.message = error.localizedDescription
                    errorHandler(error: t)
                }
        }
    }
    
    
    
    static func request<T:NSObject>(method:Alamofire.Method,path:String,params:EVObject?,func successHandler:(result:[T]?)->Void,func errorHandler:(error:BaseError?)-> Void) -> Void{
        request(method, path: path, params: params, serverPort: nil, func: { (result:[T]?) in
            successHandler(result: result)
        }) { (error) in
            errorHandler(error: error)
        }
    }
    
    static func request<T:NSObject>(method:Alamofire.Method,path:String,serverPort:String,func successHandler:(result:[T]?)->Void,func errorHandler:(error:BaseError?)-> Void) -> Void{
        request(method, path: path, params: nil, serverPort: serverPort, func: { (result:[T]?) in
            successHandler(result: result)
        }) { (error) in
            errorHandler(error: error)
        }
    }
    
    static func request<T:NSObject>(method:Alamofire.Method,path:String,func successHandler:(result:[T]?)->Void,func errorHandler:(error:BaseError?)-> Void) -> Void{
        request(method, path: path, params: nil, serverPort: nil, func: { (result:[T]?) in
            successHandler(result: result)
        }) { (error) in
            errorHandler(error: error)
        }
    }
    
    
    
}