import Foundation
import Alamofire
import SwiftyJSON

protocol ResponseHandler {
    var retryLogin: Bool { get set }
    func success(response: Response<AnyObject, NSError>, success: (json: JSON) -> Void)
    func error(response: Response<AnyObject, NSError>, error: (statusCode: Int?, url: NSURL) -> Void)
    func unauthorized(originalURLRequest: NSMutableURLRequest, success: (json: JSON) -> Void)
    func authRefreshSuccess(urlRequest: NSMutableURLRequest, success: (json: JSON) -> Void)
    func authRefreshFailure()
}

class CFResponseHandler: ResponseHandler {
    var retryLogin = true
    
    func success(response: Response<AnyObject, NSError>, success: (json: JSON) -> Void) {
        let json = sanitizeJson(JSON(response.result.value!))
        
        if let token = json["access_token"].string {
            CFSession.oauthToken = token
        }
        
        success(json: json)
    }
    
    func error(response: Response<AnyObject, NSError>, error: (statusCode: Int?, url: NSURL) -> Void) {
        error(statusCode: response.response?.statusCode, url: (response.request?.URL)!)
    }
    
    func unauthorized(originalURLRequest: NSMutableURLRequest, success: (json: JSON) -> Void) {
        CFSession.oauthToken = nil
        
        self.retryLogin = false
        if let account = CFSession.account() {
            let loginURLRequest = CFRequest.Login(
                account.info.authEndpoint,
                account.username,
                account.password
            )
            
            CFApi(responseHandler: self).refreshToken(loginURLRequest, originalURLRequest: originalURLRequest, success: success)
        } else {
            self.authRefreshFailure()
        }
    }
    
    func authRefreshSuccess(urlRequest: NSMutableURLRequest, success: (json: JSON) -> Void) {
        self.retryLogin = true
        
        if let token = CFSession.oauthToken {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        CFApi(responseHandler: self).request(urlRequest, success: success, error: { _ in
            self.authRefreshFailure()
        })
    }
    
    func authRefreshFailure() {
        // TODO: Delegate this
        CFSession.logout(true)
    }
    
    func sanitizeJson(json: JSON) -> JSON {
        var sanitizedJson = json
        
        for (key, subJson) in json["resources"] {
            let index = Int(key)!
            
            for (metadataKey, metadataSubJson) in subJson["metadata"] {
                sanitizedJson["resources"][index][metadataKey] = metadataSubJson
            }
            
            for (entityKey, entitySubJson) in subJson["entity"] {
                sanitizedJson["resources"][index][entityKey] = entitySubJson
            }
            sanitizedJson["resources"][index]["entity"] = nil
        }
        
        return sanitizedJson
    }
}

class CFApi {
    let responseHandler: ResponseHandler
    
    init(responseHandler: ResponseHandler = CFResponseHandler()) {
        self.responseHandler = responseHandler
    }
    
    func request(urlRequest: URLRequestConvertible, success: (json: JSON) -> Void, error: (statusCode: Int?, url: NSURL) -> Void) {

        Alamofire.request(urlRequest.URLRequest).validate().responseJSON { response in
            self.handleResponse(response, success: success, error: error)
        }
    }
    
    func dopplerRequest(urlRequest: URLRequestConvertible, completionHandler: (request: NSURLRequest?, response: NSHTTPURLResponse?, data: NSData?, error: NSError?) -> Void) {
        
        Alamofire.request(urlRequest.URLRequest).validate().response { (request, response, data, error) in
            completionHandler(request: request, response: response, data: data, error: error)
        }
    }
    
    func refreshToken(loginURLRequest: CFRequest, originalURLRequest: NSMutableURLRequest, success: (json: JSON) -> Void) {
            self.request(loginURLRequest, success: { _ in
                print("--- Token Refresh Success")
                self.responseHandler.authRefreshSuccess(originalURLRequest, success: success)
            }, error: { (_, _) in
                print("--- Token Refresh Fail")
                self.responseHandler.authRefreshFailure()
        })
    }
    
    func handleResponse(response: Response<AnyObject, NSError>, success: (json: JSON) -> Void, error: (statusCode: Int?, url: NSURL) -> Void) {
        if (response.result.isSuccess) {
            responseHandler.success(response, success: success)
        } else if (response.response?.statusCode == 401 && CFSession.account() != nil && responseHandler.retryLogin) {
            print("--- Auth Fail")
            responseHandler.unauthorized(response.request!.URLRequest, success: success)
        } else if (response.result.isFailure) {
            print("--- Error")
            responseHandler.error(response, error: error)
        }
    }
}