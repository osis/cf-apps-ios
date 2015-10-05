//
//  CFRequestTests.swift
//  CF Apps
//
//  Created by Dwayne Forde on 2015-08-08.
//  Copyright (c) 2015 Dwayne Forde. All rights reserved.
//

import Foundation
import XCTest
import Alamofire

class CFRequestTests: XCTestCase {
    let baseApiURL = "https://api.run.pivotal.io"
    let baseLoginURL = "https://login.run.pivotal.io"
    
    override func setUp() {
        super.setUp()
        CF.oauthToken = nil
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testLoginAuthToken() {
        XCTAssertEqual(CF.loginAuthToken, "Y2Y6", "Login auth token is Y2Y6")
    }
    
    func testNilOAuthToken() {
        let oauthHeaderValue = CF.Info().URLRequest.valueForHTTPHeaderField("Authorization")
        
        XCTAssertNil(CF.oauthToken, "OAuth token initializes as nil")
        XCTAssertNil(oauthHeaderValue, "OAuth header should be nil")
    }
    
    func testOAuthToken() {
        CF.oauthToken = "testToken"
        let oauthHeaderValue = CF.Info().URLRequest.valueForHTTPHeaderField("Authorization")
        
        XCTAssertEqual(CF.oauthToken!, "testToken", "token should not be nil when set")
        XCTAssertEqual(oauthHeaderValue!, "Bearer testToken", "token should be entered into header when not nil")
    }
    
    func testInfoMember() {
        let path = "/v2/info"
        let request: NSURLRequest = CF.Info().URLRequest
        
        XCTAssert((CF.Info() as Any) is CF, "Info is a member")
        XCTAssertEqual(CF.Info().baseURLString, baseApiURL, "Info returns api URL")
        XCTAssertEqual(CF.Info().path, path, "Info returns info path")
        XCTAssertEqual(CF.Info().method, Alamofire.Method.GET, "Info request method is GET")
        
        XCTAssertEqual(CF.Info().URLRequest.URLString, baseApiURL + path, "Info urlrequest returns the info url")
        XCTAssertNil(request.valueForHTTPHeaderField("Authorization"), "Info doesn't use basic auth")
    }
    
    func testLoginMember() {
        let path = "/oauth/token"
        let request: NSURLRequest = CF.Login("testUser", "testPassword").URLRequest
        
        XCTAssert((CF.Login("", "") as Any) is CF, "Login is a member")
        XCTAssertEqual(CF.Login("", "").baseURLString, baseLoginURL, "Login returns login URL")
        XCTAssertEqual(CF.Login("", "").path, path, "Login returns login path")
        XCTAssertEqual(CF.Login("", "").method, Alamofire.Method.POST, "Login request method is POST")
        
        XCTAssertEqual(request.URLString, baseLoginURL + path, "Login urlrequest returns the login URL")
        XCTAssertEqual(request.valueForHTTPHeaderField("Authorization")!, "Basic \(CF.loginAuthToken)", "URLRequest returns the login URL")

        let requestBody = NSString(data: request.HTTPBody!, encoding: NSUTF8StringEncoding)
        
        let grantLocation = requestBody!.rangeOfString("grant_type=password").location
        XCTAssertNotEqual(grantLocation, NSNotFound, "Login should have a grant_type param")
        
        let usernameLocation = requestBody!.rangeOfString("username=testUser").location
        XCTAssertNotEqual(usernameLocation, NSNotFound, "Login should have a grant_type param")
        
        let passwordLocation = requestBody!.rangeOfString("password=testPassword").location
        XCTAssertNotEqual(passwordLocation, NSNotFound, "Login should have a grant_type param")
        
        let scopeLocation = requestBody!.rangeOfString("scope=&").location
        XCTAssertNotEqual(scopeLocation, NSNotFound, "Login should have an empty scope param")
    }
    
    func testOrgsMember() {
        let path = "/v2/organizations"
        let request: NSURLRequest = CF.Orgs().URLRequest
        
        XCTAssert((CF.Orgs() as Any) is CF, "Orgs is a member")
        XCTAssertEqual(CF.Orgs().baseURLString, baseApiURL, "Orgs returns api URL")
        XCTAssertEqual(CF.Orgs().path, path, "Orgs returns organizations path")
        XCTAssertEqual(CF.Orgs().method, Alamofire.Method.GET, "Orgs urlrequest method is GET")
        
        XCTAssertEqual(request.URLString, baseApiURL + path, "URLRequest returns the orgs url")
        XCTAssertNil(request.valueForHTTPHeaderField("Authorization"), "Orgs doesn't use basic auth")
    }
    
    func testAppsMember() {
        let path = "/v2/apps"
        let currentPage: Int = 1
        let request: NSURLRequest = CF.Apps(currentPage).URLRequest
        
        XCTAssert((CF.Apps(currentPage) as Any) is CF, "Apps is a member")
        XCTAssertEqual(CF.Apps(currentPage).baseURLString, baseApiURL, "Apps returns api URL")
        XCTAssertEqual(CF.Apps(currentPage).path, "/v2/apps", "Apps returns applications path")
        XCTAssertEqual(CF.Apps(currentPage).method, Alamofire.Method.GET, "Apps request method is GET")
        
        XCTAssertEqual(request.URLString, baseApiURL + path + "?order-direction=desc&page=1&results-per-page=25", "Apps urlrequest returns the apps url with the right params")
        XCTAssertNil(request.valueForHTTPHeaderField("Authorization"), "Apps doesn't use basic auth")
    }
    
    func testURLRequestMethod() {
        let request = CF.Login("", "").URLRequest
        XCTAssertEqual(request.HTTPMethod, "POST", "URLRequest method should be set")
    }
}
