import Foundation
import XCTest
import SwiftyJSON

@testable import CF_Apps

class InstanceTests: XCTestCase {
    
    func instance() -> Instance {
        let path = NSBundle(forClass: self.dynamicType).pathForResource("app_stats", ofType: "json")
        let data = NSData(contentsOfFile: path!)
        let json = CFResponseHandler().sanitizeJson(JSON(data: data!))
        return Instance(json: json["0"])
    }
    
    func testURI() {
        let instance = self.instance()
        
        XCTAssertEqual(instance.uri(), "https://app_name.example.com")
    }
    
    func testState() {
        let instance = self.instance()
        
        XCTAssertEqual(instance.state(), "started")
    }
    
    func testCPUUsagePercentage() {
        let instance = self.instance()
        
        XCTAssertEqual(instance.cpuUsagePercentage(), 14.0)
    }
    
    func testMemoryUsage() {
        let instance = self.instance()
        
        XCTAssertEqual(instance.memoryUsage(), 2849.609375)
    }
    
    func testMemoryQuota() {
        let instance = self.instance()
        
        XCTAssertEqual(instance.memoryQuota(), 512)
    }
    
    func testMemoryUsagePercentage() {
        let instance = self.instance()
        
        XCTAssertEqual(instance.memoryUsagePercentage(), 5.5999999999999996)
    }
    
    func testDiskUsage() {
        let instance = self.instance()
        
        XCTAssertEqual(instance.diskUsage(), 6331.640625)
    }
    
    func testDiskQuota() {
        let instance = self.instance()
        
        XCTAssertEqual(instance.diskQuota(), 1024)
    }
    
    func testDiskUsagePercentage() {
        let instance = self.instance()
        
        XCTAssertEqual(instance.diskUsagePercentage(), 6.2000000000000002)
    }
}