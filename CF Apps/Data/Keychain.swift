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
        let dictionary = Locksmith.loadDataForUserAccount(loginAccount)
        return ((dictionary?.isEmpty) != nil) ? true : false
    }
    
    class func setCredentials(credentials: Dictionary<String, String>) -> NSError? {
        do {
         try Locksmith.saveData(credentials, forUserAccount: loginAccount)
        } catch let error as NSError {
            return error
        }
        return nil
    }
    
    class func getCredentials() -> (username: String?, password: String?) {
        let dictionary = Locksmith.loadDataForUserAccount(loginAccount)
        if ((dictionary?.isEmpty) != nil) {
            let _username: String = dictionary!["username"] as! String
            let _password: String = dictionary!["password"] as! String
            return (_username, _password)
        }
        return (nil,nil)
    }
}