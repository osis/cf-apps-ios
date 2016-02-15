//
//  Instance.swift
//  CF Apps
//
//  Created by Dwayne Forde on 2015-10-03.
//  Copyright © 2015 Dwayne Forde. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

class Instance: NSManagedObject {
    
    var json: JSON?
    
    required init(json: JSON) {
        self.json = json
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
        return (state == "CRASHED" || state == "DOWN") ? "error" : "started"
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
        return (quota != 0) ? round(usage / quota) * 100 : 0
    }
    
    private func toMb(i: Double) -> Double {
        return i / pow(1024.0,2.0)
    }
}