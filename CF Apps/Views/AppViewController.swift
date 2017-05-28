import Foundation
import UIKit
import Alamofire
import DATAStack
import Sync
import SwiftyJSON
import SafariServices

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
    @IBOutlet var browseButton: UIBarButtonItem!
    
    
    var dataStack: DATAStack?
    var app: CFApp?
    var refreshControl: UIRefreshControl!
    var url: URL?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func viewDidLoad() {
        self.browseButton.isEnabled = false
        addRefreshControl()
        loadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "logs") {
            let controller = segue.destination as! LogsViewController
            controller.appGuid = self.app!.guid
        } else if (segue.identifier == "events") {
            let controller = segue.destination as! EventsViewController
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
        self.instancesTableView.isHidden = true
        self.instancesTableHeightConstraint.constant = 0
    }
    
    func fetchSummary() {
        servicesTableView.tableFooterView = LoadingIndicatorView()
        let urlRequest = CFRequest.appSummary(app!.guid)
        CFApi().request(urlRequest,
            success: { (json) in
                DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                    self.handleSummaryResponse(json)
                    self.refreshControl.endRefreshing()
                }
            },
            error: { (statusCode) in
                print([statusCode])
        })
    }
    
    func addRefreshControl() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Refresh Summary")
        self.refreshControl.addTarget(self, action: #selector(AppViewController.loadData), for: UIControlEvents.valueChanged)
        self.scrollView.insertSubview(self.refreshControl, at: 0)
    }
    
    func handleSummaryResponse(_ json: JSON) {
        let delegate = servicesTableView.delegate as! ServicesViewController
        delegate.services = json["services"]
        
        CFStore(dataStack: self.dataStack!).syncApp(json.dictionaryObject! as [String : AnyObject], guid: self.app!.guid, completion: { (error) in
            self.setSummary(self.app!.guid)
        })
        
        DispatchQueue.main.async(execute: {
            self.servicesTableView.tableFooterView = nil
            self.servicesTableView.reloadData()
            let height = self.servicesTableView.contentSize.height
            self.servicesTableHeightConstraint.constant = height
            
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        })
    }
    
    func fetchStats() {
        instancesTableView.tableFooterView = LoadingIndicatorView()
        
        let urlRequest = CFRequest.appStats(app!.guid)
        CFApi().request(urlRequest,
            success: { (json) in
                DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                    self.handleStatsResponse(json)
                }
            },
            error: { (statusCode) in
                print([statusCode])
        })
    }
    
    func handleStatsResponse(_ json: JSON) {
        showInstances(json)
        toggleBrowsing(json)
    }
    
    func showInstances(_ json: JSON) {
        let delegate = instancesTableView.delegate as! InstancesViewConroller
        delegate.instances = json
        DispatchQueue.main.async(execute: {
            self.instancesTableView.tableFooterView = nil
            self.instancesTableView.reloadData()
            let height = self.instancesTableView.contentSize.height
            self.instancesTableHeightConstraint.constant = height
            
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        })
    }
    
    func toggleBrowsing(_ json: JSON) {
        if let urlString = Instance(json: json["0"]).uri() {
            DispatchQueue.main.async {
                self.url = URL(string: urlString)
                self.browseButton.isEnabled = true
                self.browseButton.customView?.alpha = 1
            }
        } else {
            self.browseButton.isEnabled = false
        }
    }
    
    func setSummary(_ guid: String) {
        do {
            self.app = try CFStore(dataStack: self.dataStack!).fetchApp(app!.guid)
            let state = app!.state
            
            nameLabel.text = app!.name
            stateLabel.text = state
            buildpackLabel.text = app!.activeBuildpack()
            memoryLabel.text = app!.formattedMemory()
            diskLabel.text = app!.formattedDiskQuota()
            commandLabel.text = app!.command
        } catch {
            self.app = nil
            nameLabel.text = "Error"
        }
    }
    
    @IBAction func browseButtonPushed(_ sender: UIBarButtonItem) {
        let safariController = SFSafariViewController(url: self.url!)
        present(safariController, animated: true, completion: nil)
    }
}
