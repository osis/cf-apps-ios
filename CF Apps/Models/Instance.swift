import Foundation
import CoreData
import SwiftyJSON

class Instance: NSObject {
    
    var json: JSON?
    
    init(json: JSON) {
        super.init()
        self.json = json
    }
    
    func uri() -> String? {
        let uris = stats()!["uris"]
        return (uris != nil && uris!.arrayValue.count > 0) ? "https://" + uris!.arrayValue[0].stringValue : nil
    }
    
    func usage() -> [String: JSON]? {
        let usage = stats()?["usage"]
        return (usage != nil) ? usage!.dictionaryValue : nil
    }
    
    func stats() -> [String: JSON]? {
        let stats = json!["stats"]
        return (stats != nil) ? stats.dictionaryValue : nil
    }
    
    func state() -> String {
        let state = json!["state"].stringValue
        return (state == "CRASHED" || state == "DOWN") ? "errored" : "started"
    }
    
    func cpuUsagePercentage() -> Double {
        return (usage() != nil) ? round(usage()!["cpu"]!.doubleValue * 100) : 0
    }
    
    func memoryUsage() -> Double {
        let memory = (usage() != nil) ? toMb(round(usage()!["mem"]!.doubleValue * 100)) : 0
        return memory
    }
    
    func memoryQuota() -> Double {
        let memoryQuota = (stats() != nil) ? toMb(stats()!["mem_quota"]!.doubleValue) : 0
        return memoryQuota
    }
    
    func memoryUsagePercentage() -> Double {
        return toPercent(Double(memoryUsage()), quota: Double(memoryQuota()))
    }
    
    func diskUsage() -> Double {
        let disk = (usage() != nil) ? toMb(round(usage()!["disk"]!.doubleValue * 100)) : 0
        return disk
    }
    
    func diskQuota() -> Double {
        let diskQuota = (stats() != nil) ? toMb(stats()!["disk_quota"]!.doubleValue) : 0
        return diskQuota
    }
    
    func diskUsagePercentage() -> Double {
        return toPercent(Double(diskUsage()), quota: Double(diskQuota()))
    }
    
    private func toPercent(usage: Double, quota: Double) -> Double {
        return (quota != 0) ? round(10*(usage / quota))/10: 0
    }
    
    private func toMb(i: Double) -> Double {
        return i / pow(1024.0,2.0)
    }
}