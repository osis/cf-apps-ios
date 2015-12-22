//
//  Keychain.swift
//  CF Apps
//
//  Created by Dwayne Forde on 2015-08-07.
//  Copyright (c) 2015 Dwayne Forde. All rights reserved.
//

import Foundation
import XCTest
import Locksmith

class KeychainTests: XCTestCase {
    let userAccount = Keychain.sessionAccount
    
    func clearKeychain() {
        do {
            try Locksmith.deleteDataForUserAccount(userAccount)
        } catch {
            // no-op
        }
    }
    
    override func setUp() {
        super.setUp()
        clearKeychain()
    }
    
    override func tearDown() {
        super.tearDown()
        clearKeychain()
    }
    
    func setCredentials() -> NSError? {
        return Keychain.setCredentials([
            "apiURL": "https://api.io",
            "authURL": "https://auth.io",
            "username": "testUsername",
            "password": "testPassword"
            ])
    }
    
    func testSetCredentials() {
        XCTAssertNil(setCredentials(), "should be nil when credentials have been set")
    }
    
    func testNoCredentials() {
        XCTAssertFalse(Keychain.hasCredentials(), "should return false when there are no credentials")
    }
    
    func testHasCredentials() {
        setCredentials()
        XCTAssertTrue(Keychain.hasCredentials(), "should return true when there are credentials")
    }
    
    func testHasMissingCredentialParams() {
        Keychain.setCredentials([
            "username": "testUsername",
            "password": "testPassword"
            ])
        
        XCTAssertFalse(Keychain.hasCredentials(), "should return false when added params from new version are missing from old store")
    }
    
    func testGetNoCredentials() {
        let (authURL, username, password) = Keychain.getCredentials()
        
        XCTAssertNil(authURL, "should be nil when credentials have not been set")
        XCTAssertNil(username, "should be nil when credentials have not been set")
        XCTAssertNil(password, "should be nil when credentials have not been set")
    }
    
    func testGetCredentials() {
        setCredentials()
        let (authURL, username, password) = Keychain.getCredentials()
        
        XCTAssertEqual(authURL!, "https://auth.io", "should be authURL when credentials have been set")
        XCTAssertEqual(username!, "testUsername", "should be username when credentials have been set")
        XCTAssertEqual(password!, "testPassword", "should be password when credentials have been set")
    }
    
    func testGetApiURL() {
        setCredentials()
        let apiURL = Keychain.getApiURL()
        
        XCTAssertEqual(apiURL!, "https://api.io", "should be authURL when credentials have been set")
    }
    
    func testClearCredentials() {
        setCredentials()
        Keychain.clearCredentials()
        let (authURL, username, password) = Keychain.getCredentials()
        let apiURL = Keychain.getApiURL()
        
        XCTAssertNil(apiURL, "should be nil when credentials have been cleared")
        XCTAssertNil(authURL, "should be nil when credentials have been cleared")
        XCTAssertNil(username, "should be nil when credentials have been cleared")
        XCTAssertNil(password, "should be nil when credentials have been cleared")
    }
}