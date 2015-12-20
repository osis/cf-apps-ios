//
//  CFApi.swift
//  CF Apps
//
//  Created by Dwayne Forde on 2015-07-12.
//  Copyright (c) 2015 Dwayne Forde. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class CFApi {
    class func login(success: () -> Void, error: () -> Void) {
        let (username, password) = Keychain.getCredentials()
        
        Alamofire.request(CF.Login(username!, password!))
            .validate()
            .responseJSON { (_, _, result) in
                if (result.isSuccess) {
                    let json = JSON(result.value!)
                    let token = json["access_token"].string
                    CF.oauthToken = token
                    Keychain.setCredentials([
                        "username": username!,
                        "password": password!
                        ])
                    success()
                } else {
                    error()
                }
        }
    }
    
    class func organizations(success: (json: JSON) -> Void, error: (statusCode: Int) -> Void) {
        Alamofire.request(CF.Orgs())
            .validate()
            .responseJSON { (_, response, result) in
                responseHandler(response!, result: result, success: success, error: error)
        }
    }
    
    class func applications(orgGuid: String, page: Int, success: (json: JSON) -> Void, error: (statusCode: Int) -> Void) {
        Alamofire.request(CF.Apps(orgGuid, page))
            .validate()
            .responseJSON { (_, response, result) in
                responseHandler(response!, result: result, success: success, error: error)
        }
    }
    
    class func spaces(appGuids: [String], success: (json: JSON) -> Void, error: (statusCode: Int) -> Void) {
        Alamofire.request(CF.Spaces(appGuids))
            .validate()
            .responseJSON  { (_, response, result) in
                responseHandler(response!, result: result, success: success, error: error)
            }
    }
    
    class private func responseHandler(response: NSHTTPURLResponse, result: Result<AnyObject>, success: (json: JSON) -> Void, error: (statusCode: Int) -> Void) {
        if (result.isSuccess) {
            success(json: JSON(result.value!))
        } else {
            if (response.statusCode == 401) {
//                self.login(success, error: {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let loginViewController = storyboard.instantiateInitialViewController()
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    appDelegate.window!.rootViewController = loginViewController
//                })
            }
            error(statusCode: response.statusCode)
        }
    }
}