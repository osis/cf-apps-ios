//
//  Keychain.swift
//  CF Apps
//
//  Created by Dwayne Forde on 2015-07-12.
//  Copyright (c) 2015 Dwayne Forde. All rights reserved.
//

import Foundation
import Locksmith

class Keychain {
    class var loginAccount: String { return "cfLogin" }
    
    class func hasCredentials() -> BooleanType {
        let (dictionary, error) = Locksmith.loadDataForUserAccount(loginAccount)
        return (error == nil) ? true : false
    }
    
    class func setCredentials(credentials: Dictionary<String, String>) -> NSError? {
        return Locksmith.saveData(credentials, forUserAccount: loginAccount)
    }
    
    class func getCredentials() -> (username: String?, password: String?) {
        let (dictionary, error) = Locksmith.loadDataForUserAccount(loginAccount)
        if let dictionary = dictionary {
            let _username: String = dictionary["username"] as! String
            let _password: String = dictionary["password"] as! String
            return (_username, _password)
        }
        return (nil,nil)
    }
}