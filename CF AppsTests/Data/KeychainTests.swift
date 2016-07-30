import Foundation
import XCTest
import Locksmith
import SwiftyJSON

@testable import CF_Apps

class TestAccountFactory {
    static let username = "cfUser"
    static let password = "cfPass"
    static let target = "https://api.test.io"
    
    class func info() -> CFInfo {
        let bundle = NSBundle.mainBundle()
        let path = bundle.pathForResource("PlugIns/CF Apps Tests.xctest/info", ofType: "json")
        let data = NSData(contentsOfFile: path!)
        let json = JSON(data: data!)
        return CFInfo(json: json)
    }
    
    class func account() -> CFAccount {
        return CFAccount(
            target: target,
            username: username,
            password: password,
            info: info()
        )
    }
}

class CFAccountStoreTests: XCTestCase {
    var testAccount: CFAccount?
    let testAccountKey = "cfUser_https://api.test.io"
    
    override func setUp() {
        super.setUp()
        
        testAccount = TestAccountFactory.account()
    }
    
    override func tearDown() {
        super.tearDown()
        
        do {
            try testAccount?.deleteFromSecureStore()
        } catch let error {
            debugPrint(error)
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
            XCTAssertEqual(account.username, TestAccountFactory.username)
            XCTAssertEqual(account.password, TestAccountFactory.password)
            XCTAssertEqual(account.info.authEndpoint, TestAccountFactory.info().authEndpoint)
        } else {
            XCTFail("Account not found.")
        }
    }
    
    func testHasCredentials() {
        var result = CFAccountStore.exists(TestAccountFactory.username, target: TestAccountFactory.target)
        XCTAssertFalse(result)
        
        try! CFAccountStore.create(testAccount!)
        
        result = CFAccountStore.exists(TestAccountFactory.username, target: TestAccountFactory.target)
        XCTAssertTrue(result)
    }
    
    func testAccountDelete() {
        try! CFAccountStore.create(testAccount!)
        try! CFAccountStore.delete(testAccount!)
        
        let result = CFAccountStore.exists(TestAccountFactory.username, target: TestAccountFactory.target)
        XCTAssertEqual(result, false)
        
        let list = CFAccountStore.list()
        XCTAssertEqual(list.count, 0)
    }
}