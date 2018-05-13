import Foundation
import UIKit
import SwiftyJSON
import CFoundry

class ServicesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var serviceBindings: [CFServiceBinding]?
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Services"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sbs = serviceBindings {
            return (sbs.isEmpty) ? 1 : sbs.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: nil)

        if let sbs = serviceBindings, sbs.isEmpty {
            cell.textLabel?.text = "None"
        } else {
            let sb = serviceBindings![indexPath.row]
            
            cell.textLabel?.text = sb.name
            cell.detailTextLabel?.text = sb.planName
        }
        
        return cell
    }
}
