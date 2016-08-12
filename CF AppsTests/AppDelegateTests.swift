import Foundation
import XCTest

@testable import CF_Apps

class AppDelegateTests: XCTestCase {
    var delegate: AppDelegate?
    var navController: UINavigationController?
    var controllers: [UIViewController]?
    
//    override func setUp() {
//        super.setUp()
//        
//        delegate = UIApplication.sharedApplication().delegate as? AppDelegate
//        tabController = delegate!.window!.rootViewController as? UITabBarController
//        controllers = navController!.childViewControllers
//    }
//    
//    override func tearDown() {
//        delegate = nil
//        navController = nil
//        controllers = nil
//    }
//    
//    func testDidFinishLaunching() {
//        XCTAssertEqual(controllers!.count, 1)
//        XCTAssertTrue(controllers![0] is LoginViewController)
//    }
//    
//    func testDidFinishLaunchingWithCreds() {
////        KeychainTests.setCredentials()
//        
//        delegate!.application(UIApplication.sharedApplication(), didFinishLaunchingWithOptions: nil)
//        controllers = navController!.childViewControllers
//        
//        XCTAssertEqual(controllers!.count, 2)
//        XCTAssertTrue(controllers![0] is LoginViewController)
//        XCTAssertTrue(controllers![1] is AppsViewController)
//        
//        let appsController = controllers![1] as! AppsViewController
//        XCTAssertNotNil(appsController.dataStack)
//        
////        Keychain.clearCredentials()
//    }
}