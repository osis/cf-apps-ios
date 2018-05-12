import Foundation
import XCTest
import CFoundry

@testable import CF_Apps

class AppDelegateTests: XCTestCase {
    var delegate: AppDelegate?
    var account: CFAccount?
    
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
    
    func testDidFinishLaunchingWithCreds() {
//        account = AccountFactory.account()
//        try! AccountStore.create(account!)
//        CFSession.account(account!)
//        CFSession.oauthToken = AccountFactory.oauthToken
//
//        let _ = delegate!.application(UIApplication.shared)
//
//        let rootViewController = delegate!.window!.rootViewController as! UINavigationController
//        let controllers = rootViewController.childViewControllers
//
//        XCTAssertEqual(controllers.count, 2)
//        XCTAssertTrue(controllers[0] is AppsViewController)
//
//        let appsController = controllers[1] as! AppsViewController
//        XCTAssertNotNil(appsController.dataStack)
//
//        CFSession.logout(false)
//        CFSession.reset()
    }
}
