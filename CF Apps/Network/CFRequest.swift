//
//  CF.swift
//  CF Commander
//
//  Created by Dwayne Forde on 2015-06-14.
//  Copyright (c) 2015 Dwayne Forde. All rights reserved.
//

import Foundation
import Alamofire

enum CF: URLRequestConvertible {
    static let loginAuthToken = "Y2Y6"
    static var oauthToken: String?
    
    case Info()
    case Login(String, String)
    case Orgs()
    case OrgApps(Int)
    case Apps(String, Int)
    case AppSummary(String)
    case AppStats(String)
    case Spaces([String])
    
    var baseURLString: String {
        switch self {
        case .Login:
            return "https://login.run.pivotal.io"
        default:
            return "https://api.run.pivotal.io"
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
        let URL = NSURL(string: baseURLString)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        mutableURLRequest.HTTPMethod = method.rawValue
        
        if let token = CF.oauthToken {
            mutableURLRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        switch self {
        case .Login(let username, let password):
            let loginParams = [
                "grant_type": "password",
                "username": username,
                "password": password,
                "scope": ""
            ]
            
            mutableURLRequest.setValue("Basic \(CF.loginAuthToken)", forHTTPHeaderField: "Authorization")
            
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: loginParams).0
        case .Apps(let orgGuid, let page):
            let appsParams: [String : AnyObject] = [
                "order-direction": "desc",
                "q": "organization_guid:\(orgGuid)",
                "results-per-page": "25",
                "page": page
            ]
            
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: appsParams).0
        case .Spaces(let appGuids):
            let guidString = appGuids.joinWithSeparator(",")
            let spacesParams: [String : AnyObject] = [
                "q": "app_guid IN \(guidString)",
                "results-per-page": "50"
            ]
            
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: spacesParams).0
        default:
            return mutableURLRequest
        }
    }
}