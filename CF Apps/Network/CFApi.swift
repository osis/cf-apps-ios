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

class CFResponse: NSHTTPURLResponse {
    static func stringForStatusCode(statusCode: Int?, url: NSURL?) -> String {
        if let c = statusCode, let u = url {
            let statusString = super.localizedStringForStatusCode(c)
            return "\(c) \((statusString)) response from \(u)"
        } else {
            return "Invalid URL"
        }
    }
    
    static func stringForLoginStatusCode(statusCode: Int?, url: NSURL?) -> String {
        return (statusCode == 401) ? "Incorrect credentials" : stringForStatusCode(statusCode, url: url)
    }
}

class CFApi {
    class func info(apiURL: String, success: (json: JSON) -> Void, error: (statusCode: Int?, url: NSURL?) -> Void) {
        Alamofire.request(CF.Info(apiURL))
            .validate()
            .responseJSON { response in
                if (response.result.isSuccess) {
                    let json = JSON(response.result.value!)
                    success(json: json)
                } else {
                    error(statusCode: response.response?.statusCode, url: response.request?.URL)
                }
        }
    }

    class func login(authURL: String, username: String, password: String, success: () -> Void, error: (statusCode: Int?, url: NSURL?) -> Void) {
        Alamofire.request(CF.Login(authURL, username, password))
            .validate()
            .responseJSON { response in
                if (response.result.isSuccess) {
                    let json = JSON(response.result.value!)
                    let token = json["access_token"].string
                    CF.oauthToken = token
                    success()
                } else {
                    error(statusCode: response.response?.statusCode, url: response.request?.URL)
                }
        }
    }
    
    class func orgs(success: (json: JSON) -> Void, error: (statusCode: Int) -> Void) {
        if (!CFSession.isEmpty()) {
            Alamofire.request(CF.Orgs())
                .validate()
                .responseJSON { response in
                    responseHandler(response, success: success, error: error, recover: {
                        self.orgs(success, error: error)
                    })
            }
        } else {
            self.retryLogin({
                self.orgs(success, error: error)
            })
        }
    }
    
    class func apps(orgGuid: String, page: Int, success: (json: JSON) -> Void, error: (statusCode: Int) -> Void) {
        if (!CFSession.isEmpty()) {
            Alamofire.request(CF.Apps(orgGuid, page))
                .validate()
                .responseJSON { response in
                    responseHandler(response, success: success, error: error, recover: {
                        self.apps(orgGuid, page: page, success: success, error: error)
                    })
            }
        }
    }
    
    class func appSummary(appGuid: String, success: (json: JSON) -> Void, error: (statusCode: Int) -> Void) {
        if (!CFSession.isEmpty()) {
            Alamofire.request(CF.AppSummary(appGuid))
                .validate()
                .responseJSON { response in
                    responseHandler(response, success: success, error: error, recover: {
                        self.appSummary(appGuid, success: success, error: error)
                    })
            }
        }
    }
    
    class func appStats(appGuid: String, success: (json: JSON) -> Void, error: (statusCode: Int) -> Void) {
        if (!CFSession.isEmpty()) {
            Alamofire.request(CF.AppStats(appGuid))
                .validate()
                .responseJSON { response in
                    responseHandler(response, success: success, error: error, recover: {
                        self.appStats(appGuid, success: success, error: error)
                    })
            }
        }
    }
    
    class func spaces(appGuids: [String], success: (json: JSON) -> Void, error: (statusCode: Int) -> Void) {
        if (!CFSession.isEmpty()) {
            Alamofire.request(CF.Spaces(appGuids))
                .validate()
                .responseJSON  { response in
                    responseHandler(response, success: success, error: error, recover: {
                        self.spaces(appGuids, success: success, error: error)
                    })
                    
            }
        }
    }
    
    class private func responseHandler(response: Response<AnyObject, NSError>, success: (json: JSON) -> Void, error: (statusCode: Int) -> Void, recover: () -> Void) {
        
        if (response.result.isSuccess) {
            let json = sanitizeJson(JSON(response.result.value!))
            success(json: json)
        } else {
            if (response.response!.statusCode == 401) {
                self.retryLogin(recover)
            }
            error(statusCode: response.response!.statusCode)
        }
    }
    
    class private func retryLogin(success: () -> Void) {
        let (authURL, username, password) = Keychain.getCredentials()
        
        self.login(authURL!, username: username!, password: password!, success: success, error: { _ in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginViewController: LoginViewController = storyboard.instantiateViewControllerWithIdentifier("LoginView") as! LoginViewController
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            loginViewController.authError = true
            appDelegate.window!.rootViewController = loginViewController
            CFSession.reset()
        })
    }
    
    class private func sanitizeJson(json: JSON) -> JSON {
        var sanitizedJson = json
        
        for (key, subJson) in json["resources"] {
            let index = Int(key)!
            
            for (entityKey, entitySubJson) in subJson["entity"] {
                sanitizedJson["resources"][index][entityKey] = entitySubJson
            }
            sanitizedJson["resources"][index]["entity"] = nil
            
            for (metadataKey, metadataSubJson) in subJson["metadata"] {
                sanitizedJson["resources"][index][metadataKey] = metadataSubJson
            }
            sanitizedJson["resources"][index]["metadata"] = nil
        }
        
        return sanitizedJson
    }
}