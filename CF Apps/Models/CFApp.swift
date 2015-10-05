//
//  CFApp.swift
//  CF Commander
//
//  Created by Dwayne Forde on 2015-07-01.
//  Copyright (c) 2015 Dwayne Forde. All rights reserved.
//

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
}