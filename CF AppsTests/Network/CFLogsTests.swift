import Foundation
import XCTest
import SwiftWebSocket
import Mockingjay

@testable import CF_Apps

class CFLogsTests: XCTestCase {
    let testAppGuid = "50e5b89b-83a7-46c2-ba8b-7be656029238"
    var account: CFAccount?
    
    class FakeLogger: NSObject, CFLogger {
        var appGuid: String
        var assertString: String?
        var expectation: XCTestExpectation
        
        init(appGuid: String, expectation: XCTestExpectation) {
            self.appGuid = appGuid
            self.expectation = expectation
            super.init()
        }
        
        convenience init(appGuid: String, assertString: String, expectation: XCTestExpectation) {
            self.init(appGuid: appGuid, expectation: expectation)
            self.assertString = assertString
        }
        
        func connect() {
            expectation.fulfill()
        }
        
        func reconnect() {
            expectation.fulfill()
        }
        
        func logsMessage(_ text: NSMutableAttributedString) {
            XCTAssertEqual(text.string, assertString!)
            expectation.fulfill()
        }
        
        func recentLogsFetched() {
            expectation.fulfill()
        }
    }
    
    override func setUp() {
        super.setUp()
        
        account = CFAccountFactory.account()
        try! CFAccountStore.create(account!)
        CFSession.account(account!)
    }
    
    override func tearDown() {
        super.tearDown()
        
        CFSession.reset()
        try! CFAccountStore.delete(account!)
        removeAllStubs()
    }
    
    func testInit() {
        let logs = CFLogs(appGuid: testAppGuid)
        
        XCTAssertEqual(logs.appGuid, testAppGuid)
    }
    
    func testTail() {
        // TODO: Injest and test
    }
    
    func testCreateSocket() {
        let logs = CFLogs(appGuid: testAppGuid)
        
        CFSession.oauthToken = "testToken"
        
        do {
            let socket = try logs.createSocket()
            XCTAssertEqual(socket.binaryType, WebSocketBinaryType.nsData)
        } catch {
            XCTFail()
        }
    }
    
    func testCreateSocketRequest() {
        let logs = CFLogs(appGuid: testAppGuid)
        
        CFSession.oauthToken = "testToken"
        
        do {
            let request = try logs.createSocketRequest()
            XCTAssertEqual(request.url?.absoluteString, "wss://doppler.test.io:443/apps/\(testAppGuid)/stream")
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "bearer testToken")
        } catch {
            XCTFail()
        }
    }
    
    func testLogsConnected() {
        let exp = expectation(description: "Logs Connected")
        let logs = CFLogs(appGuid: testAppGuid)
        
        logs.delegate = FakeLogger(appGuid: testAppGuid, assertString: "[]: Connected\n\n", expectation: exp)
        logs.opened()
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testLogsError() {
        let exp = expectation(description: "Logs Error")
        let logs = CFLogs(appGuid: testAppGuid)
        
        logs.delegate = FakeLogger(appGuid: testAppGuid, assertString: "[]: Network(test error)\n\n", expectation: exp)
        logs.error(WebSocketError.network("test error"))
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testLogsAuthRecovery() {
        stub(everything, json([], status: 200))
        class FakeCFLogs: CFLogs {
            let expectation: XCTestExpectation
            
            init(expectation: XCTestExpectation) {
                self.expectation = expectation
                super.init(appGuid: "")
            }
            
            override func tail() {
                expectation.fulfill()
            }
        }
        
        let exp = expectation(description: "Logs Error")
        let logs = FakeCFLogs(expectation: exp)
        
        logs.error(WebSocketError.invalidResponse("HTTP/1.1 401 Unauthorized"))
        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testLogsAuthFail() {
        stub(everything, json([], status: 500))
        class FakeCFLogs: CFLogs {
            let expectation: XCTestExpectation
            
            init(expectation: XCTestExpectation) {
                self.expectation = expectation
                super.init(appGuid: "")
            }
            
            override func handleAuthFail() {
                expectation.fulfill()
            }
        }

        CFSession.oauthToken = ""
        
        let exp = expectation(description: "Logs Error")
        let logs = FakeCFLogs(expectation: exp)
        logs.error(WebSocketError.invalidResponse("HTTP/1.1 401 Unauthorized"))
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
}
