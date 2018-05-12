import Foundation
import Locksmith
import CFoundry

// Accounts are stored in the Keychain.
// Reference to those accounts are stored in NSUserDefaults.

enum AccountError: Error {
    case notFound
}

public class AccountStore {
    class var accountsKey: String { return "Accounts" }
    class var accountListKey: String { return "AccountList" }
    
    public class func create(_ account: CFAccount) throws {
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
            return CFAccount.deserialize(data)
        }
        return nil
    }
    
    public class func delete(_ account: CFAccount) throws {
        try account.deleteFromSecureStore()
        removeKey(account.account)
    }
    
    public class func exists(_ username: String, target: String) -> Bool {
        return list().contains { $0.account == "\(username)_\(target)" }
    }
    
    public class func list() -> [CFAccount] {
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

private extension AccountStore {
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
        
        UserDefaults.standard.set(list, forKey: accountListKey)
    }
}
