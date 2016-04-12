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
    
    var dataStack: DATAStack?
    var token:String?
    var items = [CFApp]()
    var requestCount = 0
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
            controller.dataStack = self.dataStack!
        }
    }
    
    @IBAction func filterOrgClicked(sender: UIBarButtonItem) {
        let currentIndex = self.orgPickerValues.indexOf(CFSession.getOrg()!)
        ActionSheetMultipleStringPicker.showPickerWithTitle("Filter by Org", rows: [
            self.orgPickerLabels
            ], initialSelection: [currentIndex!], doneBlock: {
                picker, values, indexes in
                
                let value = values[0] as! Int
                CFSession.setOrg(self.orgPickerValues[value])
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
            self.dataStack!.drop()
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
        CFApi().request(CFRequest.Orgs(),
            success: { (json) in
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    self.handleOrgsResponse(json)
                }
            },
            error: { (statusCode) in
                print(statusCode)
            }
        )
    }
    
    func handleOrgsResponse(json: JSON) {
        dataStack!.drop()
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
        
        if CFSession.isOrgStale(orgGuids) {
            CFSession.setOrg(orgGuids[0])
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
        dispatch_async(dispatch_get_main_queue()) {
            self.orgPickerButton.enabled = true
            self.orgPickerButton.customView?.alpha = 1
        }
    }
    
    func fetchApplications() {
        setRefreshTitle("Updating Apps")
        let urlRequest = CFRequest.Apps(CFSession.getOrg()!, currentPage)
        CFApi().request(urlRequest, success: { (json) in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                self.handleAppsResponse(json)
            }
            }, error: { (statusCode) in
                print(statusCode)
            }
        )
    }
    
    func fetchCurrentObjects() {
        self.requestCount -= 1
        if self.requestCount == 0 {
            let request = NSFetchRequest(entityName: "CFApp")
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            
            try! items = dataStack!.mainContext.executeFetchRequest(request) as! [CFApp]
            
            tableView.reloadData()
            
            self.refreshControl!.endRefreshing()
            self.tableView.tableFooterView = nil
            setRefreshTitle("Refresh Apps")
        }
    }
    
    func handleAppsResponse(json: JSON) {
        var appGuids: [String] = []
        
        for (key, _) in json["resources"] {
            let index = Int(key)!
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
        let urlRequest = CFRequest.Spaces(appGuids)
        CFApi().request(urlRequest, success: { (json) in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                self.handleSpacesResponse(json)
            }
            }, error: { (statusCode) in
                print(statusCode)
            }
        )
    }

    func handleSpacesResponse(json: JSON) {
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
            currentPage += 1
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
            let spaces = try dataStack!.mainContext.executeFetchRequest(request)
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
    
    @IBAction func logoutClicked(sender: UIBarButtonItem) {
        CFSession.logout()
    }
}