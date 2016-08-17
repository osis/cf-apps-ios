import XCTest

@testable import CF_Apps

class LoginViewControllerTests: XCTestCase {

    var vc : LoginViewController!
    
    override func setUp() {
        super.setUp()
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        vc = storyboard.instantiateViewControllerWithIdentifier("LoginView") as! LoginViewController
        vc.loadView()
    }

    func testSetup() {
        vc.setup()
        
        XCTAssertNotNil(vc.vendorPicker.vendorPickerDelegate)
        XCTAssertEqual(vc.loginView.alpha, 0)
        XCTAssertEqual(vc.apiTargetField.alpha, 0)
        XCTAssertEqual(vc.apiTargetView.alpha, 1)
    }

    func testShowLoginForm() {
        vc.showLoginForm()
        
        XCTAssertEqual(vc.loginView.alpha, 1)
        XCTAssertEqual(vc.loginView.transform.ty, CGAffineTransformIdentity.ty)
    }

    func testHideLoginForm() {
        vc.hideLoginForm()
        
        XCTAssertEqual(vc.loginView.alpha, 0)
        XCTAssertEqual(vc.loginView.transform.ty, CGAffineTransformMakeTranslation(0, 50).ty)
    }
    
    func testShowTargetField() {
        vc.showTargetField()
        
        let field = vc.apiTargetField
        
//        XCTAssertTrue(vc.apiTargetView.isFirstResponder())
        XCTAssertEqual(field.alpha, 1)
    }
    
    func testHideTargetField() {
        XCTAssertEqual(vc.apiTargetField.alpha, 0)
    }
    
    func testVendorPickerUrlChange() {
        let targetURL = "https://craw.now"
        let signupURL = "https://craw.now/signup"
        vc.vendorPickerView(didSelectVendor: targetURL, signupURL: signupURL)
        
        let field = vc.apiTargetField
        
        XCTAssertEqual(field.enabled, false)
        XCTAssertEqual(field.textColor, UIColor.lightGrayColor())
        XCTAssertEqual(field.text, targetURL)
    }
    
    func testVendorPickerNilChange() {
        vc.vendorPickerView(didSelectVendor: "https://", signupURL: "")
        
        let field = vc.apiTargetField
        
        XCTAssertEqual(field.enabled, true)
        XCTAssertEqual(field.textColor, UIColor.darkGrayColor())
        XCTAssertEqual(field.text, "https://")
    }
    
    func testHideTargetForm() {
        vc.hideTargetForm()
        
        let view = vc.apiTargetView
        
        XCTAssertEqual(view.alpha, 0)
        XCTAssertEqual(view.transform.ty, CGAffineTransformMakeTranslation(0, -50).ty)
    }
}