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
    class func login(username: String, password: String, success: () -> Void, error: () -> Void) {
        Alamofire.request(CF.Login(username, password))
            .validate()
            .responseJSON { (_, _, result) in
                if (result.isSuccess) {
                    let json = JSON(result.value!)
                    let token = json["access_token"].string
                    CF.oauthToken = token
                    Keychain.setCredentials([
                        "username": username,
                        "password": password
                        ])
                    success()
                } else {
                    error()
                }
        }
    }
}