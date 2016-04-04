//
//  Service.swift
//  CF Apps
//
//  Created by Dwayne Forde on 2015-11-07.
//  Copyright © 2015 Dwayne Forde. All rights reserved.
//

import Foundation

import Foundation
import CoreData
import SwiftyJSON

class Service: NSObject {
    
    var json: JSON?
    
    init(json: JSON) {
        super.init()
        self.json = json
    }
    
    func name() -> String {
        return json!["service_plan"]["service"]["label"].stringValue
    }
    
    func planName() -> String {
        return json!["service_plan"]["name"].stringValue
    }
}