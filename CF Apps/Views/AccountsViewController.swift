import Foundation
import UIKit

class AccountsViewController: UITableViewController {
    var accounts = [CFAccount]()
    let vendors = Vendor.list
    
    override func viewDidLoad() {
        accounts = CFAccountStore.list()
        
        if CFSession.account() == nil {
            CFSession.account(accounts.first!)
            Alert.showAuthFail(self)
        }
    }
    
    @IBAction func closeClicked(sender: AnyObject) {
        dismiss()
    }
}

extension AccountsViewController {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let account = accounts[indexPath.row]
        if !CFSession.isCurrent(account) {
            CFSession.account(account)
        }
        
        dismiss()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("accountCell")
        let account = accounts[indexPath.row]
        
        let nameLabel = cell?.viewWithTag(1) as! UILabel
        nameLabel.text = vendorName(account.target)
        
        let userLabel = cell?.viewWithTag(2) as! UILabel
        userLabel.text = "User \(indexPath.row+1)"
        
        let targetLabel = cell?.viewWithTag(3) as! UILabel
        targetLabel.text = account.target
        
        if CFSession.isCurrent(account) {
            userLabel.textColor = UIColor(red: 0.27, green: 0.62, blue: 0.97, alpha: 1)
        }
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let action = UITableViewRowAction(style: .Normal, title: "Delete", handler: self.deleteRow)
        action.backgroundColor = UIColor.redColor()
        
        return [action]
    }
}

private extension AccountsViewController {
    func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func deleteRow(action: UITableViewRowAction, indexPath: NSIndexPath) {
        let deleteAccount = accounts[indexPath.row]
        let isCurrent = CFSession.isCurrent(deleteAccount)
        
        if accounts.count == 1 {
            CFSession.logout(false)
        } else {
            CFSession.reset()
            try! CFAccountStore.delete(deleteAccount)
            accounts = CFAccountStore.list()
            
            if isCurrent {
                CFSession.account(accounts.first!)
            }
        }
        
        self.tableView.reloadData()
    }
    
    func vendorName(target: String) -> String {
        let vendor = vendors.filter { v in
            let t = v.valueForKey("Target") as! String
            return t == target
        }
        if vendor.count > 0 {
            return vendor[0].valueForKey("Name") as! String
        }
        return "Other"
    }
}