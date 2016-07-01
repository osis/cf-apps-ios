import Foundation
import CoreData

@objc(CFSpace)

class CFSpace: NSManagedObject {
    
    @NSManaged var guid: String
    @NSManaged var name: String
    
}