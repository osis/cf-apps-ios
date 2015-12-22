//
//  CFSessionTests.swift
//  CF Apps
//
//  Created by Dwayne Forde on 2015-12-22.
//  Copyright © 2015 Dwayne Forde. All rights reserved.
//

import Foundation
import XCTest

class CFSessionTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
        Keychain.clearCredentials()
    }
    
    func testIsEmpty() {
        XCTAssertTrue(CFSession.isEmpty())
        
        CF.oauthToken = ""
        XCTAssertTrue(CFSession.isEmpty())
        
        Keychain.setCredentials([
            "apiURL": "",
            "authURL": "",
            "username": "",
            "password": ""
            ])
        XCTAssertFalse(CFSession.isEmpty())
    }
    
    func testReset() {
        CF.oauthToken = ""
        Keychain.setCredentials([
            "apiURL": "",
            "authURL": "",
            "username": "",
            "password": ""
            ])
        
        CFSession.reset()
        
        XCTAssertNil(CF.oauthToken)
        XCTAssertFalse(Keychain.hasCredentials())
    }
}