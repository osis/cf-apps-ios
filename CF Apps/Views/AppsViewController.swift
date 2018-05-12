import UIKit
import Foundation
import ActionSheetPicker_3_0
import CFoundry

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
    
    var token:String?
    var apps = [CFApp]()
    var orgs = [CFOrg]()
    var spaces = [CFSpace]()
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
        refresh()
        disableOrgsFilter()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "app":
            let controller = segue.destination as! AppViewController
            let cell = sender as! UITableViewCell
            let index = self.tableView.indexPath(for: cell)
            
            controller.app = apps[index!.item]
            self.searchBar.resignFirstResponder()
        default:
            break
        }
    }
    
    @IBAction func filterOrgClicked(_ sender: UIBarButtonItem) {
        // TODO: Initial selection should be from session
//        let currentIndex = self.orgPickerValues.index(of: CFSession.org()!)
        let currentIndex = 0
        
        ActionSheetMultipleStringPicker.show(withTitle: "Filter by Org", rows: [
            self.orgPickerLabels
            ], initialSelection: [currentIndex], doneBlock: {
                picker, values, indexes in
                
                let value = values?[0] as! Int
                // TODO: Save org to session
//                CFSession.org(self.orgPickerValues[value])
                self.refresh()
                
                return
            }, cancel: { ActionMultipleStringCancelBlock in return }, origin: sender)
        
        clearSearch()
    }
    
    func refresh() {
        self.clearList()
        
        let offset = self.tableView.contentOffset.y
        let refreshHeight = self.refreshControl!.frame.size.height
        let headerHeight = self.tableView.tableHeaderView!.frame.size.height
        self.tableView.contentOffset.y -= (offset <= headerHeight * -1) ? refreshHeight : refreshHeight + headerHeight
        
        self.refreshControl!.beginRefreshing()
        self.refreshControl!.sendActions(for: UIControlEvents.valueChanged)
    }

    @IBAction func refresh(_ sender: UIRefreshControl) {
        DispatchQueue.main.async {
            self.refresh()
            self.currentPage = 1
            self.fetchOrganizations()
        }
    }
}

extension AppsViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(apps.count)
        return apps.count
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (apps.count > 1 && indexPath.row == apps.count-1 && currentPage < totalPages) {
            print("Grabbing another page...")
            currentPage += 1
            self.tableView.tableFooterView = LoadingIndicatorView()
            fetchApplications()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: CellIdentifier) as! AppTableViewCell
        let app = self.apps[indexPath.row]
        let spaceIndex = self.spaces.index { (s) -> Bool in
            return app.spaceGuid == s.guid
        }
        
        let space = self.spaces[spaceIndex!]
        
        cell.render(app: app, space: space)
        
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
    
    func clearList() {
        self.apps = [CFApp]()
        self.tableView.reloadData()
    }
    
    func fetchOrganizations() {
        setRefreshTitle("Updating Organizations")
        CFApi.orgs() { orgs, error in
            if let e = error {
                print(e.localizedDescription)
                return
            }
            
            if let orgs = orgs {
                DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                    self.handleOrgsResponse(orgs)
                }
            }
        }
    }
    
    func handleOrgsResponse(_ orgs: [CFOrg]) {
        self.orgPickerLabels = []
        self.orgPickerValues = []
        var orgGuids: [String] = []
        
        for org in orgs {
            self.orgPickerValues.append(org.guid)
            self.orgPickerLabels.append(org.name)
            orgGuids.append(org.guid)
        }
        
        self.enableOrgsFilter()
        
        // TODO: Select the org from the previous session
//        if CFSession.org() == nil || !orgGuids.contains(CFSession.org()!) {
//            CFSession.org(orgGuids[0])
//        }
        
        self.orgs = orgs
        
        print("--- Orgs Synced")
        self.fetchApplications()
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
        
        CFApi.apps(orgGuid: orgPickerValues.first!, page: currentPage, searchText: searchText) { apps, error in
            if let e = error {
                print(e.localizedDescription)
            }
            
            if let apps = apps {
                DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                    self.handleAppsResponse(apps)
                }
            }
        }
    }
    
    func fetchCurrentObjects() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            
            self.refreshControl!.endRefreshing()
            self.setRefreshTitle("Refresh Apps")
            self.tableView.tableFooterView = nil
        }
    }
    
    func handleAppsResponse(_ apps: [CFApp]) {
        var appGuids: [String] = []
        
        for app in apps {
            appGuids.append(app.guid)
        }
        
//        self.totalPages = json["total_pages"].intValue
        self.totalPages = 1
        
//        let resources = json["resources"].arrayObject as! [[String:AnyObject]]
        self.apps += apps
//        let clear = currentPage == 1
        print("--- Apps Synced")
        self.fetchSpaces(appGuids)
    }
    
    func fetchSpaces(_ appGuids: [String]) {
        setRefreshTitle("Updating Spaces")
        CFApi.appSpaces(appGuids: appGuids) { spaces, error in
            if let error = error {
                print(error.localizedDescription)
            }
            
            if let spaces = spaces {
                DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                    self.handleSpacesResponse(spaces)
                }
            }
        }
//        let urlRequest = CFRequest.spaces(appGuids)
//        CFApi().request(urlRequest, success: { (json) in
//
//            }, error: { (statusCode) in
//                print([statusCode])
//            }
//        )
    }
    
    func handleSpacesResponse(_ spaces: [CFSpace]) {
        self.spaces += spaces
        print("--- Spaces Synced")
        self.fetchCurrentObjects()
    }
}
