import Foundation
import XCTest
import Alamofire

@testable import CF_Apps

class CFRequestTests: XCTestCase {
    let oauthToken = CFAccountFactory.oauthToken
    let baseApiURL = CFAccountFactory.target
    let baseLoginURL = CFAccountFactory.info().authEndpoint
    let baseLoggingURL = CFAccountFactory.info().dopplerLoggingEndpoint
    
    var account: CFAccount?
    
    override func setUp() {
        super.setUp()
        
        account = CFAccountFactory.account()
        CFSession.account(account!)
        CFSession.oauthToken = oauthToken
        try! CFAccountStore.create(account!)
    }
    
    override func tearDown() {
        super.tearDown()
        
        CFSession.reset()
        try! CFAccountStore.delete(account!)
    }
    
    func testOAuthToken() {
        let oauthHeaderValue = CFRequest.info(baseApiURL).urlRequest?.value(forHTTPHeaderField: "Authorization")
        
        XCTAssertEqual(CFSession.oauthToken!, "testToken", "token should not be nil when set")
        XCTAssertEqual(oauthHeaderValue!, "Bearer testToken", "token should be entered into header when not nil")
    }
    
    func testInfoMember() {
        let path = "/v2/info"
        let request: CFRequest = CFRequest.info(baseApiURL)
        
        CFSession.oauthToken = nil
        
        assertRequestURLStructure(request: request, base: baseApiURL, path: path)
        assertGetParams(request: request, params: "")
        
        XCTAssertNil(request.urlRequest?.value(forHTTPHeaderField: "Authorization"), "Info doesn't use basic auth")
    }
    
    func testLoginMember() {
        let path = "/oauth/token"
        let request: CFRequest = CFRequest.login(baseLoginURL, account!.username, account!.password)
        let authHeader = request.urlRequest?.value(forHTTPHeaderField: "Authorization")!
        let params = [
            "grant_type": "password",
            "username": account!.username,
            "password": account!.password,
            "scope": "&" // Login should have empty scope
        ]
        
        assertRequestURLStructure(request: request, base: baseLoginURL, path: path)
        assertPostParams(request: request, params: params)
        
        XCTAssertEqual(authHeader, "Basic \(CFSession.loginAuthToken)")
    }
    
    func testOrgsMember() {
        let path = "/v2/organizations"
        let request: CFRequest = CFRequest.orgs()
        
        assertRequestURLStructure(request: request, base: baseApiURL, path: path)
        assertGetParams(request: request, params: "")
        assertBearerToken(request: request)
    }
    
    func testAppsMember() {
        let path = "/v2/apps"
        let orgGuid = "abc123"
        let currentPage: Int = 1
        
        // Normal apps request
        let params = "order-direction=desc&page=1&q=organization_guid%3Aabc123&results-per-page=25"
        let request: CFRequest = CFRequest.apps(orgGuid, currentPage, "")
        
        assertRequestURLStructure(request: request, base: baseApiURL, path: path)
        assertGetParams(request: request, params: params)
        assertBearerToken(request: request)
        
        // Apps search
        let searchParams = "order-direction=desc&page=1&q=organization_guid%3Aabc123&q=name%3E%3Dterm&q=name%3C%3Dtern&results-per-page=25"
        let searchRequest = CFRequest.apps(orgGuid, currentPage, "term")
        
        assertGetParams(request: searchRequest, params: searchParams)
    }
    
    func testEventsMember() {
        let appGuid = "abc123"
        let path = "/v2/events"
        let params = "order-direction=desc&q=actee%3Aabc123&results-per-page=50"
        let request: CFRequest = CFRequest.events(appGuid)
        
        assertRequestURLStructure(request: request, base: baseApiURL, path: path)
        assertGetParams(request: request, params: params)
        assertBearerToken(request: request)
    }
    
    func testRecentLogsMember() {
        let appGuid = "abc123"
        let path = "/apps/\(appGuid)/recentlogs"
        let baseURL = baseLoggingURL.replacingOccurrences(of: "wss", with: "https")
        let request: CFRequest = CFRequest.recentLogs(appGuid)
        
        assertRequestURLStructure(request: request, base: baseURL, path: path)
        assertGetParams(request: request, params: "")
        assertBearerToken(request: request)
    }
}

private extension CFRequestTests {

    func assertRequestURLStructure(request: CFRequest, base: String, path: String) {
        XCTAssertEqual(request.baseURLString, base, "Request base is \(base)")
        XCTAssertEqual(request.path, path, "Request path is \(path)")
    }
    
    func assertAuth(request: CFRequest) {
        XCTAssertEqual(request.urlRequest?.value(forHTTPHeaderField: "Authorization"), "Request does have an Authorization header.")
    }
    
    func assertBearerToken(request: CFRequest) {
        XCTAssertEqual(request.urlRequest?.value(forHTTPHeaderField: "Authorization"), "Bearer \(oauthToken)", "Request has the correct bearer token")
    }
    
    func assertGetParams(request: CFRequest, params: String) {
        XCTAssertEqual(request.method, Alamofire.HTTPMethod.get, "Request method is GET")
        
        let urlParts = request.urlRequest?.url?.absoluteString.components(separatedBy: "?")
        let requestParams = (urlParts?.count == 2) ? urlParts?.last : ""
        
        XCTAssertEqual(requestParams, params, "Request params are \(params)")
    }
    
    func assertPostParams(request: CFRequest, params: [String: Any]) {
        XCTAssertEqual(request.method, Alamofire.HTTPMethod.post, "Request method is POST")
        
        let urlRequest = request.urlRequest!
        
        let contentTypeHeader = urlRequest.value(forHTTPHeaderField: "Content-Type")!
        XCTAssertEqual(contentTypeHeader, "application/x-www-form-urlencoded")
        
        let acceptHeader = urlRequest.value(forHTTPHeaderField: "Accept")!
        XCTAssertEqual(acceptHeader, "application/json")
        
        let bodyString = NSString(data: urlRequest.httpBody!, encoding: String.Encoding.utf8.rawValue)!
        for (k, v) in params {
            let location = bodyString.range(of: "\(k)=\(v)").location
            XCTAssertNotEqual(location, NSNotFound, "\(k) params should exist in the body")
        }
    }
}
