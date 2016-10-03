import UIKit
import Foundation
import Alamofire
import SwiftyJSON
import Sync
import DATAStack
import ActionSheetPicker_3_0

class AppsViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet var orgPicker: UIPickerView!
    @IBOutlet var orgPickerButton: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let CellIdentifier = "AppCell"
    
    var dataStack: DATAStack?
    var token:String?
    var items = [CFApp]()
    var currentPage = 1
    var totalPages:Int?
    var orgPickerLabels = [String]()
    var orgPickerValues = [String]()
    var searchText = ""
    
    required init!(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl!.beginRefreshing()
        self.definesPresentationContext = true;
        
        fetchOrganizations()
        observeAccounts()
    }
    
    private func observeAccounts() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(accountSwitched), name: "AccountSwitched", object: nil)
    }
    
    func accountSwitched() {
        clearSearch()
        self.items = [CFApp]()
        self.tableView.reloadData()
        refresh()
        disableOrgsFilter()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case "app":
            let controller = segue.destinationViewController as! AppViewController
            let cell = sender as! UITableViewCell
            let index = self.tableView.indexPathForCell(cell)
            
            controller.app = items[index!.item]
            controller.dataStack = self.dataStack!
            self.searchBar.resignFirstResponder()
        default:
            break
        }
    }
    
    @IBAction func filterOrgClicked(sender: UIBarButtonItem) {
        let currentIndex = self.orgPickerValues.indexOf(CFSession.org()!)
        
        ActionSheetMultipleStringPicker.showPickerWithTitle("Filter by Org", rows: [
            self.orgPickerLabels
            ], initialSelection: [currentIndex!], doneBlock: {
                picker, values, indexes in
                
                let value = values[0] as! Int
                CFSession.org(self.orgPickerValues[value])
                self.refresh()
                
                return
            }, cancelBlock: { ActionMultipleStringCancelBlock in return }, origin: sender)
        
        clearSearch()
    }
    
    func refresh() {
        let offset = self.tableView.contentOffset.y
        let refreshHeight = self.refreshControl!.frame.size.height
        let headerHeight = self.tableView.tableHeaderView!.frame.size.height
        self.tableView.contentOffset.y -= (offset <= headerHeight * -1) ? refreshHeight : refreshHeight + headerHeight
        
        self.refreshControl!.beginRefreshing()
        self.refreshControl!.sendActionsForControlEvents(UIControlEvents.ValueChanged)
    }

    @IBAction func refresh(sender: UIRefreshControl) {
        dispatch_async(dispatch_get_main_queue()) {
            self.currentPage = 1
            self.fetchOrganizations()
        }
    }
}

extension AppsViewController {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if (items.count > 1 && indexPath.row == items.count-1 && currentPage < totalPages) {
            currentPage += 1
            self.tableView.tableFooterView = LoadingIndicatorView()
            fetchApplications()
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as! AppTableViewCell
        let app = self.items[indexPath.row]
        cell.render(app, dataStack: self.dataStack!)
        
        return cell
    }
}

extension AppsViewController {
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        
        // to limit network activity, reload half a second after last key press.
        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: #selector(AppsViewController.refresh as (AppsViewController) -> () -> ()), object: nil)
        self.performSelector(#selector(AppsViewController.refresh as (AppsViewController) -> () -> ()), withObject: nil, afterDelay: 1.0)
    }
}

private extension AppsViewController {
    func setRefreshTitle(title: String) {
        dispatch_async(dispatch_get_main_queue()) {
            self.refreshControl!.attributedTitle = NSAttributedString(string: title)
        }
    }
    
    func clearSearch() {
        self.searchText = ""
        self.searchBar.text = ""
        self.searchBar.resignFirstResponder()
    }
    
    func fetchOrganizations() {
        setRefreshTitle("Updating Organizations")
        CFApi().request(CFRequest.Orgs(),
            success: { (json) in
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    self.handleOrgsResponse(json)
                }
            },
            error: { (statusCode) in
                print([statusCode])
            }
        )
    }
    
    func handleOrgsResponse(json: JSON) {
        do {
            try dataStack!.drop()
        } catch {
            print("--- Could not drop database")
        }
        
        self.orgPickerLabels = []
        self.orgPickerValues = []
        var orgGuids: [String] = []
        
        for (key, _) in json["resources"] {
            let index = Int(key)!
            let resource = json["resources"][index]
            
            self.orgPickerValues.append(resource["guid"].stringValue)
            self.orgPickerLabels.append(resource["name"].stringValue)
            orgGuids.append(resource["guid"].stringValue)
        }
        
        self.enableOrgsFilter()
        
        if CFSession.org() == nil || !orgGuids.contains(CFSession.org()!) {
            CFSession.org(orgGuids[0])
        }
        
        let resources = json["resources"].arrayObject as! [[String:AnyObject]]
        CFStore(dataStack: self.dataStack!).syncOrgs(resources, completion: { error in
            print("--- Orgs Synced")
            self.fetchApplications()
        })
    }
    
    func enableOrgsFilter() {
        dispatch_async(dispatch_get_main_queue()) {
            self.orgPickerButton.enabled = true
            self.orgPickerButton.customView?.alpha = 1
        }
    }
    
    func disableOrgsFilter() {
        dispatch_async(dispatch_get_main_queue()) {
            self.orgPickerButton.enabled = false
            self.orgPickerButton.customView?.alpha = 0.8
        }
    }
    
    func fetchApplications() {
        setRefreshTitle("Updating Apps")
        let urlRequest = CFRequest.Apps(CFSession.org()!, currentPage, searchText)
        CFApi().request(urlRequest, success: { (json) in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                self.handleAppsResponse(json)
            }
            }, error: { (statusCode) in
                print([statusCode])
            }
        )
    }
    
    func fetchCurrentObjects() {
        items = CFStore(dataStack: self.dataStack!).fetchApps()
        
        tableView.reloadData()
        
        self.refreshControl!.endRefreshing()
        setRefreshTitle("Refresh Apps")
        self.tableView.tableFooterView = nil
        if !self.searchBar.isFirstResponder() {
            tableView.setContentOffset(CGPointMake(0,-20), animated: true)
        }
    }
    
    func handleAppsResponse(json: JSON) {
        var appGuids: [String] = []
        
        for (key, _) in json["resources"] {
            let index = Int(key)!
            appGuids.append(json["resources"][index]["guid"].stringValue)
        }
        
        self.totalPages = json["total_pages"].intValue
        
        let resources = json["resources"].arrayObject as! [[String:AnyObject]]
        let clear = currentPage == 1
        CFStore(dataStack: self.dataStack!).syncApps(resources, clear: clear, completion: { error in
            print("--- Apps Synced")
            self.fetchSpaces(appGuids)
        })
    }
    
    func fetchSpaces(appGuids: [String]) {
        setRefreshTitle("Updating Spaces")
        let urlRequest = CFRequest.Spaces(appGuids)
        CFApi().request(urlRequest, success: { (json) in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                self.handleSpacesResponse(json)
            }
            }, error: { (statusCode) in
                print([statusCode])
            }
        )
    }
    
    func handleSpacesResponse(json: JSON) {
        let resources = json["resources"].arrayObject as! [[String:AnyObject]]
        CFStore(dataStack: self.dataStack!).syncSpaces(resources, completion: { (error) in
            print("--- Spaces Synced")
            self.fetchCurrentObjects()
        })
    }
}