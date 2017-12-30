import Foundation
import XCTest

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
        if account != nil {
            try! CFAccountStore.delete(account!)
            CFSession.reset()
        }
    }

    func testDidFinishLaunching() {
        let rootViewController = delegate!.window!.rootViewController
        XCTAssertTrue(rootViewController is LoginViewController)
    }
    
    func testDidFinishLaunchingWithCreds() {
        account = CFAccountFactory.account()
        try! CFAccountStore.create(account!)
        CFSession.account(account!)
        CFSession.oauthToken = CFAccountFactory.oauthToken
        
        let _ = delegate!.application(UIApplication.shared)
        
        let rootViewController = delegate!.window!.rootViewController as! UINavigationController
        let controllers = rootViewController.childViewControllers
        
        XCTAssertEqual(controllers.count, 2)
        XCTAssertTrue(controllers[0] is AppsViewController)
        
        let appsController = controllers[1] as! AppsViewController
        let predicate = NSPredicate(format: "isViewLoaded == true")
        let exp = expectation(for: predicate, evaluatedWith: appsController, handler: nil)
        let _ = XCTWaiter.wait(for: [exp], timeout: 5)
        
        XCTAssertNotNil(appsController.dataStack)
    }
}
