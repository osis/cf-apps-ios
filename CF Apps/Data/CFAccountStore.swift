import Foundation
import Locksmith
import SwiftyJSON

// Accounts are stored in the Keychain.
// Reference to those accounts are stored in NSUserDefaults.

enum CFAccountError: Error {
    case notFound
}

class CFAccountStore {
    class var accountsKey: String { return "CFAccounts" }
    class var accountListKey: String { return "CFAccountList" }
    
    class func create(_ account: CFAccount) throws {
        do {
            try account.createInSecureStore()
            saveKey(account.account)
        } catch LocksmithError.duplicate {
            try account.updateInSecureStore()
        }
        
        if !exists(account.username, target: account.target) {
            saveKey(account.account)
        }
    }
    
    class func read(_ key: String) -> CFAccount? {
        if let data = Locksmith.loadDataForUserAccount(userAccount: key, inService: "CloudFoundry") {
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
    
    class func delete(_ account: CFAccount) throws {
        try account.deleteFromSecureStore()
        removeKey(account.account)
    }
    
    class func exists(_ username: String, target: String) -> Bool {
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
    
    class func isEmpty() -> Bool {
        return self.keyList().count == 0
    }
}

private extension CFAccountStore {
    class func keyList() -> NSMutableArray {
        let savedKeys = UserDefaults.standard
            .array(forKey: accountListKey)
        
        if let keys = savedKeys {
            return NSMutableArray(array: keys)
        }
        
        return NSMutableArray()
    }
    
    class func saveKey(_ key: String) {
        let keyList = self.keyList().adding(key)
        
        UserDefaults.standard
            .set(keyList, forKey: accountListKey)
    }
    
    class func removeKey(_ key: String) {
        let list = self.keyList().filter { $0 as! String != key }
        
        UserDefaults.standard
            .set(list, forKey: accountListKey)
    }
}
