import Foundation
import XCTest

@testable import CF_Apps

class VendorsTests: XCTestCase {
    var vendors: NSMutableArray?
    
    override func setUp() {
        let list = NSBundle.mainBundle().pathForResource("Vendors", ofType: "plist")!
        vendors = NSMutableArray(contentsOfFile: list)!
    }
    
    func testOther() {
        let lastName = vendors!.lastObject!.valueForKey("Name") as! String
        XCTAssertEqual(lastName, "Other")
    }

    func testOrder() {
        var names = [String]()
        vendors!.removeLastObject()
        
        for v in vendors! {
            names.append(v.valueForKey("Name") as! String)
        }
        
        let sortedNames = names.sort()
        XCTAssertEqual(names, sortedNames)
    }
    
    func testContent() {
        let other = vendors!.lastObject!
        
        XCTAssertNotNil(other.valueForKey("Name"))
        XCTAssertNil(other.valueForKey("Target"))
        XCTAssertNil(other.valueForKey("URL"))
        
        vendors!.removeLastObject()
        for v in vendors! {
            XCTAssertNotNil(v.valueForKey("Name"))
            XCTAssertNotNil(v.valueForKey("Target"))
            XCTAssertNotNil(v.valueForKey("URL"))
        }
    }
}