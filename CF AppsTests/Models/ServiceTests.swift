import Foundation
import XCTest
import SwiftyJSON

@testable import CF_Apps

class ServiceTests:XCTestCase {
    
    func service() -> Service {
        let path = NSBundle(forClass: self.dynamicType).pathForResource("app_summary", ofType: "json")
        let data = NSData(contentsOfFile: path!)
        let json = CFResponseHandler().sanitizeJson(JSON(data: data!))
        return Service(json: json["services"][0])
    }
    
    func testName() {
        let service = self.service()
        
        XCTAssertEqual(service.name(), "label-1")
    }
    
    func testPlanName() {
        let service = self.service()
        
        XCTAssertEqual(service.planName(), "name-83")
    }
}