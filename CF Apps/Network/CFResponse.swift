import Foundation
import Alamofire
import SwiftyJSON

class CFResponse {
    static func stringForStatusCode(statusCode: Int?, url: NSURL) -> String {
        if let c = statusCode {
            let statusString = NSHTTPURLResponse.localizedStringForStatusCode(c)
            return "\(c) \((statusString)) response from \(url)"
        } else {
            return "Cannot connect to \(url)"
        }
    }
    
    static func stringForLoginStatusCode(statusCode: Int?, url: NSURL) -> String {
        return (statusCode == 401) ? "Incorrect credentials" : stringForStatusCode(statusCode, url: url)
    }
}