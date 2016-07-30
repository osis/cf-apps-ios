import Foundation
import XCTest
import Alamofire
import Mockingjay
import SwiftyJSON

@testable import CF_Apps

class CFResponseHandlerTests: XCTestCase {
    
    override func tearDown() {
        super.tearDown()
        
        clearState()
    }
    
    func clearState() {
        removeAllStubs()
        CFSession.logout()
    }
    
    func createErrorResponse(statusCode: Int) -> Alamofire.Response<AnyObject, NSError> {
        let error = NSError(domain: NSInternalInconsistencyException, code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to construct response for stub."])
        let result = Result<AnyObject, NSError>.Failure(error)
        
        let httpResponse = NSHTTPURLResponse(URL: NSURL(string: "https://test.io")!, statusCode: 500, HTTPVersion: "1.1", headerFields: nil)
        
        return Response.init(request: nil, response: httpResponse, data: nil, result: result)
    }
    
    func testSuccess() {
        let result = Result<AnyObject, NSError>.Success(["testKey":"testValue"])
        let response = Response.init(request: nil, response: nil, data: nil, result: result)
        let expectation = expectationWithDescription("Success Callback")
        
        CFResponseHandler().success(response, success: { json in
            XCTAssertEqual(json["testKey"].stringValue, "testValue")
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
        XCTAssertNil(CFSession.oauthToken)
    }

    func testError() {
        let response = createErrorResponse(500)
        let expectation = expectationWithDescription("Error Callback")
        
        CFResponseHandler().error(response, error: { statusCode, url in
            XCTAssertEqual(statusCode, 500)
            XCTAssertEqual(url?.absoluteString, "https://test.io")
            
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
        XCTAssertNil(CFSession.oauthToken)
    }
    
    func testUnauthorizedSuccess() {
        stub(everything, builder: json([], status: 200))
        CFSession.oauthToken = "TestToken"
        
        class FakeCFResponseHandler: CFResponseHandler {
            let expectation: XCTestExpectation
            init(expectation: XCTestExpectation) {
                self.expectation = expectation
            }
            
            override func authRefreshSuccess(urlRequest: NSMutableURLRequest, success: (json: JSON) -> Void) {
                XCTAssertFalse(self.retryLogin)
                XCTAssertNil(CFSession.oauthToken)
                expectation.fulfill()
            }
        }
        
        let account = TestAccountFactory.account()
        try! CFSession.account(account)

        let expectation = expectationWithDescription("Auth Refresh Success Callback")
        let handler = FakeCFResponseHandler(expectation: expectation)
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.test.io")!)
        
        handler.unauthorized(request, success: { _ in })
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
        
        try! CFAccountStore.delete(account)
    }
    
    func testUnauthorizedFailure() {
        stub(everything, builder: json([], status: 401))
        
        class FakeCFResponseHandler: CFResponseHandler {
            let expectation: XCTestExpectation
            init(expectation: XCTestExpectation) {
                self.expectation = expectation
            }
            
            override func authRefreshFailure() {
                expectation.fulfill()
            }
        }
        
        let account = TestAccountFactory.account()
        try! CFSession.account(account)
        
        let expectation = expectationWithDescription("Auth Refresh Success Callback")
        let handler = FakeCFResponseHandler(expectation: expectation)
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.test.io")!)
        
        handler.unauthorized(request, success: { _ in })
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    func testUnauthorizedWithNoCreds() {
        class FakeCFResponseHandler: CFResponseHandler {
            let expectation: XCTestExpectation
            init(expectation: XCTestExpectation) {
                self.expectation = expectation
            }
            
            override func authRefreshFailure() {
                expectation.fulfill()
            }
        }

        let expectation = expectationWithDescription("Auth Refresh Success Callback")
        let handler = FakeCFResponseHandler(expectation: expectation)
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.test.io")!)

        handler.unauthorized(request, success: { _ in })
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    
    func testAuthRefreshSuccess() {
        stub(everything, builder: json([], status: 200))
        
        let handler = CFResponseHandler()
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.test.io")!)
        let expectation = expectationWithDescription("Auth Recovery Success Callback")
        
        handler.retryLogin = false
        handler.authRefreshSuccess(request, success: { _ in
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
        
        XCTAssertNil(request.valueForHTTPHeaderField("Authorization"))
        XCTAssertTrue(handler.retryLogin)
    }

    func testAuthRefreshSuccessWithToken() {
        stub(everything, builder: json([], status: 200))
        
        let handler = CFResponseHandler()
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.test.io")!)
        let expectation = expectationWithDescription("Auth Recovery Success Callback")
       
        CFSession.oauthToken = "TestToken"
        handler.authRefreshSuccess(request, success: { _ in
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
        let authHeaderToken = request.valueForHTTPHeaderField("Authorization")
        XCTAssertEqual(authHeaderToken, "Bearer TestToken")
    }

    func testSanitizeJson() {
        let path = NSBundle(forClass: self.dynamicType).pathForResource("apps", ofType: "json")!
        let data = NSData(contentsOfFile: path)
        let json = JSON(data: data!)
        
        let sanitizedJson = CFResponseHandler().sanitizeJson(json)
        let resource = sanitizedJson["resources"][0]
        
        XCTAssertTrue(resource["guid"] == "12f830d7-2ec9-4c66-ad0a-dc5d32affb1f")
        XCTAssertTrue(resource["metadata"] != nil)
        
        XCTAssertTrue(resource["name"] == "name-1568")
        XCTAssertTrue(resource["entity"] == nil)
    }
}