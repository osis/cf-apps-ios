import Foundation
import Alamofire
import SwiftyJSON

class CFResponse {
    static func stringForStatusCode(statusCode: Int?, url: NSURL?) -> String {
        if let c = statusCode, let u = url {
            let statusString = NSHTTPURLResponse.localizedStringForStatusCode(c)
            return "\(c) \((statusString)) response from \(u)"
        } else {
            return "Invalid URL"
        }
    }
    
    static func stringForLoginStatusCode(statusCode: Int?, url: NSURL?) -> String {
        return (statusCode == 401) ? "Incorrect credentials" : stringForStatusCode(statusCode, url: url)
    }
}