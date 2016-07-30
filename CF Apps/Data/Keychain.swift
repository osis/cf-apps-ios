import Foundation
import Locksmith
import SwiftyJSON

// Accounts are stored in the Keychain.
// Reference to those accounts are stored in NSUserDefaults.

enum CFAccountError: ErrorType {
    case NotFound
}

class CFAccountStore {
    class var accountsKey: String { return "CFAccounts" }
    class var accountListKey: String { return "CFAccountList" }
    
    class func create(account: CFAccount) throws {
        do {
            try account.createInSecureStore()
            saveKey(account.account)
        } catch LocksmithError.Duplicate {
            try account.updateInSecureStore()
        }
    }
    
    class func read(key: String) -> CFAccount? {
        if let data = Locksmith.loadDataForUserAccount(key, inService: "CloudFoundry") {
            let json = JSON(data["info"]!)
            
            return CFAccount(
                target: data["target"] as! String,
                username: data["username"] as! String,
                password: data["password"] as! String,
                info: CFInfo(json: json)
            )
        }
        return nil
    }
    
    class func delete(account: CFAccount) throws {
        try account.deleteFromSecureStore()
        removeKey(account.account)
    }
    
    class func exists(username: String, target: String) -> Bool {
        return list().contains { $0.account == "\(username)_\(target)" }
    }
    
    class func list() -> [CFAccount] {
        var accounts = [CFAccount]()
        let keys = self.keyList()
        
        keys.forEach {
            let account = read($0 as! String)
            accounts.append(account!)
        }
        
        return accounts
    }
    
    private class func keyList() -> NSMutableArray {
        let savedKeys = NSUserDefaults
            .standardUserDefaults()
            .arrayForKey(accountListKey)
        
        if let keys = savedKeys {
            return NSMutableArray(array: keys)
        }
        
        return NSMutableArray()
    }
    
    private class func saveKey(key: String) {
        let keyList = self.keyList().arrayByAddingObject(key)
        
        NSUserDefaults
            .standardUserDefaults()
            .setObject(keyList, forKey: accountListKey)
    }
    
    private class func removeKey(key: String) {
        let list = self.keyList().filter { $0 as! String != key }
        
        NSUserDefaults
            .standardUserDefaults()
            .setObject(list, forKey: accountListKey)
    }
}