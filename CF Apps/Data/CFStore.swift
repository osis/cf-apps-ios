import Foundation
import DATAStack
import Sync

enum CFStore {
    case App([[String : AnyObject]], DATAStack, String, (error: NSError?) -> Void)
    case Apps([[String : AnyObject]], DATAStack, Bool, (error: NSError?) -> Void)
    case Spaces([[String : AnyObject]], DATAStack, (error: NSError?) -> Void)
    case Orgs([[String : AnyObject]], DATAStack, (error: NSError?) -> Void)
    
    var entityName: String {
        switch self {
        case .App:
            return "CFApp"
        case .Apps:
            return "CFApp"
        case .Spaces:
            return "CFSpace"
        case .Orgs:
            return "CFOrg"
        }
    }
    
    func sync() {
        var clear: Bool = true
        var data: [[String : AnyObject]]?
        var dataStack: DATAStack?
        var completion: ((error: NSError?) -> Void)?
        var predicate: NSPredicate? = nil
        
        switch self {
        case .App(let _data, let _dataStack, let _guid, let _completion):
            data = _data
            dataStack = _dataStack
            completion = _completion
            predicate = NSPredicate(format: "guid == '\(_guid)'")
        case .Apps(let _data, let _dataStack, let _clear, let _completion):
            data = _data
            dataStack = _dataStack
            clear = _clear
            completion = _completion
            predicate = (clear) ? nil : NSPredicate(format: "guid == ''")
        case .Spaces(let _data, let _dataStack, let _completion):
            data = _data
            dataStack = _dataStack
            completion = _completion
        case .Orgs(let _data, let _dataStack, let _completion):
            data = _data
            dataStack = _dataStack
            completion = _completion
        }
        
        Sync.changes(
            data!,
            inEntityNamed: entityName,
            predicate: predicate,
            dataStack: dataStack!,
            completion: completion!
        )
    }
}