//
//  CFApiTests.swift
//  CF Apps
//
//  Created by Dwayne Forde on 2016-02-16.
//  Copyright © 2016 Dwayne Forde. All rights reserved.
//

import Foundation
import XCTest
import Alamofire
import Mockingjay
import SwiftyJSON

class CFApiTests: XCTestCase {
    let baseURL = "https://unit.test"
    
    override func setUp() {
        super.setUp()
    }
    override func tearDown() {
        super.tearDown()
        
        removeAllStubs()
    }

//    func testOkInfo() {
//        let path = NSBundle(forClass: self.dynamicType).pathForResource("info", ofType: "json")!
//        let data = NSData(contentsOfFile: path)!
//        let stubee = http(200, headers: ["Content-Type": "application/json"], data: data)
//        let expectation = expectationWithDescription("Info")
//        
//        stub(uri("/v2/info"), builder: stubee)
//        
//        CFApi.info(baseURL, success: { (json) in
//            XCTAssert(json.dynamicType == JSON.self, "Response should be JSON")
//            XCTAssertEqual(json.count, JSON(data: data).count, "Complete JSON object should be parsed")
//            expectation.fulfill()
//        }, error: {_ in
//            XCTAssertTrue(false, "Should not use the error callback")
//        })
//        
//        waitForExpectationsWithTimeout(1.0, handler: nil)
//    }
//    
//    func testInfo404() {
//        let stubee = http(404)
//        stub(uri("/v2/info"), builder: stubee)
//        
//        let expectation = expectationWithDescription("Info")
//        CFApi.info(baseURL, success: { (json) in
//            XCTAssertTrue(false, "Should not use the success callback")
//            }, error: { message in
//                XCTAssertEqual(message, "404 response from \(self.baseURL)/v2/info")
//                expectation.fulfill()
//        })
//        waitForExpectationsWithTimeout(1.0, handler: nil)
//    }
    
//    func testInfo401() {
//        let stubee = http(404)
//        stub(uri("/v2/info"), builder: stubee)
//        
//        let expectation = expectationWithDescription("Info")
//        CFApi.info(baseURL, success: { (json) in
//            XCTAssertTrue(false, "Should not use the success callback")
//            }, error: { message in
//                XCTAssertEqual(message, "404 response from \(self.baseURL)/v2/info")
//                expectation.fulfill()
//        })
//        waitForExpectationsWithTimeout(1.0, handler: nil)
//    }
}