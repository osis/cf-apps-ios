import Foundation
import SwiftyJSON

class CFEvent: NSObject {
    var json: JSON?
    
    init(json: JSON) {
        super.init()
        self.json = json
    }
    
    func date() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        let dateString = json!["timestamp"].stringValue
        let date = dateFormatter.dateFromString(dateString)
        
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .MediumStyle
        
        return dateFormatter.stringFromDate(date!)
    }
    
    func type() -> String? {
        switch self.rawType() {
        case "audit.app.update":
            return isOperationalEvent() ? "operation" : "update"
        case "app.crash":
            return "crash"
        default:
            return nil
        }
    }
    
    func rawType() -> String {
        return json!["type"].stringValue
    }
    
    func isOperationalEvent() -> Bool {
        return rawType() == "audit.app.update" && state() != nil
    }
    
    func state() -> String? {
        let state = json!["metadata"]["request"]["state"]
        return (state != nil) ? state.stringValue : nil
    }
    
    func name() -> String? {
        let name = json!["metadata"]["request"]["name"]
        return (name != nil) ? name.stringValue : nil
    }
    
    func instances() -> Int? {
        let instances = json!["metadata"]["request"]["instances"]
        return (instances != nil) ? instances.intValue : nil
    }
    
    func memory() -> String? {
        let memory = json!["metadata"]["request"]["memory"]
        return (memory != nil) ? formattedMemory(memory.int64Value) : nil
    }
    
    func diskQuota() -> String? {
        let disk = json!["metadata"]["request"]["disk_quota"]
        return (disk != nil) ? formattedDiskQuota(disk.int64Value) : nil
    }
    
    func buildpack() -> String? {
        let buildpack = json!["metadata"]["request"]["buildpack"]
        return (buildpack != nil) ? buildpack.stringValue : nil
    }
    
    func environmentJson() -> String? {
        let envJson = json!["metadata"]["request"]["environment_json"]
        return (envJson != nil) ? envJson.stringValue : nil
    }
    
    func index() -> Int? {
        let index = json!["metadata"]["index"]
        return (index != nil) ? index.intValue : nil
    }
    
    func exitDesciption() -> String? {
        let description = json!["metadata"]["exit_description"]
        return (description != nil) ? description.stringValue.stringByReplacingOccurrencesOfString("\n\n", withString: "\n") : nil
    }
    
    func reason() -> String? {
        let reason = json!["metadata"]["reason"]
        return (reason != nil) ? reason.stringValue : nil
    }
    
    func attributeSummary() -> String {
        var attributes = [String]()
        
        if let name = name() {
            attributes.append("Name: \(name)")
        }
        
        if let instances = instances() {
            attributes.append("Instances: \(instances)")
        }
        
        if let memory = memory() {
            attributes.append("Memory: \(memory)")
        }
        
        if let disk = diskQuota() {
            attributes.append("Disk: \(disk)")
        }
        
        if let buildpack = buildpack() {
            attributes.append("Buildpack: \(buildpack)")
        }
        
        if let envJson = environmentJson() {
            attributes.append("Envionment JSON: \(envJson)")
        }
        
        return attributes.joinWithSeparator(", ")
    }
    
    private func formattedMemory(value: Int64) -> String {
        return byteCount(value)
    }
    
    private func formattedDiskQuota(value: Int64) -> String {
        return byteCount(value)
    }
    
    private func byteCount(i: Int64) -> String {
        let count = i * 1048576
        return NSByteCountFormatter.stringFromByteCount(count, countStyle: NSByteCountFormatterCountStyle.Memory)
    }
}