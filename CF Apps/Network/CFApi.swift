import Foundation
import Alamofire
import SwiftyJSON

protocol ResponseHandler {
    var retryLogin: Bool { get set }
    func success(_ response: DataResponse<Any>, success: @escaping (_ json: JSON) -> Void)
    func error(_ response: DataResponse<Any>, error: @escaping (_ statusCode: Int?, _ url: URL?) -> Void)
    func unauthorized(_ originalURLRequest: NSMutableURLRequest, success: @escaping (_ json: JSON) -> Void)
    func authRefreshSuccess(_ urlRequest: NSMutableURLRequest, success: @escaping (_ json: JSON) -> Void)
    func authRefreshFailure()
}

class CFResponseHandler: ResponseHandler {
    
    var retryLogin = true
    
    func success(_ response: DataResponse<Any>, success: @escaping (JSON) -> Void) {
        let json = sanitizeJson(JSON(response.result.value!))
        
        if let token = json["access_token"].string {
            CFSession.oauthToken = token
        }
        
        success(json)
    }
    
    func error(_ response: DataResponse<Any>, error: @escaping (Int?, URL?) -> Void) {
        error(response.response?.statusCode, response.response?.url)
    }
    
    func unauthorized(_ originalURLRequest: NSMutableURLRequest, success: @escaping (JSON) -> Void) {
        CFSession.oauthToken = nil
        
        self.retryLogin = false
        if let account = CFSession.account() {
            let loginURLRequest = CFRequest.login(
                account.info.authEndpoint,
                account.username,
                account.password
            )
            
            CFApi(responseHandler: self).refreshToken(loginURLRequest, originalURLRequest: originalURLRequest, success: success)
        } else {
            self.authRefreshFailure()
        }
    }
    
    func authRefreshSuccess(_ urlRequest: NSMutableURLRequest, success: @escaping (_ json: JSON) -> Void) {
        self.retryLogin = true
        
        if let token = CFSession.oauthToken {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        CFApi(responseHandler: self).request(urlRequest as URLRequest, success: success, error: { _ in
            self.authRefreshFailure()
        })
    }
    
    func authRefreshFailure() {
        // TODO: Delegate this
        CFSession.logout(true)
    }
    
    func sanitizeJson(_ json: JSON) -> JSON {
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
    
    func request(_ urlRequest: URLRequestConvertible, success: @escaping (_ json: JSON) -> Void, error: @escaping (_ statusCode: Int?, _ url: URL?) -> Void) {
        Alamofire.request(urlRequest.urlRequest!).validate().responseJSON { response in
            self.handleResponse(response, success: success, error: error)
        }
    }
    
    func dopplerRequest(_ urlRequest: URLRequestConvertible, completionHandler: @escaping (_ request: URLRequest?, _ response: HTTPURLResponse?, _ data: Data?, _ error: NSError?) -> Void) {
        
        Alamofire.request(urlRequest.urlRequest!).validate().responseData(completionHandler: { (response) in
            completionHandler(response.request, response.response, response.data, response.error as NSError?)
        })
    }
    
    func refreshToken(_ loginURLRequest: CFRequest, originalURLRequest: NSMutableURLRequest, success: @escaping (_ json: JSON) -> Void) {
            self.request(loginURLRequest, success: { _ in
                print("--- Token Refresh Success")
                self.responseHandler.authRefreshSuccess(originalURLRequest, success: success)
            }, error: { (_, _) in
                print("--- Token Refresh Fail")
                self.responseHandler.authRefreshFailure()
        })
    }
    
    func handleResponse(_ response: DataResponse<Any>, success: @escaping (_ json: JSON) -> Void, error: @escaping (_ statusCode: Int?, _ url: URL?) -> Void) {
        if (response.result.isSuccess) {
            responseHandler.success(response, success: success)
        } else if (response.response?.statusCode == 401 && responseHandler.retryLogin) {
            print("--- Auth Fail")
            responseHandler.unauthorized(response.request!.urlRequest as! NSMutableURLRequest, success: success)
        } else if (response.result.isFailure) {
            print("--- Error")
            responseHandler.error(response, error: error)
        }
    }
}
