import Foundation
import Alamofire

enum CFRequest: URLRequestConvertible {
    case Info(String)
    case Login(String, String, String)
    case Orgs()
    case OrgApps(Int)
    case Apps(String, Int)
    case AppSummary(String)
    case AppStats(String)
    case Spaces([String])
    
    var baseURLString: String {
        switch self {
        case .Login(let url, _, _):
            return url
        case .Info(let url):
            return url
        default:
            return CFSession.baseURLString
        }
    }
    
    var path: String {
        switch self {
        case .Info:
            return "/v2/info"
        case .Login:
            return "/oauth/token"
        case .Orgs:
            return "/v2/organizations"
        case .Apps:
            return "/v2/apps"
        case .AppSummary(let guid):
            return "/v2/apps/\(guid)/summary"
        case .AppStats(let guid):
            return "/v2/apps/\(guid)/stats"
        case .Spaces:
            return "/v2/spaces"
        default:
            return ""
        }
    }
    
    var method: Alamofire.Method {
        switch self {
        case .Login:
            return .POST
        default:
            return .GET
        }
    }
    
    var URLRequest: NSMutableURLRequest {
        switch self {
        case .Login(_, let username, let password):
            return loginURLRequest(username, password: password)
        case .Apps(let orgGuid, let page):
            return appsURLRequest(orgGuid, page: page)
        case .Spaces(let appGuids):
            return spacesURLRequest(appGuids)
        default:
            return cfURLRequest()
        }
    }
    
    func cfURLRequest() -> NSMutableURLRequest {
        let URL = NSURL(string: baseURLString)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        
        mutableURLRequest.HTTPMethod = method.rawValue
        
        if let token = CFSession.oauthToken {
            mutableURLRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return mutableURLRequest
    }
    
    func loginURLRequest(username: String, password: String) -> NSMutableURLRequest {
        let mutableURLRequest = cfURLRequest()
        let loginParams = [
            "grant_type": "password",
            "username": username,
            "password": password,
            "scope": ""
        ]
        
        mutableURLRequest.setValue("Basic \(CFSession.loginAuthToken)", forHTTPHeaderField: "Authorization")
        
        return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: loginParams).0
    }
    
    func appsURLRequest(orgGuid: String, page: Int) -> NSMutableURLRequest{
        let mutableURLRequest = cfURLRequest()
        let appsParams: [String : AnyObject] = [
            "order-direction": "desc",
            "q": "organization_guid:\(orgGuid)",
            "results-per-page": "25",
            "page": page
        ]
        
        return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: appsParams).0
    }
    
    func spacesURLRequest(appGuids: [String]) -> NSMutableURLRequest {
        let mutableURLRequest = cfURLRequest()
        let guidString = appGuids.joinWithSeparator(",")
        let spacesParams: [String : AnyObject] = [
            "q": "app_guid IN \(guidString)",
            "results-per-page": "50"
        ]
        
        return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: spacesParams).0
    }
}