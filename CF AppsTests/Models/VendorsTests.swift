import Foundation
import XCTest

@testable import CF_Apps

class VendorsTests: XCTestCase {
    func testListOrder() {
        var names = [String]()
        
        for v in Vendor.list as [AnyObject] {
            XCTAssertNotNil(v.value(forKey: "Name"))
            XCTAssertNotNil(v.value(forKey: "Name"))
            XCTAssertNotNil(v.value(forKey: "Target"))
            XCTAssertNotNil(v.value(forKey: "URL"))
            
            let name = v.value(forKey: "Name") as! String
            names.append(name.lowercased())
        }
        
        let sortedNames = names.sorted()
        XCTAssertEqual(names, sortedNames)
    }
    
    func testOptions() {
        let options = Vendor.options
        
        XCTAssertTrue(options.count > 1)
        
        let lastOption = options.lastObject as! NSDictionary
        let lastName = lastOption.value(forKey: "Name") as! String
        XCTAssertEqual(lastName, "Other")
    }
}
