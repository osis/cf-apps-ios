import Foundation
import Locksmith

enum KeychainError: ErrorType {
    case NotFound
}

class Keychain {
    class var sessionAccount: String { return "cfSession" }
    
    class func hasCredentials() -> Bool {
        let dictionary = Locksmith.loadDataForUserAccount(sessionAccount)

        if ((dictionary) != nil) {
            let keys = dictionary?.keys.sort().joinWithSeparator("")
            let params = ["loggingURL", "apiURL", "authURL", "username", "password"].sort().joinWithSeparator("")
            return (keys == params)
        }
        
        return false
    }
    
    class func setCredentials(credentials: Dictionary<String, String>) -> NSError? {
        do {
         try Locksmith.saveData(credentials, forUserAccount: sessionAccount)
        } catch let error as NSError {
            return error
        }
        return nil
    }
    
    class func getCredentials() throws -> (authUrl: String, loggingURL: String, username: String, password: String) {
        let dictionary = Locksmith.loadDataForUserAccount(sessionAccount)
        if (hasCredentials()) {
            let _authURL: String = dictionary!["authURL"] as! String
            let _loggingURL: String = dictionary!["loggingURL"] as! String
            let _username: String = dictionary!["username"] as! String
            let _password: String = dictionary!["password"] as! String
            return (_authURL, _loggingURL, _username, _password)
        }
        throw KeychainError.NotFound
    }
    
    class func getApiURL() throws -> String {
        let dictionary = Locksmith.loadDataForUserAccount(sessionAccount)
        if (hasCredentials()) {
            let _url: String = dictionary!["apiURL"] as! String
            return _url
        }
        throw KeychainError.NotFound
    }
    
    class func getAuthURL() throws -> String {
        let dictionary = Locksmith.loadDataForUserAccount(sessionAccount)
        if (hasCredentials()) {
            let _url: String = dictionary!["authURL"] as! String
            return _url
        }
        throw KeychainError.NotFound
    }
    
    class func getLoggingURL() throws -> String {
        let dictionary = Locksmith.loadDataForUserAccount(sessionAccount)
        if (hasCredentials()) {
            let _url: String = dictionary!["loggingURL"] as! String
            return _url
        }
        throw KeychainError.NotFound
    }
    
    class func clearCredentials() -> NSError? {
        do {
            try Locksmith.deleteDataForUserAccount(sessionAccount)
        } catch let error as NSError {
            return error
        }
        return nil
    }
}