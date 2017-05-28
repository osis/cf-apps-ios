import Foundation
import XCTest

@testable import CF_Apps

class CFSessionTests: XCTestCase {
    var account: CFAccount {
        return CFAccountFactory.account()
    }
    
    override func tearDown() {
        super.tearDown()
        
        CFSession.reset()
        do { try CFAccountStore.delete(account) } catch {}
    }
    
    func testConstants() {
        XCTAssertEqual(CFSession.loginAuthToken, "Y2Y6", "Login auth token is Y2Y6")
        XCTAssertEqual(CFSession.accountKey, "currentAccount")
        XCTAssertEqual(CFSession.orgKey, "currentOrg")
    }
    
    func testInit() {
        XCTAssertNil(CFSession.oauthToken, "OAuth token initializes as nil")
    }


    func testSetAccount() {
        CFSession.account(account)
        
        let key = UserDefaults.standard.object(forKey: CFSession.accountKey) as! String
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
    
    func testReset() {
        CFSession.oauthToken = ""
        CFSession.org("guid")
        try! CFSession.account(account)
        
        CFSession.reset()
        
        XCTAssertNil(CFSession.org())
        XCTAssertNil(CFSession.account())
        XCTAssertNil(CFSession.oauthToken)
    }
    
    func testLogout() {
        try! CFAccountStore.create(account)
        CFSession.account(account)
        
        CFSession.logout(true)
        
        XCTAssertTrue(CFAccountStore.isEmpty())
        XCTAssertNil(CFSession.org())
        XCTAssertNil(CFSession.account())
        XCTAssertNil(CFSession.oauthToken)
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let controller = delegate.window?.rootViewController as! LoginViewController
        XCTAssertTrue(controller.authError)
    }
}
