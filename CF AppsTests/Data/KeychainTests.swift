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

@testable import CF_Apps

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
            "loggingURL": "wss://logging.io",
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
        do {
            try Keychain.getCredentials()
            XCTFail()
        } catch KeychainError.NotFound {
            // Pass case
        } catch {
            XCTFail()
        }
    }
    
    func testGetCredentials() {
        setCredentials()
        do {
            let (authURL, loggingURL, username, password) = try Keychain.getCredentials()
            
            XCTAssertEqual(authURL, "https://auth.io", "should be authURL when credentials have been set")
            XCTAssertEqual(username, "testUsername", "should be username when credentials have been set")
            XCTAssertEqual(password, "testPassword", "should be password when credentials have been set")
        } catch {
            XCTFail()
        }
    }
    
    func testGetApiURL() {
        setCredentials()
        do {
            let apiURL = try Keychain.getApiURL()
            
            XCTAssertEqual(apiURL, "https://api.io", "should be authURL when credentials have been set")
        } catch {
            XCTFail()
        }
    }
    
    func testClearCredentials() {
        setCredentials()
        Keychain.clearCredentials()
        
        do {
            try Keychain.getCredentials()
        } catch KeychainError.NotFound {
            // Pass case
        } catch {
            XCTFail()
        }
        
        do {
            try Keychain.getApiURL()
        } catch KeychainError.NotFound {
            // Pass case
        } catch {
            XCTFail()
        }
    }
}