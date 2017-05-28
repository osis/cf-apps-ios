import Foundation
import DATAStack
import Sync

struct CFStore {
    var dataStack: DATAStack
    
    func syncApp(_ data: [String : Any], guid: String, completion: @escaping (_ error: NSError?) -> Void) -> Void {
        let predicate = NSPredicate(format: "guid == '\(guid)'")
        
        Sync.changes(
            [data],
            inEntityNamed: "CFApp",
            predicate: predicate,
            dataStack: dataStack,
            completion: completion
        )
    }
    
    func syncApps(_ data: [[String : Any]], clear: Bool, completion: @escaping (_ error: NSError?) -> Void) -> Void {
        let predicate: NSPredicate? = (clear) ? nil : NSPredicate(format: "guid == ''")
        
        Sync.changes(
            data,
            inEntityNamed: "CFApp",
            predicate: predicate,
            dataStack: dataStack,
            completion: completion
        )
    }
    
    func syncSpaces(_ data: [[String : Any]], completion: @escaping (_ error: NSError?) -> Void) -> Void {
        Sync.changes(
            data,
            inEntityNamed: "CFSpace",
            predicate: nil,
            dataStack: dataStack,
            completion: completion
        )
    }
    
    func syncOrgs(_ data: [[String : Any]], completion: @escaping (_ error: NSError?) -> Void) -> Void {
        Sync.changes(
            data,
            inEntityNamed: "CFOrg",
            predicate: nil,
            dataStack: dataStack,
            completion: completion
        )
    }
    
    func fetchApp(_ guid: String) throws -> CFApp {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CFApp")
        let predicate = NSPredicate(format: "guid == %@", guid)
        
        request.predicate = predicate
        let apps = try dataStack.mainContext.fetch(request) as! [CFApp]
        return apps[0]
    }
    
    func fetchApps() -> [CFApp] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CFApp")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        return try! dataStack.mainContext.fetch(request) as! [CFApp]
    }
    
    func fetchSpace(_ guid: String) throws -> CFSpace? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CFSpace")
        request.predicate = NSPredicate(format: "guid == %@", guid)
        let spaces = try dataStack.mainContext.fetch(request) as! [CFSpace]
        return (spaces.isEmpty) ? nil : spaces.first
    }
}
