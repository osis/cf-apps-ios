import Foundation
import UIKit

class AccountsViewController: UITableViewController {
    var accounts = [CFAccount]()
    var vendors: NSArray {
        let list = NSBundle.mainBundle().pathForResource("Vendors", ofType: "plist")!
        return NSArray(contentsOfFile: list)!
    }
    
    override func viewDidLoad() {
        accounts = CFAccountStore.list()
    }
    
    @IBAction func closeClicked(sender: AnyObject) {
        dismiss()
    }
    
    private func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let account = accounts[indexPath.row]
        CFSession.account(account)
        
        dismiss()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("accountCell")
        let account = accounts[indexPath.row]
        
        let nameLabel = cell?.viewWithTag(1) as! UILabel
        nameLabel.text = vendorName(account.target)
        
        if CFSession.isCurrent(account) {
            nameLabel.textColor = UIColor.redColor()
        }
        
        let userLabel = cell?.viewWithTag(2) as! UILabel
        userLabel.text = account.username
        
        let targetLabel = cell?.viewWithTag(3) as! UILabel
        targetLabel.text = account.target
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let action = UITableViewRowAction(style: .Normal, title: "Delete", handler: self.deleteRow)
        action.backgroundColor = UIColor.redColor()
        
        return [action]
    }
    
    private func deleteRow(action: UITableViewRowAction, indexPath: NSIndexPath) {
        let account = accounts[indexPath.row]
        do {
            try CFAccountStore.delete(account)
        } catch let e {
            debugPrint("Account Delete Error - \(e)")
        }
        
        accounts = CFAccountStore.list()
        self.tableView.reloadData()
    }
    
    private func vendorName(target: String) -> String {
        let vendor = vendors.filter { v in
            if let t = v.valueForKey("Target") as? String {
                return t == target
            }
            return false
        }
        if vendor.count > 0 {
            return vendor[0].valueForKey("Name") as! String
        }
        return "Custom"
    }
}