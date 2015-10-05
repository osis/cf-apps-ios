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
    
    func usage() -> [String: JSON] {
        return stats()["usage"]!.dictionaryValue
    }
    
    func stats() -> [String: JSON] {
        return json!["stats"].dictionaryValue
    }
    
    func cpuUsagePercentage() -> Double {
        return round(usage()["cpu"]!.doubleValue * 100)
    }
    
    func memoryUsage() -> Double {
        let memory = usage()["mem"]!.doubleValue
        return toMb(memory)
    }
    
    func memoryQuota() -> Double {
        let memoryQuota = stats()["mem_quota"]!.doubleValue
        return toMb(memoryQuota)
    }
    
    func memoryUsagePercentage() -> Double {
        return round((Double(memoryUsage()) / Double(memoryQuota())) * 100)
    }
    
    func diskUsage() -> Double {
        let disk = usage()["disk"]!.doubleValue
        return toMb(disk)
    }
    
    func diskQuota() -> Double {
        let diskQuota = stats()["disk_quota"]!.doubleValue
        return toMb(diskQuota)
    }
    
    func diskUsagePercentage() -> Double {
        return round((Double(diskUsage()) / Double(diskQuota())) * 100)
    }
    
    private func toMb(i: Double) -> Double {
        return i / pow(1024.0,2.0)
    }
}