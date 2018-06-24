import Foundation
import XCTest
import CFoundry

@testable import CF_Apps

class AppDelegateTests: XCTestCase {
    var delegate: AppDelegate?
    
    override func setUp() {
        super.setUp()
        delegate = UIApplication.shared.delegate as? AppDelegate
    }
    
    override func tearDown() {
        delegate = nil
    }

    func testDidFinishLaunching() {
        let _ = delegate!.application(UIApplication.shared)
        let rootViewController = delegate!.window!.rootViewController
        XCTAssertTrue(rootViewController is LoginViewController)
    }
}
