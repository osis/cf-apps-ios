import Foundation
import UIKit
import SwiftyJSON

class InstancesViewConroller: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var instances: JSON?
    
    override func viewDidLoad() {
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Instances"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (instances != nil) ? instances!.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let instance = Instance(json: instances!["\(indexPath.row)"])

        let cell = tableView.dequeueReusableCell(withIdentifier: "InstanceCell") as UITableViewCell!
        
        let indexLabel = cell!.viewWithTag(1) as! UILabel
        indexLabel.text = String(indexPath.row)
        
        let cpuLabel = cell!.viewWithTag(2) as! UILabel
        cpuLabel.text = "\(instance.cpuUsagePercentage())%"
        
        let memoryLabel = cell!.viewWithTag(3) as! UILabel
        memoryLabel.text = "\(instance.memoryUsagePercentage())%"
        
        let diskLabel = cell!.viewWithTag(4) as! UILabel
        diskLabel.text = "\(instance.diskUsagePercentage())%"
        
        let stateView: UIImageView = cell!.viewWithTag(5) as! UIImageView
        stateView.image = UIImage(named: instance.state())
        
        return cell!
    }
}
