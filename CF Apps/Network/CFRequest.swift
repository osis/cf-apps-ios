import Foundation
import Alamofire

enum CFRequest: URLRequestConvertible {
    case info(String)
    case login(String, String, String)
    case orgs()
    case orgApps(Int)
    case apps(String, Int, String)
    case appSummary(String)
    case appStats(String)
    case spaces([String])
    case events(String)
    case recentLogs(String)
    
    var baseURLString: String {
        switch self {
        case .login(let url, _, _):
            return url
        case .info(let url):
            return url
        case .recentLogs(_):
            if var components = URLComponents(string: CFSession.dopplerURLString) {
                components.scheme = "https"
                return components.string!
            }
            return ""
        default:
            return CFSession.baseURLString
        }
    }
    
    var path: String {
        switch self {
        case .info:
            return "/v2/info"
        case .login:
            return "/oauth/token"
        case .orgs:
            return "/v2/organizations"
        case .apps:
            return "/v2/apps"
        case .appSummary(let guid):
            return "/v2/apps/\(guid)/summary"
        case .appStats(let guid):
            return "/v2/apps/\(guid)/stats"
        case .spaces:
            return "/v2/spaces"
        case .events:
            return "/v2/events"
        case .recentLogs(let guid):
            return "/apps/\(guid)/recentlogs"
        default:
            return ""
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .login:
            return .post
        default:
            return .get
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        switch self {
        case .login(_, let username, let password):
            return loginURLRequest(username, password: password)
        case .apps(let orgGuid, let page, let searchText):
            return appsURLRequest(orgGuid, page: page, searchText: searchText) as URLRequest
        case .spaces(let appGuids):
            return spacesURLRequest(appGuids) as URLRequest
        case .events(let appGuid):
            return eventsURLRequest(appGuid) as URLRequest
        default:
            return cfURLRequest()
        }
    }
    
    func cfURLRequest() -> URLRequest {
        let URL = Foundation.URL(string: baseURLString)!
        var mutableURLRequest = URLRequest(url: URL.appendingPathComponent(path))
        
        mutableURLRequest.httpMethod = method.rawValue
        
        if let token = CFSession.oauthToken {
            mutableURLRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return mutableURLRequest
    }
    
    func loginURLRequest(_ username: String, password: String) -> URLRequest {
        var urlRequest = cfURLRequest()
        let loginParams = [
            "grant_type": "password",
            "username": username,
            "password": password,
            "scope": ""
        ]
        
        urlRequest.setValue("Basic \(CFSession.loginAuthToken)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        urlRequest = try! URLEncoding.default.encode(urlRequest, with: loginParams)
        return urlRequest
    }
    
    func appsURLRequest(_ orgGuid: String, page: Int, searchText: String) -> NSMutableURLRequest{
        let mutableURLRequest = cfURLRequest()
        var appsParams: [String : Any] = [
            "order-direction": "desc",
            "q": ["organization_guid:\(orgGuid)"],
            "results-per-page": "25",
            "page": page
        ]
        
        if !searchText.isEmpty {
            var queries = appsParams["q"] as! [String]
            queries.append("name>=\(searchText)")
            queries.append("name<=\(searchText.bumpLastChar())")
            appsParams["q"] = queries
        }
        
        var request = try! URLEncoding.default.encode(mutableURLRequest, with: appsParams)
        
        if let query = request.url?.query {
            var URLComponents = Foundation.URLComponents(url: mutableURLRequest.url!, resolvingAgainstBaseURL: false)
            let trimmedQuery = query.replacingOccurrences(of: "%5B%5D", with: "")
            
            URLComponents?.percentEncodedQuery =  trimmedQuery
            request.url = URLComponents?.url
        }
        
        return request as! NSMutableURLRequest
    }
    
    func spacesURLRequest(_ appGuids: [String]) -> NSMutableURLRequest {
        let mutableURLRequest = cfURLRequest()
        let guidString = appGuids.joined(separator: ",")
        let spacesParams: [String : AnyObject] = [
            "q": "app_guid IN \(guidString)" as AnyObject,
            "results-per-page": "50" as AnyObject
        ]
        
        return try! URLEncoding.default.encode(mutableURLRequest as URLRequestConvertible, with: spacesParams) as! NSMutableURLRequest
    }
    
    func eventsURLRequest(_ appGuid: String) -> NSMutableURLRequest {
        let mutableURLRequest = cfURLRequest()
        let eventParams: [String : AnyObject] = [
            "order-direction": "desc" as AnyObject,
            "q": "actee:\(appGuid)" as AnyObject,
            "results-per-page": "50" as AnyObject
        ]
        
        return try! URLEncoding.default.encode(mutableURLRequest, with: eventParams) as! NSMutableURLRequest
    }
}
