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
    
    class private func sanitizeJson(json: JSON) -> JSON {
        var sanitizedJson = json
        
        for (key, subJson) in json["resources"] {
            let index = Int(key)!
            
            for (entityKey, entitySubJson) in subJson["entity"] {
                sanitizedJson["resources"][index][entityKey] = entitySubJson
            }
            sanitizedJson["resources"][index]["entity"] = nil
            
            for (metadataKey, metadataSubJson) in subJson["metadata"] {
                sanitizedJson["resources"][index][metadataKey] = metadataSubJson
            }
            sanitizedJson["resources"][index]["metadata"] = nil
        }
        
        return sanitizedJson
    }
}