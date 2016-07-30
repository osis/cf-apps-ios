import UIKit
import Foundation
import Alamofire
import SwiftyJSON
import Sync
import DATAStack
import ActionSheetPicker_3_0

class AppsViewController: UITableViewController {
    
    @IBOutlet var orgPicker: UIPickerView!
    @IBOutlet var orgPickerButton: UIBarButtonItem!
    
    let CellIdentifier = "AppCell"
    
    var dataStack: DATAStack?
    var token:String?
    var items = [CFApp]()
    var currentPage = 1
    var totalPages:Int?
    var orgPickerLabels = [String]()
    var orgPickerValues = [String]()

    required init!(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl!.beginRefreshing()
        fetchOrganizations()
        observeAccounts()
    }
    
    func setupPicker() {
        let delegate = OrgPicker()
        self.orgPicker.dataSource = delegate;
        self.orgPicker.delegate = delegate;
    }
    
    private func observeAccounts() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(accountSwitched), name: "AccountSwitched", object: nil)
    }
    
    func accountSwitched() {
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
    }
    
    func refresh() {
        do {
            try dataStack!.drop()
        } catch {
            debugPrint("Could not drop database")
        }
        
        self.tableView.contentOffset.y -= self.refreshControl!.frame.size.height
        self.refreshControl!.beginRefreshing()
        self.refreshControl!.sendActionsForControlEvents(UIControlEvents.ValueChanged)
    }

    @IBAction func refresh(sender: UIRefreshControl) {
        dispatch_async(dispatch_get_main_queue()) {
            self.currentPage = 1
            self.fetchOrganizations()
        }
    }
    
    func setRefreshTitle(title: String) {
        dispatch_async(dispatch_get_main_queue()) {
            self.refreshControl!.attributedTitle = NSAttributedString(string: title)
        }
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
        let urlRequest = CFRequest.Apps(CFSession.org()!, currentPage)
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