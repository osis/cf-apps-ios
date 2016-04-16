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
    @IBOutlet var scrollView: UIScrollView!
    
    var dataStack: DATAStack?
    var app: CFApp?
    var refreshControl: UIRefreshControl!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func viewDidLoad() {
        addRefreshControl()
        loadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "logs") {
            let controller = segue.destinationViewController as! LogsViewController
            controller.appGuid = self.app!.guid
        }
    }
    
    func loadData() {
        fetchSummary()
        
        if (app!.statusImageName() == "started") {
            fetchStats()
        } else {
            hideInstancesTable()
        }
    }
    
    func hideInstancesTable() {
        self.instancesTableView.hidden = true
        self.instancesTableHeightConstraint.constant = 0
    }
    
    func fetchSummary() {
        servicesTableView.tableFooterView = loadingCell()
        let urlRequest = CFRequest.AppSummary(app!.guid)
        CFApi().request(urlRequest,
            success: { (json) in
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    self.handleSummaryResponse(json)
                    self.refreshControl.endRefreshing()
                }
            },
            error: { (statusCode) in
                print(statusCode)
        })
    }
    
    func addRefreshControl() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Refresh Summary")
        self.refreshControl.addTarget(self, action: #selector(AppViewController.loadData), forControlEvents: UIControlEvents.ValueChanged)
        self.scrollView.addSubview(self.refreshControl)
    }
    
    func handleSummaryResponse(json: JSON) {
        let delegate = servicesTableView.delegate as! ServicesViewController
        delegate.services = json["services"]
        
        let predicate = NSPredicate(format: "guid == ''")
        Sync.changes(
            [json.object],
            inEntityNamed: "CFApp",
            predicate: predicate,
            dataStack: self.dataStack,
            completion: { error in
                self.setSummary(self.app!.guid)
            }
        )
        
        dispatch_async(dispatch_get_main_queue(), {
            self.servicesTableView.tableFooterView = nil
            self.servicesTableView.reloadData()
            let height = self.servicesTableView.contentSize.height
            self.servicesTableHeightConstraint.constant = height
            
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        })
    }
    
    func fetchStats() {
        instancesTableView.tableFooterView = loadingCell()
        
        let urlRequest = CFRequest.AppStats(app!.guid)
        CFApi().request(urlRequest,
            success: { (json) in
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    self.handleStatsResponse(json)
                }
            },
            error: { (statusCode) in
                print(statusCode)
        })
    }
    
    func handleStatsResponse(json: JSON) {
        let delegate = instancesTableView.delegate as! InstancesViewConroller
        delegate.instances = json
        dispatch_async(dispatch_get_main_queue(), {
            self.instancesTableView.tableFooterView = nil
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
            let apps = try dataStack!.mainContext.executeFetchRequest(request) as! [CFApp]
            self.app = apps[0]
            
            nameLabel.text = app!.name
            stateLabel.text = app!.state
            buildpackLabel.text = app!.activeBuildpack()
            memoryLabel.text = app!.formattedMemory()
            diskLabel.text = app!.formattedDiskQuota()
            commandLabel.text = app!.command
        } catch {
            self.app = nil
            nameLabel.text = "Error"
        }
    }
    
    func loadingCell() -> UIActivityIndicatorView {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        spinner.startAnimating()
        spinner.frame = CGRectMake(0, 0, 320, 44)
        return spinner
    }
}
