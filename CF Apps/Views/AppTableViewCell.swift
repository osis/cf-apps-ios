import Foundation
import UIKit
import DATAStack

class AppTableViewCell: UITableViewCell {
    let identifier = "AppCell"
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func render(app: CFApp, dataStack: DATAStack) {
        let appNameLabel: UILabel = self.viewWithTag(1) as! UILabel
        let memLabel: UILabel = self.viewWithTag(2) as! UILabel
        let diskLabel: UILabel = self.viewWithTag(3) as! UILabel
        let stateView: UIImageView = self.viewWithTag(4) as! UIImageView
        let buildpackLabel: UILabel = self.viewWithTag(5) as! UILabel
        let spaceLabel: UILabel = self.viewWithTag(6) as! UILabel
        
        let request = NSFetchRequest(entityName: "CFSpace")
        request.predicate = NSPredicate(format: "guid == %@", app.spaceGuid)
        do {
            let spaces = try dataStack.mainContext.executeFetchRequest(request)
            if spaces.count != 0 { spaceLabel.text = spaces[0].name }
        } catch {
            spaceLabel.text = "N/A"
        }
        
        appNameLabel.text = app.name
        memLabel.text = app.formattedMemory()
        diskLabel.text = app.formattedDiskQuota()
        stateView.image = UIImage(named: app.statusImageName())
        buildpackLabel.text = app.activeBuildpack()
    }
}