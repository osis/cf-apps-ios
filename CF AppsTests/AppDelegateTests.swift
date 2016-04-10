import Foundation
import XCTest

@testable import CF_Apps

class AppDelegateTests: XCTestCase {
    func testDidFinishLaunching() {
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let navController = delegate.window!.rootViewController
        navController?.childViewControllers.count
        
        let controllers = navController!.childViewControllers
        XCTAssertEqual(controllers.count, 1)
        XCTAssertTrue(controllers[0] is LoginViewController)
    }
    
    func testDidFinishLaunchingWithCreds() {
        KeychainTests.setCredentials()
        
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        delegate.application(UIApplication.sharedApplication(), didFinishLaunchingWithOptions: nil)
        
        let navController = delegate.window!.rootViewController
        navController?.childViewControllers.count
        let controllers = navController!.childViewControllers
        
        XCTAssertEqual(controllers.count, 2)
        XCTAssertTrue(controllers[0] is LoginViewController)
        XCTAssertTrue(controllers[1] is AppsViewController)
        
        let appsController = controllers[1] as! AppsViewController
        XCTAssertNotNil(appsController.dataStack)
        
        Keychain.clearCredentials()
    }
}