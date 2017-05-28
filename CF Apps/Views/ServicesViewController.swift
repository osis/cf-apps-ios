import Foundation
import UIKit
import SwiftyJSON

class ServicesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var services: JSON?
    
    func isLoaded() -> Bool {
        return services != nil
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Services"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (isLoaded()) {
            return (services!.isEmpty) ? 1 : services!.arrayValue.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: nil)

        let service = Service(json: services![indexPath.row])
        
        let name = (services!.isEmpty) ? "None" : service.name()
        let plan = (services!.isEmpty) ? "" : service.planName()
        
        cell.textLabel?.text = name
        cell.detailTextLabel?.text = plan
        
        return cell
    }
}
