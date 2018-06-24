import XCTest
import Swifter

class LoginViewTests: XCTestCase {
    var app:XCUIApplication!
    var server: HttpServer!
    
    var logo: XCUIElement { return app.images["launch_icon"] }
    var title: XCUIElement { return app.staticTexts["API Endpoint"] }
    var vendorPicker: XCUIElement { return app.pickerWheels["Pivotal Web Services"] }
    var targetButton: XCUIElement { return app.buttons["Target"] }
    var targetField: XCUIElement { return app.textFields["https://"] }
    var emptyTargetField: XCUIElement { return app.textFields[""] }
    var progressSpinner: XCUIElement { return app.activityIndicators["In progress"] }
    
    var usernameField: XCUIElement { return app.textFields["Username"] }
    var passwordField: XCUIElement { return app.secureTextFields["Password"] }
    var loginButton: XCUIElement { return app.buttons["Login"] }
    var cancelButton: XCUIElement { return app.buttons["Cancel"] }
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        
        server = HttpServer()
    }
    
    override func tearDown() {
        super.tearDown()
        server.stop()
    }
    
    func testLoginDefault() {
        XCTAssertTrue(logo.exists)
        XCTAssertTrue(logo.isHittable)
        
        XCTAssertTrue(title.exists)
        XCTAssertTrue(title.isHittable)
        
        XCTAssertTrue(vendorPicker.exists)
        XCTAssertTrue(vendorPicker.isHittable)
        
        XCTAssertTrue(targetButton.exists)
        XCTAssertTrue(targetButton.isHittable)
        
        XCTAssertFalse(targetField.exists)
        XCTAssertFalse(progressSpinner.exists)
        XCTAssertFalse(usernameField.exists)
        XCTAssertFalse(passwordField.exists)
        XCTAssertFalse(loginButton.exists)
        XCTAssertFalse(cancelButton.exists)
    }
    
    func testLoginPickerWheelVendors() {
        let vendors = loadVendors()
        
        var picker = vendorPicker
        for v in vendors {
            let name = v["Name"]!
            picker.adjust(toPickerWheelValue: name)
            picker = app.pickerWheels[name]
            
            XCTAssertTrue(picker.waitForExistence(timeout: 0))
        }
    }
    
    func testTargetInvalidURL() {
        vendorPicker.adjust(toPickerWheelValue: "Other")
        
        if targetField.waitForExistence(timeout: 0) {
            let exp = expectation(description: "Invalid URL Dialog")
            addUIInterruptionMonitor(withDescription: "Invalid URL") { (alert) -> Bool in
                alert.buttons["OK"].tap()
                exp.fulfill()
                return true
            }
            targetButton.tap()
            app.tap()
            waitForExpectations(timeout: 1, handler: nil)
        }
    }
    
    func testTarget404() {
        vendorPicker.adjust(toPickerWheelValue: "Other")
        
        XCTAssertTrue(targetField.waitForExistence(timeout: 0))
        targetField.clearAndEnterText(text: "")
        emptyTargetField.typeText("http://127.0.0.1:8080")
        
        let serverExp = expectation(description: "Server Request")
        server["/v2/info"] = { request in
            sleep(1)
            serverExp.fulfill()
            return .notFound
        }
        try! server.start(8080)
        
        targetButton.tap()
        XCTAssertTrue(progressSpinner.exists)
        wait(for: [serverExp], timeout: 5)
        
        app.alerts["Error"].buttons["OK"].tap()
        XCTAssertFalse(progressSpinner.exists)
    }
    
    func testLoginAndRemember() {
        vendorPicker.adjust(toPickerWheelValue: "Other")
        
        XCTAssertTrue(targetField.waitForExistence(timeout: 0))
        
        targetField.clearAndEnterText(text: "")
        emptyTargetField.typeText("http://127.0.0.1:8080")
        
        let path = Bundle(for: type(of: self)).path(forResource: "info", ofType: "json")
        server["/v2/info"] = shareFile(path!)
        server["/oauth/token"] = { request in
            let body = self.responseObject(filename: "tokens")
            return HttpResponse.ok(.json(body))
        }
        server["/v2/organizations"] = { request in
            let body = self.responseObject(filename: "orgs")
            return HttpResponse.ok(.json(body))
        }
        server["/v2/apps"] = { request in
            return HttpResponse.ok(.json(["resources": []] as AnyObject))
        }
        try! server.start(8080)
        
        targetButton.tap()
        
        XCTAssertTrue(usernameField.waitForExistence(timeout: 1))
        XCTAssertTrue(passwordField.exists)
        XCTAssertTrue(loginButton.exists)
        XCTAssertTrue(cancelButton.exists)
        
        usernameField.typeText("testUser")
        passwordField.tap()
        passwordField.typeText("testPass")
        
        loginButton.tap()
        
        XCTAssertTrue(app.navigationBars["Navigation"].waitForExistence(timeout: 1))
        
        sleep(10) //TODO: Not sure why this is needed. NSUserDefaults doesn't synchronize without it but synchonize() method is deprecated.
        
        app = XCUIApplication()
        app.launch()
        
        XCTAssertTrue(app.navigationBars["Navigation"].waitForExistence(timeout: 1))
        
        let accountsButton = app.navigationBars["Navigation"].children(matching: .button).element(boundBy: 0)
        accountsButton.tap()
        
        XCTAssertTrue(app.navigationBars["Accounts"].waitForExistence(timeout: 1))
        
        let tablesQuery = app.tables
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["testUser"]/*[[".cells.staticTexts[\"testUser\"]",".staticTexts[\"testUser\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.swipeLeft()
        
        app.tables.buttons["Delete"].tap()
    }
    
    func loadVendors() -> [[String : String]] {
        let vendorsPath = Bundle(for: LoginViewTests.self).url(forResource: "vendors", withExtension: "plist")
        return NSArray(contentsOf: vendorsPath!) as! [[String : String]]
    }
    
    func responseObject(filename: String) -> AnyObject {
        let path = Bundle(for: type(of: self)).path(forResource: filename, ofType: "json")
        let jsonData = try! Data(contentsOf: URL(fileURLWithPath: path!))
        return try! JSONSerialization.jsonObject(with: jsonData, options: []) as AnyObject
    }

}

extension XCUIElement {
    /**
     Removes any current text in the field before typing in the new value
     - Parameter text: the text to enter into the field
     */
    func clearAndEnterText(text: String) {
        guard let stringValue = self.value as? String else {
            XCTFail("Tried to clear and enter text into a non string value")
            return
        }
        
        self.tap()
        
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.characters.count)
        
        self.typeText(deleteString)
    }
}
