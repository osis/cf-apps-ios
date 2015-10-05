//
//  AppsViewController.swift
//  CF Commander
//
//  Created by Dwayne Forde on 2015-06-14.
//  Copyright (c) 2015 Dwayne Forde. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import SwiftyJSON
import Sync
import DATAStack

class AppsViewController: UITableViewController {
    let CellIdentifier = "AppCell"
    var token:String?
    let dataStack: DATAStack
    var items = [CFApp]()
    var currentPage = 1
    var totalPages:Int?

    required init!(coder aDecoder: NSCoder) {
        dataStack = DATAStack(modelName: "CFStore")
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl!.beginRefreshing()
        loadApplications({
            self.fetchCurrentObjects()
            self.refreshControl!.endRefreshing()
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "app") {
            let controller = segue.destinationViewController as! AppViewController
            let cell = sender as! UITableViewCell
            let index = self.tableView.indexPathForCell(cell)
            
            controller.app = items[index!.item]
        }
    }
    
    @IBAction func refresh(sender: UIRefreshControl) {
        currentPage = 1
        dataStack.drop()
        loadApplications({
            sender.endRefreshing()
            self.fetchCurrentObjects()
        })
    }
    
    func setRefreshTitle(title: String) {
        self.refreshControl!.attributedTitle = NSAttributedString(string: title)
    }
    
    func loadApplications(completeClosure: () -> Void) {
        if (CF.oauthToken == nil) {
            login(completeClosure)
        } else {
            fetchApplications(completeClosure)
        }
    }
    
    func login(completeClosure: () -> Void) {
        let (username, password) = Keychain.getCredentials()
        
        setRefreshTitle("Authenticating")
        CFApi.login(username!, password: password!, success: {
            self.fetchApplications(completeClosure)
            }, error: {
                print("Well this is embarrassing...")
        })
    }
    
    func fetchApplications(completeClosure: () -> Void) {
        setRefreshTitle("Fetching Apps")
        Alamofire.request(CF.Apps(currentPage))
            .validate()
            .responseJSON { (_, _, result) in
                if (result.isSuccess) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                        self.handleAppsResponse(result.value!, completeClosure: completeClosure)
                    }
                } else {
                    print(result.value)
                }
        }
    }
    
    func fetchCurrentObjects() {
        let request = NSFetchRequest(entityName: "CFApp")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        try! items = dataStack.mainContext.executeFetchRequest(request) as! [CFApp]
        
        tableView.reloadData()
        setRefreshTitle("Refresh Apps")
    }
    
    func handleAppsResponse(data: AnyObject, completeClosure: () -> Void) {
        var json = JSON(data)
        for (key, subJson) in json["resources"] {
            let index = Int(key)!
            
            for (entityKey, entitySubJson) in subJson["entity"] {
                json["resources"][index][entityKey] = entitySubJson
            }
            json["resources"][index]["entity"] = nil
            
            for (metadataKey, metadataSubJson) in subJson["metadata"] {
                json["resources"][index][metadataKey] = metadataSubJson
            }
            json["resources"][index]["metadata"] = nil
        }
        
        self.totalPages = json["total_pages"].intValue
        
//        let app_count = json["total_results"]
        
        let predicate = NSPredicate(format: "guid == ''")

        Sync.changes(
            json["resources"].arrayObject,
            inEntityNamed: "CFApp",
            predicate: predicate,
            dataStack: self.dataStack,
            completion: { error in
                completeClosure()
            }
        )
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if (items.count > 1 && indexPath.row == items.count-1 && currentPage < totalPages) {
            currentPage++
            self.tableView.tableFooterView = loadingCell()
            loadApplications({
                self.fetchCurrentObjects()
                self.tableView.tableFooterView = nil
            })
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return appCell(indexPath)
    }
    
    func appCell(indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as UITableViewCell!
        let cfApp = self.items[indexPath.row]
        
        let appNameLabel: UILabel = cell.viewWithTag(1) as! UILabel
        let memLabel: UILabel = cell.viewWithTag(2) as! UILabel
        let diskLabel: UILabel = cell.viewWithTag(3) as! UILabel
        let stateView: UIImageView = cell.viewWithTag(4) as! UIImageView
        let buildpackLabel: UILabel = cell.viewWithTag(5) as! UILabel
        
        appNameLabel.text = cfApp.name
        memLabel.text = String(stringInterpolationSegment: cfApp.memory)
        diskLabel.text = String(stringInterpolationSegment: cfApp.diskQuota)
        stateView.image = UIImage(named: cfApp.statusImageName())
        buildpackLabel.text = cfApp.activeBuildpack()
    
        return cell
    }
    
    func loadingCell() -> UIActivityIndicatorView {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        spinner.startAnimating()
        spinner.frame = CGRectMake(0, 0, 320, 44)
        return spinner
    }
}