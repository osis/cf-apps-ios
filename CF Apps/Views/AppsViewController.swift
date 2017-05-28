import UIKit
import Foundation
import Alamofire
import SwiftyJSON
import Sync
import DATAStack
import ActionSheetPicker_3_0
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


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
    
    fileprivate func observeAccounts() {
        NotificationCenter.default.addObserver(self, selector: #selector(accountSwitched), name: NSNotification.Name(rawValue: "AccountSwitched"), object: nil)
    }
    
    func accountSwitched() {
        clearSearch()
        self.items = [CFApp]()
        self.tableView.reloadData()
        refresh()
        disableOrgsFilter()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "app":
            let controller = segue.destination as! AppViewController
            let cell = sender as! UITableViewCell
            let index = self.tableView.indexPath(for: cell)
            
            controller.app = items[index!.item]
            controller.dataStack = self.dataStack!
            self.searchBar.resignFirstResponder()
        default:
            break
        }
    }
    
    @IBAction func filterOrgClicked(_ sender: UIBarButtonItem) {
        let currentIndex = self.orgPickerValues.index(of: CFSession.org()!)
        
        ActionSheetMultipleStringPicker.show(withTitle: "Filter by Org", rows: [
            self.orgPickerLabels
            ], initialSelection: [currentIndex!], doneBlock: {
                picker, values, indexes in
                
                let value = values?[0] as! Int
                CFSession.org(self.orgPickerValues[value])
                self.refresh()
                
                return
            }, cancel: { ActionMultipleStringCancelBlock in return }, origin: sender)
        
        clearSearch()
    }
    
    func refresh() {
        let offset = self.tableView.contentOffset.y
        let refreshHeight = self.refreshControl!.frame.size.height
        let headerHeight = self.tableView.tableHeaderView!.frame.size.height
        self.tableView.contentOffset.y -= (offset <= headerHeight * -1) ? refreshHeight : refreshHeight + headerHeight
        
        self.refreshControl!.beginRefreshing()
        self.refreshControl!.sendActions(for: UIControlEvents.valueChanged)
    }

    @IBAction func refresh(_ sender: UIRefreshControl) {
        DispatchQueue.main.async {
            self.currentPage = 1
            self.fetchOrganizations()
        }
    }
}

extension AppsViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (items.count > 1 && indexPath.row == items.count-1 && currentPage < totalPages) {
            currentPage += 1
            self.tableView.tableFooterView = LoadingIndicatorView()
            fetchApplications()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: CellIdentifier) as! AppTableViewCell
        let app = self.items[indexPath.row]
        cell.render(app, dataStack: self.dataStack!)
        
        return cell
    }
}

extension AppsViewController {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        
        // to limit network activity, reload half a second after last key press.
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(AppsViewController.refresh as (AppsViewController) -> () -> ()), object: nil)
        self.perform(#selector(AppsViewController.refresh as (AppsViewController) -> () -> ()), with: nil, afterDelay: 1.0)
    }
}

private extension AppsViewController {
    func setRefreshTitle(_ title: String) {
        DispatchQueue.main.async {
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
        CFApi().request(CFRequest.orgs(),
            success: { (json) in
                DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                    self.handleOrgsResponse(json)
                }
            },
            error: { (statusCode) in
                print([statusCode])
            }
        )
    }
    
    func handleOrgsResponse(_ json: JSON) {
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
        DispatchQueue.main.async {
            self.orgPickerButton.isEnabled = true
            self.orgPickerButton.customView?.alpha = 1
        }
    }
    
    func disableOrgsFilter() {
        DispatchQueue.main.async {
            self.orgPickerButton.isEnabled = false
            self.orgPickerButton.customView?.alpha = 0.8
        }
    }
    
    func fetchApplications() {
        setRefreshTitle("Updating Apps")
        let urlRequest = CFRequest.apps(CFSession.org()!, currentPage, searchText)
        CFApi().request(urlRequest, success: { (json) in
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
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
        if !self.searchBar.isFirstResponder {
            tableView.setContentOffset(CGPoint(x: 0,y: -20), animated: true)
        }
    }
    
    func handleAppsResponse(_ json: JSON) {
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
    
    func fetchSpaces(_ appGuids: [String]) {
        setRefreshTitle("Updating Spaces")
        let urlRequest = CFRequest.spaces(appGuids)
        CFApi().request(urlRequest, success: { (json) in
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                self.handleSpacesResponse(json)
            }
            }, error: { (statusCode) in
                print([statusCode])
            }
        )
    }
    
    func handleSpacesResponse(_ json: JSON) {
        let resources = json["resources"].arrayObject as! [[String:AnyObject]]
        CFStore(dataStack: self.dataStack!).syncSpaces(resources, completion: { (error) in
            print("--- Spaces Synced")
            self.fetchCurrentObjects()
        })
    }
}
