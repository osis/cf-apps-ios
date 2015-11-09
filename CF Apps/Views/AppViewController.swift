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
    @IBOutlet var servicesTableHeightConstraint: NSLayoutConstraint!
    @IBOutlet var instancesTableHeightConstraint: NSLayoutConstraint!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var stateLabel: UILabel!
    @IBOutlet var diskLabel: UILabel!
    @IBOutlet var memoryLabel: UILabel!
    @IBOutlet var buildpackLabel: UILabel!
    @IBOutlet var commandLabel: UILabel!
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
        let delegate = servicesTableView.delegate as! ServicesViewController
        delegate.services = JSON(data)["services"]
        
        dispatch_async(dispatch_get_main_queue(), {
            self.servicesTableView.reloadData()
            let height = self.servicesTableView.contentSize.height
            self.servicesTableHeightConstraint.constant = height
            
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        })
        
        let predicate = NSPredicate(format: "guid == ''")
        var json = JSON(data)
        Sync.changes(
            [json.object],
            inEntityNamed: "CFApp",
            predicate: predicate,
            dataStack: self.dataStack,
            completion: { error in
                self.setSummary(self.app!.guid)
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
        let delegate = instancesTableView.delegate as! InstancesViewConroller
        delegate.instances = JSON(data)
        dispatch_async(dispatch_get_main_queue(), {
            self.instancesTableView.reloadData()
            let height = self.instancesTableView.contentSize.height
            self.instancesTableHeightConstraint.constant = height

            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        })
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
