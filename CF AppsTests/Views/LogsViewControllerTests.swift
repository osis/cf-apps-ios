import XCTest

@testable import CF_Apps

class LogsViewControllerTests: XCTestCase {
    
    class FakeCFLogs: CFLogs {
        let expectation: XCTestExpectation
        
        init(expectation: XCTestExpectation) {
            self.expectation = expectation
            super.init(appGuid: "")
        }
        
        override func connect() {
            expectation.fulfill()
        }
        
        override func reconnect() {
            expectation.fulfill()
        }
        
        override func disconnect() {
            expectation.fulfill()
        }
        
        override func recent() {
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
        XCTAssertEqual(vc.logView.text, "")
    }
    
    func testStartLogging() {
        let expectation = expectationWithDescription("Tail Logs")
        
        vc.logs = FakeCFLogs(expectation: expectation)
        
        vc.startLogging()
        
        XCTAssertTrue(vc.logs!.delegate === vc)
        XCTAssertTrue(UIApplication.sharedApplication().idleTimerDisabled)
        waitForExpectationsWithTimeout(1.0, handler: nil)
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
        
        XCTAssertFalse(UIApplication.sharedApplication().idleTimerDisabled)
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
}