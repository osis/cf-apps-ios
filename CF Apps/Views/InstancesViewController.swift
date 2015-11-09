//
//  InstancesViewController.swift
//  CF Apps
//
//  Created by Dwayne Forde on 2015-10-03.
//  Copyright © 2015 Dwayne Forde. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class InstancesViewConroller: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var instances: JSON?
    
    override func viewDidLoad() {
    }
    
    func isLoaded() -> Bool {
        return instances != nil
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Instances"
    }
    
//    - (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//    {
//    return [animalSectionTitles objectAtIndex:section];
//    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoaded() {
            return instances!.count
//            return instances!.count + 5
        } else {
            return 1
        }
    }
    
//    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//        
//    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        if isLoaded() {
            let instance = Instance(json: instances!["\(indexPath.row)"])
//            let instance = Instance(json: instances!["0"])
            cell = tableView.dequeueReusableCellWithIdentifier("InstanceCell") as UITableViewCell!
 
            let indexLabel = cell!.viewWithTag(1) as! UILabel
            indexLabel.text = String(indexPath.row)
            
            let cpuLabel = cell!.viewWithTag(2) as! UILabel
            cpuLabel.text = "\(instance.cpuUsagePercentage())%"
            
            let memoryLabel = cell!.viewWithTag(3) as! UILabel
            memoryLabel.text = "\(instance.memoryUsagePercentage())%"
            
            let diskLabel = cell!.viewWithTag(4) as! UILabel
            diskLabel.text = "\(instance.diskUsagePercentage())%"
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("InstanceCell") as UITableViewCell!
            
            let indexLabel = cell!.viewWithTag(1) as! UILabel
            indexLabel.text = "..."
            
            let cpuLabel = cell!.viewWithTag(2) as! UILabel
            cpuLabel.text = "..."
            
            let memoryLabel = cell!.viewWithTag(3) as! UILabel
            memoryLabel.text = "..."
            
            let diskLabel = cell!.viewWithTag(4) as! UILabel
            diskLabel.text = "..."
        }
        return cell!
    }
}
