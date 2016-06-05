import Foundation
import UIKit
import SwiftyJSON

class EventsViewController: UITableViewController {
    var appGuid: String?
    var events = [CFEvent]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.contentOffset.y -= self.refreshControl!.frame.size.height
        self.refreshControl!.beginRefreshing()
        self.refreshControl!.sendActionsForControlEvents(UIControlEvents.ValueChanged)
        fetchEvents()
    }
    
    func fetchEvents() {
        setRefreshTitle("Fetching Events")
        
        let request = CFRequest.Events(self.appGuid!)
        CFApi().request(request, success: { (json) in
            self.handleEventsRequest(json)
        }, error: { (statusCode, url) in
            print("Network Error")
            print(statusCode)
            print(url)
        })
    }
    
    func handleEventsRequest(json: JSON) {
        for e in json["resources"].arrayValue {
            let event = CFEvent(json: e)
            if let _ = event.type() {
                events.append(event)
            }
        }
        
        self.refreshControl!.endRefreshing()
        tableView.reloadData()
        setRefreshTitle("Refresh Events")
    }
    
    @IBAction func refresh(sender: AnyObject) {
        fetchEvents()
    }
    
    func setRefreshTitle(title: String) {
        dispatch_async(dispatch_get_main_queue()) {
            self.refreshControl!.attributedTitle = NSAttributedString(string: title)
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let event = events[indexPath.item]
        
        if let type = event.type() {
            switch type {
            case "operation":
                return operationalEventCell(event)
            case "update":
                return attributeEventCell(event)
            default:
                return crashEventCell(event)
            }
        }
        
        return event.isOperationalEvent() ? operationalEventCell(event) : attributeEventCell(event)
    }
    
    func operationalEventCell(event: CFEvent) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("OperationEventCell")
        
        let dateLabel = cell!.viewWithTag(1) as! UILabel
        dateLabel.text = event.date()
        
        let stateLabel = cell!.viewWithTag(2) as! UILabel
        stateLabel.text = event.state()
        
        let stateImg = cell!.viewWithTag(3) as! UIImageView
        stateImg.image = UIImage(named: event.state()!.localizedLowercaseString)
        
        return cell!
    }
    
    func attributeEventCell(event: CFEvent) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("AttributeEventCell")
        
        let dateLabel = cell!.viewWithTag(1) as! UILabel
        dateLabel.text = event.date()
        
        let descriptionLabel = cell?.viewWithTag(2) as! UILabel
        descriptionLabel.text = event.attributeSummary()
        
        return cell!
    }
    
    func crashEventCell(event: CFEvent) ->  UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("CrashEventCell")
        
        let dateLabel = cell!.viewWithTag(1) as! UILabel
        dateLabel.text = event.date()
        
        let reasonLabel = cell!.viewWithTag(2) as! UILabel
        reasonLabel.text = event.reason()
        
        let descriptionLabel = cell!.viewWithTag(3) as! UILabel
        descriptionLabel.text = event.exitDesciption()
        
        return cell!
    }
}