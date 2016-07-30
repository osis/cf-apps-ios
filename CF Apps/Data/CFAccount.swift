import Foundation
import Locksmith

struct CFAccount: ReadableSecureStorable, CreateableSecureStorable, DeleteableSecureStorable,GenericPasswordSecureStorable {
    
    let target: String
    let username: String
    let password: String
    
    let info: CFInfo
    
    let service = "CloudFoundry"
    var account: String { return "\(username)_\(target)" }
    
    var data: [String : AnyObject] {
        let data: [String : AnyObject] = [
            "target" : target,
            "username" : username,
            "password" : password,
            "info" : info.serialize()
        ]

        return data
    }
}