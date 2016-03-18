//
//  CFSession.swift
//  CF Apps
//
//  Created by Dwayne Forde on 2015-12-21.
//  Copyright © 2015 Dwayne Forde. All rights reserved.
//

import Foundation

class CFSession {
    static let loginAuthToken = "Y2Y6"
    
    static var oauthToken: String?
    static var baseURLString: String {
        do {
            return try Keychain.getApiURL()
        } catch {
            return ""
        }
    }
    
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
        CFSession.oauthToken = nil
    }
    
    class func isEmpty() -> Bool {
        return (CFSession.oauthToken == nil || !Keychain.hasCredentials())
    }
}

