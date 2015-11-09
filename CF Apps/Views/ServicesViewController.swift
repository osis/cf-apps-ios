//
//  ServicesViewController.swift
//  CF Apps
//
//  Created by Dwayne Forde on 2015-11-07.
//  Copyright © 2015 Dwayne Forde. All rights reserved.
//

import Foundation
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

class ServicesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var services: JSON?
    
    override func viewDidLoad() {
    }
    
    func isLoaded() -> Bool {
        return services != nil
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Services"
    }
    
    //    - (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
    //    {
    //    return [animalSectionTitles objectAtIndex:section];
    //    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoaded() {
            return services!.arrayValue.count
        } else {
            return 1
        }
    }
    
    //    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    //
    //    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: nil)
        if isLoaded() {
            let service = Service(json: services![indexPath.row])
            //            let instance = Instance(json: instances!["0"])
            
            cell.textLabel?.text = service.name()
            cell.detailTextLabel?.text = service.planName()
        } else {
            cell.textLabel?.text = "..."
            cell.detailTextLabel?.text = "..."
        }
        return cell
    }
}