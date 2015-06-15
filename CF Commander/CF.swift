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
    
    var baseURLString: String {
        switch self {
        case .Login:
            return "https://login.run.pivotal.io"
        default:
            return "https://api.run.pivotal.io"
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
    
    var path: String {
        switch self {
        case .Info:
            return "/v2/info"
        case .Login:
            return "/oauth/token"
        case .Orgs:
            return "/v2/organizations"
        default:
            return "/"
        }
    }
    
    var URLRequest: NSURLRequest {
        let URL = NSURL(string: baseURLString)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        mutableURLRequest.HTTPMethod = method.rawValue
        
        if let token = CF.oauthToken {
            mutableURLRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        switch self {
        case .Login(let username, let password):
            let parameters = [
                "grant_type": "password",
                "username": username,
                "password": password,
                "scope": ""
            ]
            
            mutableURLRequest.setValue("Basic \(CF.loginAuthToken)", forHTTPHeaderField: "Authorization")
            
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: parameters).0
        default:
            return mutableURLRequest
        }
    }
}