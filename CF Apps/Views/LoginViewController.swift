import Foundation
import UIKit
import Alamofire
import QuartzCore
import SwiftyJSON
import SafariServices

class LoginViewController: UIViewController, VendorPickerDelegate {
    @IBOutlet var loginView: UIView!
    @IBOutlet var apiTargetView: UIView!
    @IBOutlet var usernameField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet weak var apiTargetField: UITextField!
    @IBOutlet var apiTargetSpinner: UIActivityIndicatorView!
    @IBOutlet var loginSpinner: UIActivityIndicatorView!
    

    @IBOutlet var loginButton: UIButton!
    @IBOutlet var signupButton: UIButton!
    @IBOutlet var vendorPicker: VendorPicker!
    @IBOutlet weak var targetButton: UIButton!
    
    var authError = false
    var apiInfo: CFInfo?
    var signupURL: NSURL?
    let transitionSpeed = 0.5
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setup()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear(animated: Bool) {
        if authError {
            showAuthAlert()
        }
    }
    
    func setup() {
        vendorPicker.vendorPickerDelegate = self
        vendorPicker.pickerView(vendorPicker, didSelectRow: vendorPicker.selectedRowInComponent(0), inComponent: 0)
        showTargetForm()
        hideLoginForm()
        hideTargetField()
    }
    
    func showLoginForm() {
        UIView.animateWithDuration(transitionSpeed, animations: {
            self.loginView.alpha = 1
            self.loginView.transform = CGAffineTransformIdentity
            self.usernameField.becomeFirstResponder()
        })
    }
    
    func hideLoginForm() {
        loginView.alpha = 0
        loginView.transform = CGAffineTransformMakeTranslation(0, 50)
        usernameField.text = ""
        passwordField.text = ""
    }
    
    func showTargetField() {
        UIView.animateWithDuration(transitionSpeed, animations: {
            self.apiTargetField.alpha = 1
            self.apiTargetField.becomeFirstResponder()
        })
    }
    
    func hideTargetField() {
        apiTargetField.alpha = 0
    }

    func vendorPickerView(didSelectVendor targetURL: String?, signupURL: String?) {
        if let targetURL = targetURL {
            apiTargetField.enabled = false
            apiTargetField.textColor = UIColor.lightGrayColor()
            apiTargetField.text = targetURL
            signupButton.enabled = true
            self.signupURL = NSURL(string: signupURL!)
            hideTargetField()
        } else {
            let urlString = "https://"
            apiTargetField.enabled = true
            apiTargetField.textColor = UIColor.darkGrayColor()
            apiTargetField.text = urlString
            signupButton.enabled = false
            self.signupURL = nil
            showTargetField()
        }
    }
    
    func showTargetForm() {
        UIView.animateWithDuration(transitionSpeed, animations: {
            self.apiTargetView.alpha = 1
            self.apiTargetView.transform = CGAffineTransformMakeTranslation(0, 0)
        })
    }
    
    func hideTargetForm() {
        UIView.animateWithDuration(transitionSpeed, animations: {
            self.apiTargetView.alpha = 0
            self.apiTargetView.transform = CGAffineTransformMakeTranslation(0, -50)
        })
    }
    
    func startButtonSpinner(button: UIButton, spinner: UIActivityIndicatorView) {
        spinner.startAnimating()
        button.alpha = 0
    }
    
    func stopButtonSpinner(button: UIButton, spinner: UIActivityIndicatorView) {
        spinner.stopAnimating()
        button.alpha = 1
    }
    
    func showAuthAlert() {
        showAlert("Authentication Failed", message: "There was an error authenticating. Please try again.")
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in }
        alert.addAction(alertAction)
        presentViewController(alert, animated: true) { () -> Void in }
    }
    
    func target() {
        startButtonSpinner(targetButton, spinner: apiTargetSpinner)
        startButtonSpinner(signupButton, spinner: loginSpinner)
        let urlRequest = CFRequest.Info(self.apiTargetField.text!)
        CFApi().request(urlRequest, success: { (json) in
            self.apiInfo = CFInfo( json: json)
            self.hideTargetForm()
            self.showLoginForm()
            self.stopButtonSpinner(self.targetButton, spinner: self.apiTargetSpinner)
            self.stopButtonSpinner(self.signupButton, spinner: self.loginSpinner)
        }, error: { statusCode, url in
            self.showAlert("Error", message: CFResponse.stringForLoginStatusCode(statusCode, url: url))
            self.stopButtonSpinner(self.targetButton, spinner: self.apiTargetSpinner)
            self.stopButtonSpinner(self.signupButton, spinner: self.loginSpinner)
        })
    }
    
    func login() {
        self.startButtonSpinner(self.loginButton, spinner: self.loginSpinner)
        
        let urlRequest = CFRequest.Login(apiInfo!.authEndpoint, usernameField.text!, passwordField.text!)
        CFApi().request(urlRequest, success: { json in
            let account = CFAccount(
                target: self.apiTargetField.text!,
                username: self.usernameField.text!,
                password: self.passwordField.text!,
                info: self.apiInfo!
            )
            
            do {
                try CFAccountStore.create(account)
                CFSession.account(account)
                
                self.performSegueWithIdentifier("apps", sender: nil)
                self.stopButtonSpinner(self.loginButton, spinner: self.loginSpinner)
            } catch {
                self.showAlert("Error", message: "Could not save account.")
                self.stopButtonSpinner(self.loginButton, spinner: self.loginSpinner)
            }
        }, error: { statusCode, url in
            self.showAlert("Error", message: CFResponse.stringForLoginStatusCode(statusCode, url: url))
            self.stopButtonSpinner(self.loginButton, spinner: self.loginSpinner)
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "apps") {
            let navController = segue.destinationViewController as! UINavigationController
            let appsViewController = navController.topViewController as! AppsViewController
            let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            appsViewController.dataStack = delegate.dataStack
            self.hidesBottomBarWhenPushed = false;
        }
    }
    
    @IBAction func usernameNextPressed(sender: AnyObject) {
        passwordField.becomeFirstResponder()
    }
    
    @IBAction func loginPushed(sender: UIButton) {
        login()
    }
    
    @IBAction func keyboardLoginAction(sender: AnyObject) {
        login()
    }
    
    @IBAction func targetPushed(sender: AnyObject) {
        target()
    }
    
    @IBAction func keyboardTargetAction(sender: AnyObject) {
        target()
    }
    
    @IBAction func signupPushed(sender: AnyObject) {
        let safariController = SFSafariViewController(URL: self.signupURL!)
            presentViewController(safariController, animated: true, completion: nil)
    }
}