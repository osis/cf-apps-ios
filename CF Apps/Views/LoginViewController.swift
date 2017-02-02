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
    

    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var vendorPicker: VendorPicker!
    @IBOutlet weak var targetButton: UIButton!
    
    var authError = false
    var apiInfo: CFInfo?
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
            Alert.showAuthFail(self)
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

    func vendorPickerView(didSelectVendor targetURL: String, signupURL: String) {
        if signupURL != "" {
            apiTargetField.enabled = false
            apiTargetField.textColor = UIColor.lightGrayColor()
            apiTargetField.text = targetURL
            hideTargetField()
        } else {
            let urlString = "https://"
            apiTargetField.enabled = true
            apiTargetField.textColor = UIColor.darkGrayColor()
            apiTargetField.text = urlString
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
    
    func target() {
        let urlString = self.apiTargetField.text!
        
        if (urlString.isValidURL()) {
        // TODO: Refactor
        startButtonSpinner(targetButton, spinner: apiTargetSpinner)
        let urlRequest = CFRequest.Info(self.apiTargetField.text!)
        CFApi().request(urlRequest, success: { (json) in
            self.apiInfo = CFInfo( json: json)
            self.hideTargetForm()
            self.showLoginForm()
            self.stopButtonSpinner(self.targetButton, spinner: self.apiTargetSpinner)
        }, error: { statusCode, url in
           Alert.show(self, title: "Error", message: CFResponse.stringForLoginStatusCode(statusCode, url: url))
            self.stopButtonSpinner(self.targetButton, spinner: self.apiTargetSpinner)
        })
        } else {
            Alert.show(self, title: "Invalid URL", message: "The URL you've entered seems to be invalid. Please check and try again.")
        }
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
                
                if let navController = self.navigationController {
                    navController.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    self.performSegueWithIdentifier("apps", sender: nil)
                }
                self.stopButtonSpinner(self.loginButton, spinner: self.loginSpinner)
            } catch {
                Alert.show(self, title: "Error", message: "Could not save account.")
                self.stopButtonSpinner(self.loginButton, spinner: self.loginSpinner)
            }
        }, error: { statusCode, url in
            Alert.show(self, title: "Error", message: CFResponse.stringForLoginStatusCode(statusCode, url: url))
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
    
    @IBAction func cancelPushed(sender: AnyObject) {
        setup()
    }
    
    @IBAction func loginPushed(sender: UIButton) {
        login()
    }
    
    @IBAction func keyboardLoginAction(sender: AnyObject) {
        login()
    }
    
    @IBAction func targetPushed(sender: AnyObject) {
        self.hideTargetForm()
        self.showLoginForm()
        self.stopButtonSpinner(self.targetButton, spinner: self.apiTargetSpinner)
    }
    
    @IBAction func keyboardTargetAction(sender: AnyObject) {
        target()
    }
}