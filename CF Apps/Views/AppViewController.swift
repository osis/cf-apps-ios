import Foundation
import UIKit
import SafariServices
import CFoundry

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
    @IBOutlet var startStopButton: UIBarButtonItem!
    @IBOutlet var toolbar: UIToolbar!
    
    let stopButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.pause, target: self, action: #selector(stop))
    let startButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.play, target: self, action: #selector(start))
    
    var app: CFApp!
    var refreshControl: UIRefreshControl!
    var url: URL?
    var startStopIndex: Int?
    
    override func viewDidLoad() {
        self.browseButton.isEnabled = false
        
        setStopStartButton()
        addRefreshControl()
        loadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "logs") {
            let controller = segue.destination as! LogsViewController
            controller.appGuid = self.app.guid
        } else if (segue.identifier == "events") {
            let controller = segue.destination as! EventsViewController
            controller.appGuid = self.app.guid
        }
    }
    
    func setStopStartButton() {
        self.startStopIndex = (self.toolbar.items?.index(of: startStopButton))!
        if (app.state == "STARTED") {
            self.toolbar.items![self.startStopIndex!] = self.stopButton
        } else {
            self.toolbar.items![self.startStopIndex!] = self.startButton
        }
    }
    
    @objc func loadData() {
        fetchSummary()
        fetchStats()
    }
    
    func hideInstancesTable() {
        self.instancesTableView.isHidden = true
        self.instancesTableHeightConstraint.constant = 0
    }
    
    func fetchSummary() {
        servicesTableView.tableFooterView = LoadingIndicatorView()
        CFApi.appSummary(appGuid: app.guid) { appSummary, error in
            if let e = error {
                print(e.localizedDescription)
            }
            
            if let summary = appSummary {
                self.handleSummaryResponse(summary)
            }
        }
    }
    
    func addRefreshControl() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Refresh Summary")
        self.refreshControl.addTarget(self, action: #selector(AppViewController.loadData), for: UIControlEvents.valueChanged)
        self.scrollView.insertSubview(self.refreshControl, at: 0)
    }
    
    func handleSummaryResponse(_ app: CFApp) {
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
            self.setSummary(app)
            
            let delegate = self.servicesTableView.delegate as! ServicesViewController
            delegate.serviceBindings = app.serviceBindings
            
            self.servicesTableView.tableFooterView = nil
            self.servicesTableView.reloadData()
            let height = self.servicesTableView.contentSize.height
            self.servicesTableHeightConstraint.constant = height
            
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
    }
    
    func fetchStats() {
        if (app.statusImageName() == "started") {
            requestStats()
        } else {
            hideInstancesTable()
        }
    }
    
    func requestStats() {
        instancesTableView.tableFooterView = LoadingIndicatorView()
        
        CFApi.appStats(appGuid: app.guid) { stats, error in
            if let e = error {
                print(e.localizedDescription)
            }
            
            if let stats = stats {
                self.handleStatsResponse(stats)
            }
        }
    }
    
    func handleStatsResponse(_ stats: CFAppStats) {
        showInstances(stats.instances)
        toggleBrowsing(stats.instances)
    }
    
    func showInstances(_ instances: [CFAppInstance]) {
        let delegate = instancesTableView.delegate as! InstancesViewConroller
        delegate.instances = instances
        DispatchQueue.main.async(execute: {
            self.instancesTableView.tableFooterView = nil
            self.instancesTableView.reloadData()
            let height = self.instancesTableView.contentSize.height
            self.instancesTableHeightConstraint.constant = height
            
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        })
    }
    
    func toggleBrowsing(_ instances: [CFAppInstance]) {
        if instances.count > 0 && instances[0].uris!.count > 0 {
            let uri = instances[0].uris![0]
            DispatchQueue.main.async {
                self.url = URL(string: "http://\(uri)")
                self.browseButton.isEnabled = true
                self.browseButton.customView?.alpha = 1
            }
        } else {
            self.browseButton.isEnabled = false
        }
    }
    
    func setSummary(_ app: CFApp) {
        nameLabel.text = app.name
        stateLabel.text = app.state
        buildpackLabel.text = app.activeBuildpack()
        memoryLabel.text = app.formattedMemory()
        diskLabel.text = app.formattedDiskQuota()
        commandLabel.text = app.command
    }
    
    @objc func start() {
        print("Starting App...")
        requestStart(app: app)
    }
    
    func requestStart(app: CFApp) {
        CFApi.appStart(appGuid: app.guid) { app, error in
            if let error = error {
                self.handleStartError(error)
            }
            
            if let app = app {
                self.handleStartSuccess(app)
            }
        }
    }
    
    func handleStartError(_ error: Error) {
        showError(title: "Error Starting App", error: error)
    }
    
    func handleStopError(_ error: Error) {
        showError(title: "Error Stopping App", error: error)
    }
    
    func showError(title: String, error: Error) {
        Alert.show(self, title: title, message: error.localizedDescription)
    }
    
    func handleStartSuccess(_ app: CFApp) {
        self.app = app
        self.handleSummaryResponse(app)
        
        self.toolbar.items![self.startStopIndex!] = self.stopButton
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let logsController = storyboard.instantiateViewController(withIdentifier: "LogsView") as! LogsViewController
        logsController.appGuid = app.guid
        logsController.skipRecent = true
        self.navigationController?.pushViewController(logsController, animated: true)
    }
    
    @objc func stop() {
        print("Stopping...")
        requestStop(app)
    }
    
    func requestStop(_ app: CFApp) {
        CFApi.appStop(appGuid: app.guid) { app, error in
            if let error = error {
                self.handleStopError(error)
            }
            if let app = app {
                self.handleStopSuccess(app)
            }
        }
    }
    
    func handleStopSuccess(_ app: CFApp) {
        self.toolbar.items![self.startStopIndex!] = self.startButton
        self.app = app
        self.handleSummaryResponse(app)
    }
    
    @IBAction func browseButtonPushed(_ sender: UIBarButtonItem) {
        let safariController = SFSafariViewController(url: self.url!)
        present(safariController, animated: true, completion: nil)
    }
}
