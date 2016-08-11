import Foundation
import XCTest

@testable import CF_Apps

class CFAccountStoreTests: XCTestCase {
    var testAccount: CFAccount?
    let testAccountKey = "cfUser_https://api.test.io"
    
    override func setUp() {
        super.setUp()
        
        testAccount = CFAccountFactory.account()
    }
    
    override func tearDown() {
        super.tearDown()
        
        do {
            try testAccount?.deleteFromSecureStore()
        } catch let error {
            print(error)
        }
        
        NSUserDefaults.standardUserDefaults().removeObjectForKey(CFAccountStore.accountListKey)
    }
    
    func testAccountKeyFormat() {
        XCTAssertEqual(testAccount!.account, testAccountKey)
    }
    
    func testAccountCreate() {
        try! CFAccountStore.create(testAccount!)
        
        let account = testAccount!.readFromSecureStore()!
        XCTAssertNotNil(account.data)
        
        let list = CFAccountStore.list()
        XCTAssertEqual(list.count, 1)
        XCTAssertEqual(list[0].account, testAccountKey)
    }
    
    func testAccountRead() {
        try! CFAccountStore.create(testAccount!)
        
        if let account = CFAccountStore.read(testAccountKey) {
            XCTAssertEqual(account.username, CFAccountFactory.username)
            XCTAssertEqual(account.password, CFAccountFactory.password)
            XCTAssertEqual(account.info.authEndpoint, CFAccountFactory.info().authEndpoint)
        } else {
            XCTFail("Account not found.")
        }
    }
    
    func testExists() {
        var result = CFAccountStore.exists(CFAccountFactory.username, target: CFAccountFactory.target)
        XCTAssertFalse(result)
        
        try! CFAccountStore.create(testAccount!)
        
        result = CFAccountStore.exists(CFAccountFactory.username, target: CFAccountFactory.target)
        XCTAssertTrue(result)
    }
    
    func testAccountDelete() {
        try! CFAccountStore.create(testAccount!)
        try! CFAccountStore.delete(testAccount!)
        
        let result = CFAccountStore.exists(CFAccountFactory.username, target: CFAccountFactory.target)
        XCTAssertEqual(result, false)
        
        let list = CFAccountStore.list()
        XCTAssertEqual(list.count, 0)
    }
    
    func testIsEmpty() {
        var result = CFAccountStore.isEmpty()
        XCTAssertTrue(result)
        
        try! CFAccountStore.create(testAccount!)
        
        result = CFAccountStore.isEmpty()
        XCTAssertFalse(result)
    }
}