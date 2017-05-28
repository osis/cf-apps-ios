import Foundation
import Locksmith

struct CFAccount: ReadableSecureStorable, CreateableSecureStorable, DeleteableSecureStorable,GenericPasswordSecureStorable {
    
    let target: String
    let username: String
    let password: String
    
    let info: CFInfo
    
    let service = "CloudFoundry"
    var account: String { return "\(username)_\(target)" }
    
    var data: [String : Any] {
        let data: [String : AnyObject] = [
            "target" : target as AnyObject,
            "username" : username as AnyObject,
            "password" : password as AnyObject,
            "info" : info.serialize() as AnyObject
        ]

        return data
    }
}
