import Foundation
import UIKit

class Alert {
    class func showAuthFail(_ controller: UIViewController) {
        show(controller, title: "Authentication Failed", message: "There was an error authenticating. Please try again.")
    }
    
    class func show(_ controller: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (UIAlertAction) -> Void in }
        alert.addAction(alertAction)
        controller.present(alert, animated: true) { () -> Void in }
    }
}
