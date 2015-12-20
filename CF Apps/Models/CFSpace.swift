//
//  CFSpace.swift
//  CF Apps
//
//  Created by Dwayne Forde on 2015-12-13.
//  Copyright © 2015 Dwayne Forde. All rights reserved.
//

import Foundation
import CoreData

class CFSpace: NSManagedObject {
    
    @NSManaged var guid: String
    @NSManaged var name: String
    
}