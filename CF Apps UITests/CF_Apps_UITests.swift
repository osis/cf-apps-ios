import XCTest
import Swifter

class CF_Apps_UITests: XCTestCase {
    var app:XCUIApplication!
    
    var logo: XCUIElement { return app.images["launch_icon"] }
    var title: XCUIElement { return app.staticTexts["API Endpoint"] }
    var vendorPicker: XCUIElement { return app.pickerWheels["Pivotal Web Services"] }
    var targetButton: XCUIElement { return app.buttons["Target"] }
    var targetField: XCUIElement { return app.textFields["https://"] }
    var emptyTargetField: XCUIElement { return app.textFields[""] }
    var progressSpinner: XCUIElement { return app.activityIndicators["In progress"] }
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app = XCUIApplication()
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
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
    }
    
    func testOtherVendorField() {
    }
    
    func testTargetInvalidURL() {
        vendorPicker.adjust(toPickerWheelValue: "Other")
        usleep(50000)
        
        XCTAssertTrue(targetField.exists)
        
        var exp = expectation(description: "Invalid URL Dialog")
        addUIInterruptionMonitor(withDescription: "Invalid URL") { (alert) -> Bool in
            alert.buttons["OK"].tap()
            exp.fulfill()
            return true
        }
        targetButton.tap()
        app.tap()
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testTarget404() {
        vendorPicker.adjust(toPickerWheelValue: "Other")
        usleep(50000)
        
        XCTAssertTrue(targetField.exists)
        targetField.clearAndEnterText(text: "")
        emptyTargetField.typeText("http://127.0.0.1:8080")
        
        let serverExp = expectation(description: "Server Request")
        let server = HttpServer()
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
    
    func testLoginPickerWheelVendors() {
        let vendors = loadVendors()
        
        var picker = vendorPicker
        for v in vendors {
            let name = v["Name"]!
            picker.adjust(toPickerWheelValue: name)
            usleep(50000)
            picker = app.pickerWheels[name]
        }
    }
    
    func loadVendors() -> [[String : String]] {
        let vendorsPath = Bundle(for: CF_Apps_UITests.self).url(forResource: "vendors", withExtension: "plist")
        return NSArray(contentsOf: vendorsPath!) as! [[String : String]]
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
