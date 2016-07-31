import Foundation
import XCTest

@testable import CF_Apps

class VendorsTests: XCTestCase {
    func testListOrder() {
        var names = [String]()
        
        for v in Vendor.list {
            XCTAssertNotNil(v.valueForKey("Name"))
            XCTAssertNotNil(v.valueForKey("Target"))
            XCTAssertNotNil(v.valueForKey("URL"))
            
            let name = v.valueForKey("Name") as! String
            names.append(name.lowercaseString)
        }
        
        let sortedNames = names.sort()
        XCTAssertEqual(names, sortedNames)
    }
    
    func testOptions() {
        let options = Vendor.options
        
        XCTAssertTrue(options.count > 1)
        
        let lastOption = options.lastObject as! NSDictionary
        let lastName = lastOption.valueForKey("Name") as! String
        XCTAssertEqual(lastName, "Other")
    }
}