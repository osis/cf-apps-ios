import Foundation
import CoreData

@objc(CFApp)

class CFApp: NSManagedObject {
    
    @NSManaged var buildpack: String?
    @NSManaged var detectedBuildpack: String?
    @NSManaged var guid: String
    @NSManaged var name: String
    @NSManaged var packageState: String
    @NSManaged var state: String
    @NSManaged var spaceGuid: String
    @NSManaged var diskQuota: Int32
    @NSManaged var memory: Int32
    @NSManaged var command: String
    
    func activeBuildpack() -> String {
        if ((detectedBuildpack?.isEmpty) == false) {
            return detectedBuildpack!
        }
        
        if ((buildpack?.isEmpty) == false) {
            return buildpack!
        }
        
        return ""
    }
    
    func statusImageName() -> String {
        switch state {
        case "STARTED":
            return (packageState == "FAILED") ? "error" : "started"
        default:
            return "stopped"
        }
    }
    
    func formattedMemory() -> String {
        return byteCount(memory)
    }
    
    func formattedDiskQuota() -> String {
        return byteCount(diskQuota)
    }
    
    private func byteCount(i: Int32) -> String {
        let count = Int64.init(i) * 1048576
        return NSByteCountFormatter.stringFromByteCount(count, countStyle: NSByteCountFormatterCountStyle.Memory)
    }
}