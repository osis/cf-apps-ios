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
import ActionSheetPicker_3_0

class AppsViewController: UITableViewController {
    
    @IBOutlet var orgPicker: UIPickerView!
    @IBOutlet var logoutButton: UIBarButtonItem!
    @IBOutlet var orgPickerButton: UIBarButtonItem!
    
    let CellIdentifier = "AppCell"
    let dataStack: DATAStack
    
    var token:String?
    var items = [CFApp]()
    var requestCount = 0
    var currentPage = 1
    var orgGuid:String?
    var totalPages:Int?
    var orgPickerLabels = [String]()
    var orgPickerValues = [String]()

    required init!(coder aDecoder: NSCoder) {
        dataStack = DATAStack(modelName: "CFStore")
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl!.beginRefreshing()
        self.requestCount = 3
        fetchOrganizations()
    }
    
    func setupPicker() {
        let delegate = OrgPicker()
        self.orgPicker.dataSource = delegate;
        self.orgPicker.delegate = delegate;
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "app") {
            let controller = segue.destinationViewController as! AppViewController
            let cell = sender as! UITableViewCell
            let index = self.tableView.indexPathForCell(cell)
            
            controller.app = items[index!.item]
        } else if (segue.identifier == "logout") {
            CFSession.reset()
        }
    }
    
    @IBAction func filterOrgClicked(sender: UIBarButtonItem) {
        let currentIndex = self.orgPickerValues.indexOf(self.orgGuid!)
        ActionSheetMultipleStringPicker.showPickerWithTitle("Filter by Org", rows: [
            self.orgPickerLabels
            ], initialSelection: [currentIndex!], doneBlock: {
                picker, values, indexes in
                
                print("values = \(values)")
                print("indexes = \(indexes)")
                print("picker = \(picker)")
                let value = values[0] as! Int
                self.orgGuid = self.orgPickerValues[value]
                self.refresh()
                return
            }, cancelBlock: { ActionMultipleStringCancelBlock in return }, origin: sender)
    }
    
    func refresh() {
        dispatch_async(dispatch_get_main_queue()) {
            self.refreshControl!.beginRefreshing()
            self.tableView.setContentOffset(CGPointMake(0, self.tableView.contentOffset.y-self.refreshControl!.frame.size.height), animated: true)
            self.currentPage = 1
            self.requestCount = 3
            self.dataStack.drop()
            self.fetchOrganizations()
        }
    }
    
    @IBAction func refresh(sender: UIRefreshControl) {
        dispatch_async(dispatch_get_main_queue()) {
        self.currentPage = 1
        self.requestCount = 3
        self.fetchOrganizations()
        }
    }
    
    func setRefreshTitle(title: String) {
        self.refreshControl!.attributedTitle = NSAttributedString(string: title)
    }
    
    func fetchOrganizations() {
        setRefreshTitle("Updating Organizations")
        CFApi.orgs(
            { (json) in
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    self.handleOrgsResponse(json)
                }
            },
            error: { (statusCode) in
                debugPrint(statusCode)
            }
        )
    }
    
    func handleOrgsResponse(var json: JSON) {
        dataStack.drop()
        self.orgPickerLabels = []
        self.orgPickerValues = []
        
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
            
            
            self.orgPickerValues.append(json["resources"][index]["guid"].stringValue)
            self.orgPickerLabels.append(json["resources"][index]["name"].stringValue)
        }
        
        self.enableOrgsFilter()
        
        if (self.orgGuid == nil) {
            self.orgGuid = json["resources"][0]["guid"].stringValue
        }
        
        self.fetchApplications()
        
        Sync.changes(
            json["resources"].arrayObject,
            inEntityNamed: "CFOrg",
            predicate: nil,
            dataStack: self.dataStack,
            completion: { error in
                print("--- Orgs Synced")
                self.fetchCurrentObjects()
            }
        )
    }
    
    func enableOrgsFilter() {
        self.orgPickerButton.enabled = true
        self.orgPickerButton.customView?.alpha = 1
    }
    
    func fetchApplications() {
        setRefreshTitle("Updating Apps")
        CFApi.apps(orgGuid!, page: currentPage, success: { (json) in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                self.handleAppsResponse(json)
            }
            }, error: { (statusCode) in
                debugPrint(statusCode)
            }
        )
    }
    
    func fetchCurrentObjects() {
        self.requestCount--
        if self.requestCount == 0 {
            let request = NSFetchRequest(entityName: "CFApp")
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            
            try! items = dataStack.mainContext.executeFetchRequest(request) as! [CFApp]
            
            tableView.reloadData()
            
            self.refreshControl!.endRefreshing()
            self.tableView.tableFooterView = nil
            setRefreshTitle("Refresh Apps")
        }
    }
    
    func handleAppsResponse(var json: JSON) {
        var appGuids: [String] = []
        
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
            
            appGuids.append(json["resources"][index]["guid"].stringValue)
        }
        
        self.totalPages = json["total_pages"].intValue

        let predicate: NSPredicate? = (currentPage > 1) ? NSPredicate(format: "guid == ''") : nil
        
        self.fetchSpaces(appGuids)
        
        Sync.changes(
            json["resources"].arrayObject,
            inEntityNamed: "CFApp",
            predicate: predicate,
            dataStack: self.dataStack,
            completion: { error in
                print("--- Apps Synced")
                self.fetchCurrentObjects()
            }
        )
    }
    
    func fetchSpaces(appGuids: [String]) {
        setRefreshTitle("Updating Spaces")
        CFApi.spaces(appGuids, success: { (json) in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                self.handleSpacesResponse(json)
            }
            }, error: { (statusCode) in
                debugPrint(statusCode)
            }
        )
    }

    func handleSpacesResponse(var json: JSON) {
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
        
        Sync.changes(
            json["resources"].arrayObject,
            inEntityNamed: "CFSpace",
            predicate: nil,
            dataStack: self.dataStack,
            completion: { error in
                self.fetchCurrentObjects()
                print("--- Spaces Synced")
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
            self.requestCount = 2
            fetchApplications()
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
        let spaceLabel: UILabel = cell.viewWithTag(6) as! UILabel
        
        let request = NSFetchRequest(entityName: "CFSpace")
        request.predicate = NSPredicate(format: "guid == %@", cfApp.spaceGuid)
        do {
            let spaces = try dataStack.mainContext.executeFetchRequest(request)
            if spaces.count != 0 { spaceLabel.text = spaces[0].name }
        } catch {
            spaceLabel.text = "N/A"
        }
        
        appNameLabel.text = cfApp.name
        memLabel.text = cfApp.formattedMemory()
        diskLabel.text = cfApp.formattedDiskQuota()
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