import Foundation
import XCTest

@testable import CF_Apps

class CFSessionTests: XCTestCase {
    
    override func tearDown() {
        super.tearDown()
        
        let domain = NSBundle.mainBundle().bundleIdentifier
        
        Keychain.clearCredentials()
        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(domain!)
    }
    
    func testConstants() {
        XCTAssertEqual(CFSession.loginAuthToken, "Y2Y6")
        XCTAssertEqual(CFSession.orgKey, "currentOrg")
    }
    
    func testIsEmpty() {
        XCTAssertTrue(CFSession.isEmpty())
        
        CFSession.oauthToken = ""
        XCTAssertTrue(CFSession.isEmpty())
        
        Keychain.setCredentials([
            "apiURL": "",
            "authURL": "",
            "loggingURL": "",
            "username": "",
            "password": ""
            ])
        XCTAssertFalse(CFSession.isEmpty())
    }
    
    func testReset() {
        CFSession.oauthToken = ""
        CFSession.setOrg("guid")
        Keychain.setCredentials([
            "apiURL": "",
            "authURL": "",
            "username": "",
            "password": ""
            ])
        
        CFSession.reset()
        
        XCTAssertNil(CFSession.getOrg())
        XCTAssertNil(CFSession.oauthToken)
        XCTAssertFalse(Keychain.hasCredentials())
    }
    
    func testSetOrg() {
        CFSession.setOrg("guid")
        
        let guid = NSUserDefaults.standardUserDefaults().objectForKey(CFSession.orgKey) as! String
        XCTAssertEqual(guid, "guid")
    }
    
    func testGetOrgNil() {
        let guid = CFSession.getOrg()
        
        XCTAssertNil(guid)
    }
    
    func testGetOrg() {
        CFSession.setOrg("guid")
        
        XCTAssertEqual(CFSession.getOrg(), "guid")
    }
    
    func testIsOrgStale() {
        XCTAssertTrue(CFSession.isOrgStale([]))
        
        CFSession.setOrg("guid")
        XCTAssertTrue(CFSession.isOrgStale([]))
        XCTAssertFalse(CFSession.isOrgStale(["guid"]))
    }
}