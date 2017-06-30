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
        self.refreshControl!.sendActions(for: UIControlEvents.valueChanged)
        fetchEvents()
    }
    
    func fetchEvents() {
        setRefreshTitle("Fetching Events")
        
        let request = CFRequest.events(self.appGuid!)
        CFApi().request(request, success: { (json) in
            self.handleEventsRequest(json)
        }, error: { (statusCode, url) in
            if let s = statusCode, let u = url {
                print("Network Error. Status: %s, URL: %s", s, u)
            } else {
                print("Unknown Network Error")
            }
        })
    }
    
    func handleEventsRequest(_ json: JSON) {
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
    
    @IBAction func refresh(_ sender: AnyObject) {
        fetchEvents()
    }
    
    func setRefreshTitle(_ title: String) {
        DispatchQueue.main.async {
            self.refreshControl!.attributedTitle = NSAttributedString(string: title)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    func operationalEventCell(_ event: CFEvent) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "OperationEventCell")
        
        let dateLabel = cell!.viewWithTag(1) as! UILabel
        dateLabel.text = event.date()
        
        let stateLabel = cell!.viewWithTag(2) as! UILabel
        stateLabel.text = event.state()
        
        let stateImg = cell!.viewWithTag(3) as! UIImageView
        stateImg.image = UIImage(named: event.state()!.localizedLowercase)
        
        return cell!
    }
    
    func attributeEventCell(_ event: CFEvent) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "AttributeEventCell")
        
        let dateLabel = cell!.viewWithTag(1) as! UILabel
        dateLabel.text = event.date()
        
        let descriptionLabel = cell?.viewWithTag(2) as! UILabel
        descriptionLabel.text = event.attributeSummary()
        
        return cell!
    }
    
    func crashEventCell(_ event: CFEvent) ->  UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "CrashEventCell")
        
        let dateLabel = cell!.viewWithTag(1) as! UILabel
        dateLabel.text = event.date()
        
        let reasonLabel = cell!.viewWithTag(2) as! UILabel
        reasonLabel.text = event.reason()
        
        let descriptionLabel = cell!.viewWithTag(3) as! UILabel
        descriptionLabel.text = event.exitDesciption()
        
        return cell!
    }
}
