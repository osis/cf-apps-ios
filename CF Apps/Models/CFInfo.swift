import Foundation
import SwiftyJSON

public struct CFInfo {
    let json: JSON
    
    struct Keys {
      static let support = "support"
      static let description = "description"
      static let tokenEndpoint = "token_endpoint"
      static let authEndpoint = "authorization_endpoint"
      static let apiVersion = "api_version"
      static let appSSHEndpoint = "app_ssh_endpoint"
      static let appSSHHostKeyFingerprint = "app_ssh_host_key_fingerprint"
      static let appSSHOAuthClient = "app_ssh_oauth_client"
      static let loggingEndpoint = "logging_endpoint"
      static let dopplerLoggingEndpoint = "doppler_logging_endpoint"
    }

    var support: String {
        return getStringValue(Keys.support)
    }
    
    var description: String {
        return getStringValue(Keys.description)
    }
    
    var tokenEndpoint: String {
        return getStringValue(Keys.tokenEndpoint)
    }
    
    var authEndpoint: String {
        return getStringValue(Keys.authEndpoint)
    }
    
    var apiVersion: String {
        return getStringValue(Keys.apiVersion)
    }
    
    var appSSHEndpoint: String {
        return getStringValue(Keys.appSSHEndpoint)
    }
    
    var appSSHHostKeyFingerprint: String {
        return getStringValue(Keys.appSSHHostKeyFingerprint)
    }
    
    var appSSHOAuthClient: String {
        return getStringValue(Keys.appSSHOAuthClient)
    }
    
    var loggingEndpoint: String {
        return getStringValue(Keys.loggingEndpoint)
    }
    
    var dopplerLoggingEndpoint: String {
        return getStringValue(Keys.dopplerLoggingEndpoint)
    }
    
    private func getStringValue(key: String) -> String {
        return json[key].stringValue
    }
    
    func serialize() -> [String : String] {
        return [
            Keys.support : support,
            Keys.description : description,
            Keys.tokenEndpoint : tokenEndpoint,
            Keys.authEndpoint : authEndpoint,
            Keys.apiVersion : apiVersion,
            Keys.appSSHEndpoint : appSSHEndpoint,
            Keys.appSSHHostKeyFingerprint : appSSHHostKeyFingerprint,
            Keys.appSSHOAuthClient : appSSHOAuthClient,
            Keys.loggingEndpoint : loggingEndpoint,
            Keys.dopplerLoggingEndpoint : dopplerLoggingEndpoint
        ]
    }
}
