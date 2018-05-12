import Foundation
import UIKit
import CFoundry

class Session {
    static let accountKey = "currentAccount"
    static let orgKey = "currentOrg"
    
    class func account(_ account: CFAccount) {
        UserDefaults.standard.set(account.account, forKey: accountKey)
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "AccountSwitched"), object: nil)
    }
    
    class func account() -> CFAccount? {
        if let key = currentAccountKey() {
            return AccountStore.read(key)
        }
        return nil
    }
    
    class func isCurrent(_ account: CFAccount) -> Bool {
        if let sessionAccount = self.account() {
            return sessionAccount.account == account.account
        }
        return false
    }
    
    class func org(_ orgGuid: String) {
        return UserDefaults.standard.set(orgGuid, forKey: orgKey)
    }
    
    class func org() -> String? {
        return UserDefaults.standard.object(forKey: orgKey) as! String?
    }
    
    class func reset() {
        //TODO: CFAPI Reset?
        CFApi.logout()
        
        UserDefaults.standard.removeObject(forKey: accountKey)
        UserDefaults.standard.removeObject(forKey: orgKey)
    }
    
    class func logout(_ isError: Bool) {
        if let account = Session.account() {
            try! AccountStore.delete(account)
        }
        
        reset()
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        if AccountStore.isEmpty() {
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let loginController = storyboard.instantiateViewController(withIdentifier: "LoginView") as! LoginViewController
            loginController.authError = isError
            delegate.window?.rootViewController = loginController
        } else {
            let appsController = delegate.showAppsScreen()
            appsController.performSegue(withIdentifier: "accounts", sender: nil)
        }
    }
    
    fileprivate class func currentAccountKey() -> String? {
        return UserDefaults.standard.object(forKey: accountKey) as! String?
    }
}

