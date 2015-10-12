//
//  AppViewController.swift
//  CF Apps
//
//  Created by Dwayne Forde on 2015-09-02.
//  Copyright (c) 2015 Dwayne Forde. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import DATAStack
import Sync
import SwiftyJSON

class AppViewController: UIViewController {
    @IBOutlet var commandLabel: UILabel!
    @IBOutlet var diskLabel: UILabel!
    @IBOutlet var memoryLabel: UILabel!
    @IBOutlet var buildpackLabel: UILabel!
    @IBOutlet var stateLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var servicesTableView: UITableView!
    @IBOutlet var instancesTableView: UITableView!
    let dataStack: DATAStack
    var app: CFApp?
    
    required init(coder aDecoder: NSCoder) {
                dataStack = DATAStack(modelName: "CFStore")
        super.init(coder: aDecoder)!
    }
    
    override func viewDidLoad() {
        fetchSummary()
        fetchStats()
    }
    
    func fetchSummary() {
        Alamofire.request(CF.AppSummary(app!.guid))
            .validate()
            .responseJSON { (_, _, result) in
                if (result.isFailure) {
                    print(result.value)
                } else {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                        self.handleSummaryResponse(result.value!)
                    }
                }
        }
    }
    
    func handleSummaryResponse(data: AnyObject) {
        let predicate = NSPredicate(format: "guid == ''")
        var json = JSON(data)
        Sync.changes(
            [json.object],
            inEntityNamed: "CFApp",
            predicate: predicate,
            dataStack: self.dataStack,
            completion: { error in
                self.setSummary(json["guid"].stringValue)
            }
        )
    }
    
    func fetchStats() {
        Alamofire.request(CF.AppStats(app!.guid))
            .validate()
            .responseJSON { (_, _, result) in
                if (result.isFailure) {
                    print(result.value)
                } else {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                        self.handleStatsResponse(result.value!)
                    }
                }
        }
    }
    
    func handleStatsResponse(data: AnyObject) {
//       instancesTableView.delegate = InstancesViewConroller()
        let delegate = instancesTableView.delegate as! InstancesViewConroller
        delegate.instances = JSON(data)
        dispatch_async(dispatch_get_main_queue(), {
            self.instancesTableView.reloadData()
            let height = self.instancesTableView.contentSize.height

//            [UIView animateWithDuration:0.25 animations:^{
            var frame = self.instancesTableView.frame
            frame.size.height = height
            self.instancesTableView.frame = frame;
            
            // if you have other controls that should be resized/moved to accommodate
            // the resized tableview, do that here, too
//            }];
        });

    }
    
    func setSummary(guid: String) {
        let request = NSFetchRequest(entityName: "CFApp")
        let predicate = NSPredicate(format: "guid == %@", guid)
        request.predicate = predicate
        
        do {
            let apps = try dataStack.mainContext.executeFetchRequest(request) as! [CFApp]
            self.app = apps[0]
            
            nameLabel.text = app!.name
            stateLabel.text = app!.state
            buildpackLabel.text = app!.activeBuildpack()
            memoryLabel.text = String(app!.memory)
            memoryLabel.text = String(app!.diskQuota)
            commandLabel.text = app!.command
        } catch {
            self.app = nil
            nameLabel.text = "Error"
        }
    }
}
