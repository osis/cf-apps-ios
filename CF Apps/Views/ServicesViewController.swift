import Foundation
import UIKit
import SwiftyJSON
import CFoundry

class ServicesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var serviceBindings: [CFServiceBinding]?
    
    func isLoaded() -> Bool {
        return serviceBindings != nil
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Services"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (isLoaded()) {
            return (serviceBindings!.isEmpty) ? 1 : serviceBindings!.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: nil)

        let sb = serviceBindings![indexPath.row]
        
        cell.textLabel?.text = sb.name
        cell.detailTextLabel?.text = sb.planName
        
        return cell
    }
}
