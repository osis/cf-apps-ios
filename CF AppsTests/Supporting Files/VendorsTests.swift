import Foundation
import XCTest

@testable import CF_Apps

class VendorsTests: XCTestCase {
    var vendors: NSMutableArray?
    
    override func setUp() {
        super.setUp()
        
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
            let name = v.valueForKey("Name") as! String
            names.append(name.lowercaseString)
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