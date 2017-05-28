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
        vc = storyboard.instantiateViewController(withIdentifier: "LogsView") as! LogsViewController
        vc.appGuid = "testGuid"
        vc.loadView()
    }
    
    func testInit() {
        XCTAssertEqual(vc.logView.text, "")
    }
    
    func testStartLogging() {
        let exp = expectation(description: "Tail Logs")
        
        vc.logs = FakeCFLogs(expectation: exp)
        
        vc.startLogging()
        
        XCTAssertTrue(vc.logs!.delegate === vc)
        XCTAssertTrue(UIApplication.shared.isIdleTimerDisabled)
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testLogsMessage() {
        vc.logView.attributedText = NSAttributedString(string: "First Line")
        vc.logsMessage(NSMutableAttributedString(string: "\nSecond Line"))
        XCTAssertEqual(vc.logView.text, "First Line\nSecond Line")
    }
    
    func testStopLogging() {
        let exp = expectation(description: "Stop Logging")
        
        vc.logs = FakeCFLogs(expectation: exp)
        vc.stopLogging()
        
        XCTAssertFalse(UIApplication.shared.isIdleTimerDisabled)
        waitForExpectations(timeout: 1.0, handler: nil)
    }
}
