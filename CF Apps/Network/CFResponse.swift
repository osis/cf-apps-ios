import Foundation
import Alamofire
import SwiftyJSON

class CFResponse {
    static func stringForStatusCode(_ statusCode: Int?, url: URL?) -> String {
        if let c = statusCode, let u = url {
            let statusString = HTTPURLResponse.localizedString(forStatusCode: c)
            return "\(c) \((statusString)) response from \(u)"
        } else {
            return "Cannot connect to \(String(describing: url))"
        }
    }
    
    static func stringForLoginStatusCode(_ statusCode: Int?, url: URL?) -> String {
        return (statusCode == 401) ? "Incorrect credentials" : stringForStatusCode(statusCode, url: url)
    }
}
