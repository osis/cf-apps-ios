import Foundation
import DATAStack
import Sync

struct CFStore {
    var dataStack: DATAStack
    
    func syncApp(data: [String : AnyObject], guid: String, completion: (error: NSError?) -> Void) -> Void {
        let predicate = NSPredicate(format: "guid == '\(guid)'")
        
        Sync.changes(
            [data],
            inEntityNamed: "CFApp",
            predicate: predicate,
            dataStack: dataStack,
            completion: completion
        )
    }
    
    func syncApps(data: [[String : AnyObject]], clear: Bool, completion: (error: NSError?) -> Void) -> Void {
        let predicate: NSPredicate? = (clear) ? nil : NSPredicate(format: "guid == ''")
        
        Sync.changes(
            data,
            inEntityNamed: "CFApp",
            predicate: predicate,
            dataStack: dataStack,
            completion: completion
        )
    }
    
    func syncSpaces(data: [[String : AnyObject]], completion: (error: NSError?) -> Void) -> Void {
        Sync.changes(
            data,
            inEntityNamed: "CFSpace",
            predicate: nil,
            dataStack: dataStack,
            completion: completion
        )
    }
    
    func syncOrgs(data: [[String : AnyObject]], completion: (error: NSError?) -> Void) -> Void {
        Sync.changes(
            data,
            inEntityNamed: "CFOrg",
            predicate: nil,
            dataStack: dataStack,
            completion: completion
        )
    }
    
    func fetchApp(guid: String) throws -> CFApp {
        let request = NSFetchRequest(entityName: "CFApp")
        let predicate = NSPredicate(format: "guid == %@", guid)
        
        request.predicate = predicate
        let apps = try dataStack.mainContext.executeFetchRequest(request) as! [CFApp]
        return apps[0]
    }
    
    func fetchApps() -> [CFApp] {
        let request = NSFetchRequest(entityName: "CFApp")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        return try! dataStack.mainContext.executeFetchRequest(request) as! [CFApp]
    }
    
    func fetchSpace(guid: String) throws -> AnyObject? {
        let request = NSFetchRequest(entityName: "CFSpace")
        request.predicate = NSPredicate(format: "guid == %@", guid)
        let spaces = try dataStack.mainContext.executeFetchRequest(request)
        return (spaces.isEmpty) ? nil : spaces[0]
    }
}