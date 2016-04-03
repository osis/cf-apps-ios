//
//  CFSession.swift
//  CF Apps
//
//  Created by Dwayne Forde on 2015-12-21.
//  Copyright © 2015 Dwayne Forde. All rights reserved.
//

import Foundation
import UIKit

class CFSession {
    static let loginAuthToken = "Y2Y6"
    static let orgKey = "currentOrg"
    
    static var oauthToken: String?
    static var baseURLString: String {
        do {
            return try Keychain.getApiURL()
        } catch {
            return ""
        }
    }
    
    class func save(apiURL: String, authURL: String, loggingURL: String, username: String, password: String) {
        Keychain.setCredentials([
            "apiURL": apiURL,
            "authURL": authURL,
            "loggingURL": loggingURL,
            "username": username,
            "password": password
            ])
    }
    
    class func reset() {
        let domain = NSBundle.mainBundle().bundleIdentifier
        
        Keychain.clearCredentials()
        CFSession.oauthToken = nil
        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(domain!)
    }
    
    class func isEmpty() -> Bool {
        return (CFSession.oauthToken == nil || !Keychain.hasCredentials())
    }
    
    class func setOrg(orgGuid: String) {
        return NSUserDefaults.standardUserDefaults().setObject(orgGuid, forKey: orgKey)
    }
    
    class func getOrg() -> String? {
        return NSUserDefaults.standardUserDefaults().objectForKey(orgKey) as! String?
    }
    
    class func isOrgStale(currentOrgs: [String]) -> Bool {
        return CFSession.getOrg() == nil || !currentOrgs.contains(CFSession.getOrg()!)
    }
    
    class func logout(hadAuthError: Bool = false) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController: LoginViewController = storyboard.instantiateViewControllerWithIdentifier("LoginView") as! LoginViewController
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        loginViewController.authError = hadAuthError
        appDelegate.window!.rootViewController = loginViewController
        CFSession.reset()
    }
}