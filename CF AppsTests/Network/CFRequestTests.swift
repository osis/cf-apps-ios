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
        let oauthHeaderValue = CFRequest.Info(baseApiURL).URLRequest.valueForHTTPHeaderField("Authorization")
        
        XCTAssertEqual(CFSession.oauthToken!, "testToken", "token should not be nil when set")
        XCTAssertEqual(oauthHeaderValue!, "Bearer testToken", "token should be entered into header when not nil")
    }
    
    func testInfoMember() {
        let path = "/v2/info"
        let request: CFRequest = CFRequest.Info(baseApiURL)
        
        CFSession.oauthToken = nil
        
        assertRequestURLStructure(request, base: baseApiURL, path: path)
        assertGetParams(request, params: "")
        
        XCTAssertNil(request.URLRequest.valueForHTTPHeaderField("Authorization"), "Info doesn't use basic auth")
    }
    
    func testLoginMember() {
        let path = "/oauth/token"
        let request: CFRequest = CFRequest.Login(baseLoginURL, account!.username, account!.password)
        let authHeader = request.URLRequest.valueForHTTPHeaderField("Authorization")!
        let params = [
            "grant_type": "password",
            "username": account!.username,
            "password": account!.password,
            "scope": "&" // Login should have empty scope
        ]
        
        assertRequestURLStructure(request, base: baseLoginURL, path: path)
        assertPostParams(request, params: params)
        
        XCTAssertEqual(authHeader, "Basic \(CFSession.loginAuthToken)")
    }
    
    func testOrgsMember() {
        let path = "/v2/organizations"
        let request: CFRequest = CFRequest.Orgs()
        
        assertRequestURLStructure(request, base: baseApiURL, path: path)
        assertGetParams(request, params: "")
        assertBearerToken(request)
    }
    
    func testAppsMember() {
        let path = "/v2/apps"
        let orgGuid = "abc123"
        let currentPage: Int = 1
        
        // Normal apps request
        let params = "order-direction=desc&page=1&q=organization_guid%3Aabc123&results-per-page=25"
        let request: CFRequest = CFRequest.Apps(orgGuid, currentPage, "")
        
        assertRequestURLStructure(request, base: baseApiURL, path: path)
        assertGetParams(request, params: params)
        assertBearerToken(request)
        
        // Apps search
        let searchParams = "order-direction=desc&page=1&q=organization_guid%3Aabc123&q=name%3E%3Dterm&q=name%3C%3Dtern&results-per-page=25"
        let searchRequest = CFRequest.Apps(orgGuid, currentPage, "term")
        
        assertGetParams(searchRequest, params: searchParams)
    }
    
    func testEventsMember() {
        let appGuid = "abc123"
        let path = "/v2/events"
        let params = "order-direction=desc&q=actee%3Aabc123&results-per-page=50"
        let request: CFRequest = CFRequest.Events(appGuid)
        
        assertRequestURLStructure(request, base: baseApiURL, path: path)
        assertGetParams(request, params: params)
        assertBearerToken(request)
    }
    
    func testRecentLogsMember() {
        let appGuid = "abc123"
        let path = "/apps/\(appGuid)/recentlogs"
        let baseURL = baseLoggingURL.stringByReplacingOccurrencesOfString("wss", withString: "https")
        let request: CFRequest = CFRequest.RecentLogs(appGuid)
        
        assertRequestURLStructure(request, base: baseURL, path: path)
        assertGetParams(request, params: "")
        assertBearerToken(request)
    }
}

private extension CFRequestTests {

    func assertRequestURLStructure(request: CFRequest, base: String, path: String) {
        XCTAssertEqual(request.baseURLString, base, "Request base is \(base)")
        XCTAssertEqual(request.path, path, "Request path is \(path)")
    }
    
    func assertAuth(request: CFRequest) {
        XCTAssertEqual(request.URLRequest.valueForHTTPHeaderField("Authorization"), "Request does have an Authorization header.")
    }
    
    func assertBearerToken(request: CFRequest) {
        XCTAssertEqual(request.URLRequest.valueForHTTPHeaderField("Authorization"), "Bearer \(oauthToken)", "Request has the correct bearer token")
    }
    
    func assertGetParams(request: CFRequest, params: String) {
        XCTAssertEqual(request.method, Alamofire.Method.GET, "Request method is GET")
        
        let urlParts = request.URLRequest.URLString.componentsSeparatedByString("?")
        let requestParams = (urlParts.count == 2) ? urlParts.last : ""
        
        XCTAssertEqual(requestParams, params, "Request params are \(params)")
    }
    
    func assertPostParams(request: CFRequest, params: NSDictionary) {
        XCTAssertEqual(request.method, Alamofire.Method.POST, "Request method is POST")
        
        let urlRequest = request.URLRequest
        
        let contentTypeHeader = urlRequest.valueForHTTPHeaderField("Content-Type")!
        XCTAssertEqual(contentTypeHeader, "application/x-www-form-urlencoded")
        
        let acceptHeader = urlRequest.valueForHTTPHeaderField("Accept")!
        XCTAssertEqual(acceptHeader, "application/json")
        
        let bodyString = NSString(data: urlRequest.HTTPBody!, encoding: NSUTF8StringEncoding)!
        for (k, v) in params {
            let location = bodyString.rangeOfString("\(k)=\(v)").location
            XCTAssertNotEqual(location, NSNotFound, "\(k) params should exist in the body")
        }
    }
}
