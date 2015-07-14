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
    var currentPage = 0

    required init!(coder aDecoder: NSCoder!) {
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
    
    @IBAction func refresh(sender: UIRefreshControl) {
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
        let (username: String?, password: String?) = Keychain.getCredentials()
        
        setRefreshTitle("Authenticating...")
        CFApi.login(username!, password: password!, success: {
            self.fetchApplications(completeClosure)
            }, error: {
                println("Well this is embarrassing...")
        })
    }
    
    func fetchApplications(completeClosure: () -> Void) {
        setRefreshTitle("Fetching Apps...")
        Alamofire.request(CF.Apps())
            .validate()
            .responseJSON { (request, response, data, error) in
                if (error != nil) {
                    println(error)
                } else {
                    self.handleAppsResponse(data!, completeClosure: completeClosure)
                }
        }
    }
    
    func fetchCurrentObjects() {
        let request = NSFetchRequest(entityName: "CFApp")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        items = dataStack.mainContext.executeFetchRequest(request, error: nil) as! [CFApp]
        
        tableView.reloadData()
        setRefreshTitle("Refresh Apps...")
    }
    
    func handleAppsResponse(data: AnyObject, completeClosure: () -> Void) {
        var json = JSON(data)
        for (key: String, subJson: JSON) in json["resources"] {
            var index = key.toInt()!
            
            for (entityKey: String, entitySubJson: JSON) in subJson["entity"] {
                json["resources"][index][entityKey] = entitySubJson
            }
            json["resources"][index]["entity"] = nil
            
            for (metadataKey: String, metadataSubJson: JSON) in subJson["metadata"] {
                json["resources"][index][metadataKey] = metadataSubJson
            }
            json["resources"][index]["metadata"] = nil

        }

        Sync.changes(
            json["resources"].arrayObject,
            inEntityNamed: "CFApp",
            dataStack: dataStack,
            completion: { error in
                completeClosure()
            }
        )
        println(json["resources"][0])
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return appCell(indexPath)
    }
    
    func appCell(indexPath: NSIndexPath) -> UITableViewCell {
        var cell = self.tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as! UITableViewCell
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
    
    func loadingCell() -> UITableViewCell {
        var cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
        var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        
        activityIndicator.center = cell.center
        cell.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        cell.tag = 99
        
        return cell
    }
    
//    func mergeChild(parentJson: JSON, childKey: String) {
//        for (key: String, subJson: JSON) in parentJson[childKey] {
//            parentJson.dictionaryObject[key] = subJson.dictionaryObject
//        }
//        parentJson[childKey] = nil
//    }
}