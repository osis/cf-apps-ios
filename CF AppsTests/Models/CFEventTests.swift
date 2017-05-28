import Foundation
import SwiftyJSON
import XCTest

@testable import CF_Apps

class CFEventTests: XCTestCase {
    var json: JSON?
    
    override func setUp() {
        super.setUp()
        
        let path = Bundle(for: type(of: self)).path(forResource: "events", ofType: "json")
        let data = NSData(contentsOfFile: path!)
        self.json = CFResponseHandler().sanitizeJson(JSON(data: data! as Data))
    }
    
    func operationEvent() -> CFEvent {
        return CFEvent(json: json!["resources"][0])
    }
    
    func attributeEvent() -> CFEvent {
        return CFEvent(json: json!["resources"][11])
    }
    
    func crashEvent() -> CFEvent {
        return CFEvent(json: json!["resources"][8])
    }
    
    func testType() {
        XCTAssertEqual(operationEvent().type(), "operation")
        XCTAssertEqual(attributeEvent().type(), "update")
        XCTAssertEqual(crashEvent().type(), "crash")
    }
    
    func testRawType() {
        XCTAssertEqual(operationEvent().rawType(), "audit.app.update")
    }
    
    func testState() {
        XCTAssertEqual(operationEvent().state(), "STARTED")
        XCTAssertNil(attributeEvent().state())
    }
    
    func testName() {
        XCTAssertNil(operationEvent().name())
        XCTAssertEqual(attributeEvent().name(), "stemcells")
    }
    
    func testMemory() {
        XCTAssertNil(operationEvent().memory())
        XCTAssertEqual(attributeEvent().memory(), "64 MB")
    }
    
    func testDisk() {
        XCTAssertNil(operationEvent().diskQuota())
        XCTAssertEqual(attributeEvent().diskQuota(), "100 MB")
    }
    
    func testBuildpack() {
        XCTAssertNil(operationEvent().buildpack())
        XCTAssertEqual(attributeEvent().buildpack(), "https://github.com/cloudfoundry-community/staticfile-buildpack.git")
    }
    
    func testEnvironmentJson() {
        XCTAssertNil(operationEvent().environmentJson())
        XCTAssertEqual(attributeEvent().environmentJson(), "PRIVATE DATA HIDDEN")
    }
    
    func testIndex() {
        XCTAssertNil(operationEvent().index())
        XCTAssertEqual(crashEvent().index(), 0)
    }
    
    func testExistDescription() {
        XCTAssertNil(operationEvent().exitDesciption())
        XCTAssertEqual(crashEvent().exitDesciption(), "2 error(s) occurred:\n")
    }
    
    func testReason() {
        XCTAssertNil(operationEvent().reason())
        XCTAssertEqual(crashEvent().reason(), "CRASHED")
    }

    func testAttributeSummary() {
        XCTAssertEqual(operationEvent().attributeSummary(), "")
        XCTAssertEqual(attributeEvent().attributeSummary(), "Name: stemcells, Instances: 1, Memory: 64 MB, Disk: 100 MB, Buildpack: https://github.com/cloudfoundry-community/staticfile-buildpack.git, Envionment JSON: PRIVATE DATA HIDDEN")
    }
}
