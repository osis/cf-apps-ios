import Foundation
import CoreData

@objc(CFOrg)

class CFOrg: NSManagedObject {
    
    @NSManaged var guid: String
    @NSManaged var name: String
    
}
