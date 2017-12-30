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
        CFSession.reset()
    }
    
    func createErrorResponse(statusCode: Int) -> DataResponse<Any> {
        let error = NSError(domain: NSExceptionName.internalInconsistencyException.rawValue, code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to construct response for stub."])
        let result = Result<Any>.failure(error)
        let httpResponse = HTTPURLResponse(url: NSURL(string: "https://test.io")! as URL, statusCode: 500, httpVersion: "1.1", headerFields: nil)
        
        return DataResponse.init(request: nil, response: httpResponse, data: nil, result: result)
    }
    
    func testSuccess() {
        let result = Result<Any>.success(["testKey":"testValue"])
        let response = DataResponse.init(request: nil, response: nil, data: nil, result: result)
        let exp = expectation(description: "Success Callback")
        
        CFResponseHandler().success(response, success: { json in
            XCTAssertEqual(json["testKey"].stringValue, "testValue")
            exp.fulfill()
        })
        
        waitForExpectations(timeout: 1.0, handler: nil)
        XCTAssertNil(CFSession.oauthToken)
    }

    func testError() {
        let response = createErrorResponse(statusCode: 500)
        let exp = expectation(description: "Error Callback")
        
        CFResponseHandler().error(response, error: { statusCode, url in
            XCTAssertEqual(statusCode, 500)
            XCTAssertEqual(url?.absoluteString, "https://test.io")
            
            exp.fulfill()
        })
        
        waitForExpectations(timeout: 1.0, handler: nil)
        XCTAssertNil(CFSession.oauthToken)
    }
    
    func testUnauthorizedSuccess() {
        stub(everything, json([], status: 200))
        CFSession.oauthToken = "TestToken"
        
        class FakeCFResponseHandler: CFResponseHandler {
            let exp: XCTestExpectation
            init(expectation: XCTestExpectation) {
                self.exp = expectation
            }
            
            override func authRefreshSuccess(_ urlRequest: NSMutableURLRequest, success: @escaping (_ json: JSON) -> Void) {
                XCTAssertFalse(self.retryLogin)
                XCTAssertNil(CFSession.oauthToken)
                exp.fulfill()
            }
        }
        
        let account = CFAccountFactory.account()
        CFSession.account(account)
        try! CFAccountStore.create(account)

        let exp = expectation(description: "Auth Refresh Success Callback")
        let handler = FakeCFResponseHandler(expectation: exp)
        let request = NSMutableURLRequest(url: URL(string: "https://api.test.io")!)
        
        handler.unauthorized(request, success: { _ in })
        
        waitForExpectations(timeout: 1.0, handler: nil)
        
        try! CFAccountStore.delete(account)
    }
    
    func testUnauthorizedFailure() {
        stub(everything, json([], status: 401))
        
        class FakeCFResponseHandler: CFResponseHandler {
            let exp: XCTestExpectation
            init(exp: XCTestExpectation) {
                self.exp = exp
            }
            
            override func authRefreshFailure() {
                exp.fulfill()
            }
        }
        
        let account = CFAccountFactory.account()
        CFSession.account(account)
        try! CFAccountStore.create(account)
        
        let exp = expectation(description: "Auth Refresh Success Callback")
        let handler = FakeCFResponseHandler(exp: exp)
        let request = NSMutableURLRequest(url: URL(string: "https://api.test.io")!)
        
        handler.unauthorized(request, success: { _ in })
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testUnauthorizedWithNoCreds() {
        class FakeCFResponseHandler: CFResponseHandler {
            let exp: XCTestExpectation
            init(exp: XCTestExpectation) {
                self.exp = exp
            }
            
            override func authRefreshFailure() {
                exp.fulfill()
            }
        }

        let exp = expectation(description: "Auth Refresh Success Callback")
        let handler = FakeCFResponseHandler(exp: exp)
        let request = NSMutableURLRequest(url: URL(string: "https://api.test.io")!)

        handler.unauthorized(request, success: { _ in })
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    
    func testAuthRefreshSuccess() {
        stub(everything, json([], status: 200))
        
        let handler = CFResponseHandler()
        let request = NSMutableURLRequest(url: URL(string: "https://api.test.io")!)
        let exp = expectation(description: "Auth Recovery Success Callback")
        
        handler.retryLogin = false
        handler.authRefreshSuccess(request, success: { _ in
            exp.fulfill()
        })
        
        waitForExpectations(timeout: 1.0, handler: nil)
        
        XCTAssertNil(request.value(forHTTPHeaderField: "Authorization"))
        XCTAssertTrue(handler.retryLogin)
    }

    func testAuthRefreshSuccessWithToken() {
        stub(everything, json([], status: 200))
        
        let handler = CFResponseHandler()
        let request = NSMutableURLRequest(url: URL(string: "https://api.test.io")!)
        let exp = expectation(description: "Auth Recovery Success Callback")
       
        CFSession.oauthToken = "TestToken"
        handler.authRefreshSuccess(request, success: { _ in
            exp.fulfill()
        })
        
        waitForExpectations(timeout: 1.0, handler: nil)
        let authHeaderToken = request.value(forHTTPHeaderField: "Authorization")
        XCTAssertEqual(authHeaderToken, "Bearer TestToken")
    }

    func testSanitizeJson() {
        let path = Bundle(for: type(of: self)).path(forResource: "apps", ofType: "json")!
        let data = NSData(contentsOfFile: path)
        let json = JSON(data: data! as Data)
        
        let sanitizedJson = CFResponseHandler().sanitizeJson(json)
        let resource = sanitizedJson["resources"][0]
        
        XCTAssertTrue(resource["guid"] == "12f830d7-2ec9-4c66-ad0a-dc5d32affb1f")
        XCTAssertTrue(resource["metadata"] != JSON.null)
        
        XCTAssertTrue(resource["name"] == "name-1568")
        XCTAssertTrue(resource["entity"] == JSON.null)
    }
}
