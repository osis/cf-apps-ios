import Foundation
import XCTest

@testable import CF_Apps

class CFSessionTests: XCTestCase {
    var account: CFAccount {
        return TestAccountFactory.account()
    }
    
    override func tearDown() {
        super.tearDown()
        
        CFSession.logout()
        do { try CFAccountStore.delete(account) } catch {}
    }
    
    func testConstants() {
        XCTAssertEqual(CFSession.loginAuthToken, "Y2Y6")
        XCTAssertEqual(CFSession.accountKey, "currentAccount")
        XCTAssertEqual(CFSession.orgKey, "currentOrg")
    }


    func testSetAccount() {
        CFSession.account(account)
        
        let key = NSUserDefaults.standardUserDefaults().objectForKey(CFSession.accountKey) as! String
        XCTAssertEqual(key, account.account)
    }
    
    func testAccount() {
        XCTAssertNil(CFSession.account())
        
        try! CFAccountStore.create(account)
        CFSession.account(account)
        
        if let sessionAccount = CFSession.account() {
            XCTAssertEqual(sessionAccount.account, account.account)
        } else {
            XCTFail()
        }
        
        try! CFAccountStore.delete(account)
    }
    
    func testOrg() {
        let org = "testOrg"
        
        XCTAssertNil(CFSession.org())
        
        CFSession.org(org)
        
        XCTAssertEqual(CFSession.org(), org)
    }
    
    func testLogout() {
        CFSession.oauthToken = ""
        CFSession.org("guid")
        try! CFSession.account(account)
        
        CFSession.logout()
        
        XCTAssertNil(CFSession.org())
        XCTAssertNil(CFSession.account())
        XCTAssertNil(CFSession.oauthToken)
    }
    
//    func testIsEmpty() {
//        XCTAssertTrue(CFSession.isEmpty())
//        
//        CFSession.oauthToken = ""
//        XCTAssertTrue(CFSession.isEmpty())
//
//// TODO: Set Credentials
////        Keychain.setCredentials([
////            "apiURL": "",
////            "authURL": "",
////            "loggingURL": "",
////            "username": "",
////            "password": ""
////            ])
//        XCTAssertFalse(CFSession.isEmpty())
//    }
    
    
//    func testSetOrg() {
//        CFSession.setOrg("guid")
//        
//        let guid = NSUserDefaults.standardUserDefaults().objectForKey(CFSession.orgKey) as! String
//        XCTAssertEqual(guid, "guid")
//    }
//    
//    func testGetOrgNil() {
//        let guid = CFSession.getOrg()
//        
//        XCTAssertNil(guid)
//    }
//    
//    func testGetOrg() {
//        CFSession.setOrg("guid")
//        
//        XCTAssertEqual(CFSession.getOrg(), "guid")
//    }
//    
//    func testIsOrgStale() {
//        XCTAssertTrue(CFSession.isOrgStale([]))
//        
//        CFSession.setOrg("guid")
//        XCTAssertTrue(CFSession.isOrgStale([]))
//        XCTAssertFalse(CFSession.isOrgStale(["guid"]))
//    }
}