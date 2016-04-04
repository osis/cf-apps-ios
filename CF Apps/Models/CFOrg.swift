import Foundation
import CoreData

class CFOrg: NSManagedObject {
    
    @NSManaged var guid: String
    @NSManaged var name: String
    
}