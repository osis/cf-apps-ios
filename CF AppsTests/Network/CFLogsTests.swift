//
//  CFLogsTests.swift
//  CF Apps
//
//  Created by Dwayne Forde on 2016-03-27.
//  Copyright © 2016 Dwayne Forde. All rights reserved.
//

import Foundation
import XCTest
import SwiftWebSocket
import Mockingjay

@testable import CF_Apps

class CFLogsTests: XCTestCase {
    let testAppGuid = "50e5b89b-83a7-46c2-ba8b-7be656029238"
    
    class FakeLogger: NSObject, CFLogger {
        var appGuid: String
        var expectation: XCTestExpectation
        
        init(appGuid: String, expectation: XCTestExpectation) {
            self.appGuid = appGuid
            self.expectation = expectation
            super.init()
        }
        
        func tail() {
            expectation.fulfill()
        }
        
        func logsConnected() {
            expectation.fulfill()
        }
        
        func logsError(description: String) {
            XCTAssertEqual(description, "Network(test websocket error)")
            expectation.fulfill()
        }
        
        func logsMessage(text: NSMutableAttributedString) {
            XCTAssertEqual(text, "test message")
            expectation.fulfill()
        }
    }
    
    override func setUp() {
    }
    
    override func tearDown() {
        CFSession.reset()
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
        
        KeychainTests.setCredentials()
        CFSession.oauthToken = "testToken"
        
        do {
            let socket = try logs.createSocket()
            XCTAssertEqual(socket.binaryType, WebSocketBinaryType.NSData)
        } catch {
            XCTFail()
        }
    }
    
    func testCreateSocketRequest() {
        let logs = CFLogs(appGuid: testAppGuid)
        
        KeychainTests.setCredentials()
        CFSession.oauthToken = "testToken"
        
        do {
            let request = try logs.createSocketRequest()
            XCTAssertEqual(request.URLString, "wss://loggregator.capi.test/tail/?app=\(testAppGuid)")
            XCTAssertEqual(request.valueForHTTPHeaderField("Authorization"), "bearer testToken")
        } catch {
            XCTFail()
        }
    }
    
    func testLogsConnected() {
        let expectation = expectationWithDescription("Logs Connected")
        let logs = CFLogs(appGuid: testAppGuid)
        
        logs.delegate = FakeLogger(appGuid: testAppGuid, expectation: expectation)
        logs.opened()
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    func testClosed() {
       // TODO: Nothing Happens.
    }
    
    func testLogsError() {
        let expectation = expectationWithDescription("Logs Error")
        let logs = CFLogs(appGuid: testAppGuid)
        
        logs.delegate = FakeLogger(appGuid: testAppGuid, expectation: expectation)
        logs.error(WebSocketError.Network("test websocket error"))
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    func testLogsAuthRecovery() {
        stub(everything, builder: json([], status: 200))
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
        
        KeychainTests.setCredentials()
        let expectation = expectationWithDescription("Logs Error")
        let logs = FakeCFLogs(expectation: expectation)
        
        logs.error(WebSocketError.InvalidResponse("HTTP/1.1 401 Unauthorized"))
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }

    func testLogsAuthFail() {
        stub(everything, builder: json([], status: 500))
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
        
        KeychainTests.setCredentials()
        CFSession.oauthToken = ""
        XCTAssertFalse(CFSession.isEmpty())
        
        let expectation = expectationWithDescription("Logs Error")
        let logs = FakeCFLogs(expectation: expectation)
        logs.error(WebSocketError.InvalidResponse("HTTP/1.1 401 Unauthorized"))
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    func testMessageFormat() {
        let logs = CFLogs(appGuid: testAppGuid)
        let message = logs.formatMessage("SRC", sourceID: "0", message: "Message", type: LogMessage.MessageType.Out)
        
        XCTAssertEqual(message.string, "\n\nSRC[0]: Message")

        var srcRange = NSString(string: message.string).rangeOfString("SRC[0]:")
        
        let srcAttributes = message.attributesAtIndex(0, effectiveRange: &srcRange)
        let srcFont = srcAttributes["NSFont"] as! UIFont
        let srcColor = srcAttributes["NSColor"] as! UIColor

        XCTAssertEqual(srcFont, logs.font)
        XCTAssertEqual(srcColor, logs.prefixColor)
        
        var msgRange = NSString(string: message.string).rangeOfString("Message")
        let msgAttributes = message.attributesAtIndex(10, effectiveRange: &msgRange)
        let msgFont = msgAttributes["NSFont"] as! UIFont
        let msgColor = msgAttributes["NSColor"] as! UIColor
        
        XCTAssertEqual(msgFont, logs.font)
        XCTAssertEqual(msgColor, logs.outColor)
    }
    
    func testMessageErrorFormat() {
        let logs = CFLogs(appGuid: testAppGuid)
        let message = logs.formatMessage("SRC", sourceID: "0", message: "Message", type: LogMessage.MessageType.Err)
        
        var msgRange = NSString(string: message.string).rangeOfString("Message")
        let msgAttributes = message.attributesAtIndex(10, effectiveRange: &msgRange)
        
        let msgColor = msgAttributes["NSColor"] as! UIColor
        
        XCTAssertEqual(msgColor, logs.errColor)
    }
}
