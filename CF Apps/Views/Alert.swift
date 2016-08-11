import Foundation
import UIKit

class Alert {
    class func showAuthFail(controller: UIViewController) {
        show(controller, title: "Authentication Failed", message: "There was an error authenticating. Please try again.")
    }
    
    class func show(controller: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in }
        alert.addAction(alertAction)
        controller.presentViewController(alert, animated: true) { () -> Void in }
    }
}