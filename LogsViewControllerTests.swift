//
//  LogsViewControllerTests.swift
//  CF Apps
//
//  Created by Dwayne Forde on 2016-04-02.
//  Copyright © 2016 Dwayne Forde. All rights reserved.
//

import XCTest

@testable import CF_Apps

class LogsViewControllerTests: XCTestCase {
    
    class FakeCFLogs: CFLogs {
        let expectation: XCTestExpectation
        
        init(expectation: XCTestExpectation) {
            self.expectation = expectation
            super.init(appGuid: "")
        }
        
        override func tail() {
            expectation.fulfill()
        }
        
        override func disconnect() {
            expectation.fulfill()
        }
    }
    
    var vc : LogsViewController!
    
    override func setUp() {
        super.setUp()
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        vc = storyboard.instantiateViewControllerWithIdentifier("LogsView") as! LogsViewController
        vc.appGuid = "testGuid"
        vc.loadView()
    }
    
    func testInit() {
        XCTAssertEqual(vc.logView.text, "Connecting...")
    }
    
    func testStartLogging() {
        let expectation = expectationWithDescription("Tail Logs")
        
        vc.logs = FakeCFLogs(expectation: expectation)
        
        vc.startLogging()
        
        XCTAssertTrue(vc.logs!.delegate === vc)
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    func testLogsConnected() {
        vc.logsConnected()
        XCTAssertEqual(vc.logView.text, "")
    }
    
    func testLogsError() {
        let description = "Test Error"
        vc.logsError(description)
        XCTAssertEqual(vc.logView.text, description)
    }
    
    func testLogsMessage() {
        vc.logView.attributedText = NSAttributedString(string: "First Line")
        vc.logsMessage(NSMutableAttributedString(string: "\nSecond Line"))
        XCTAssertEqual(vc.logView.text, "First Line\nSecond Line")
    }
    
    func testStopLogging() {
        let expectation = expectationWithDescription("Stop Logging")
        
        vc.logs = FakeCFLogs(expectation: expectation)
        vc.stopLogging()
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
}