import XCTest

@testable import CF_Apps

class LoginViewControllerTests: XCTestCase {

    var vc : LoginViewController!
    
    override func setUp() {
        super.setUp()
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        vc = storyboard.instantiateViewController(withIdentifier: "LoginView") as! LoginViewController
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
        XCTAssertEqual(vc.loginView.transform.ty, CGAffineTransform.identity.ty)
    }

    func testHideLoginForm() {
        vc.hideLoginForm()
        
        XCTAssertEqual(vc.loginView.alpha, 0)
        XCTAssertEqual(vc.loginView.transform.ty, CGAffineTransform(translationX: 0, y: 50).ty)
    }
    
    func testShowTargetField() {
        vc.showTargetField()
        
        let field = vc.apiTargetField
        
//        XCTAssertTrue(vc.apiTargetView.isFirstResponder())
        XCTAssertEqual(field?.alpha, 1)
    }
    
    func testHideTargetField() {
        XCTAssertEqual(vc.apiTargetField.alpha, 0)
    }
    
    func testVendorPickerUrlChange() {
        let targetURL = "https://craw.now"
        let signupURL = "https://craw.now/signup"
        vc.vendorPickerView(didSelectVendor: targetURL, signupURL: signupURL)
        
        let field = vc.apiTargetField
        
        XCTAssertEqual(field?.isEnabled, false)
        XCTAssertEqual(field?.textColor, UIColor.lightGray)
        XCTAssertEqual(field?.text, targetURL)
    }
    
    func testVendorPickerNilChange() {
        vc.vendorPickerView(didSelectVendor: "https://", signupURL: "")
        
        let field = vc.apiTargetField
        
        XCTAssertEqual(field?.isEnabled, true)
        XCTAssertEqual(field?.textColor, UIColor.darkGray)
        XCTAssertEqual(field?.text, "https://")
    }
    
    func testHideTargetForm() {
        vc.hideTargetForm()
        
        let view = vc.apiTargetView
        
        XCTAssertEqual(view?.alpha, 0)
        XCTAssertEqual(view?.transform.ty, CGAffineTransform(translationX: 0, y: -50).ty)
    }
}
