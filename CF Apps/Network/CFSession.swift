//
//  CFSession.swift
//  CF Apps
//
//  Created by Dwayne Forde on 2015-12-21.
//  Copyright © 2015 Dwayne Forde. All rights reserved.
//

import Foundation

class CFSession {
    class func save(apiURL: String, authURL: String, username: String, password: String) {
        Keychain.setCredentials([
            "apiURL": apiURL,
            "authURL": authURL,
            "username": username,
            "password": password
            ])
    }
    
    class func reset() {
        Keychain.clearCredentials()
        CF.apiURL = nil
        CF.oauthToken = nil
    }
}

