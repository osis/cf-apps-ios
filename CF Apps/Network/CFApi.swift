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
            .responseJSON { (request, response, data, _error) in
                if (_error != nil) {
                    error()
                } else {
                    let json = JSON(data!)
                    let token = json["access_token"].string
                    CF.oauthToken = token
                    Keychain.setCredentials([
                        "username": username,
                        "password": password
                        ])
                    success()
                }
        }
    }
}