import Foundation
import UIKit
import QuartzCore
import SafariServices
import CFoundry

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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setup()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if authError {
            Alert.showAuthFail(self)
        }
    }
    
    func setup() {
        vendorPicker.vendorPickerDelegate = self
        vendorPicker.pickerView(vendorPicker, didSelectRow: vendorPicker.selectedRow(inComponent: 0), inComponent: 0)
        showTargetForm()
        hideLoginForm()
        hideTargetField()
    }
    
    func showLoginForm() {
        UIView.animate(withDuration: transitionSpeed, animations: {
            self.loginView.alpha = 1
            self.loginView.transform = CGAffineTransform.identity
            self.usernameField.becomeFirstResponder()
        })
    }
    
    func hideLoginForm() {
        loginView.alpha = 0
        loginView.transform = CGAffineTransform(translationX: 0, y: 50)
        usernameField.text = ""
        passwordField.text = ""
    }
    
    func showTargetField() {
        UIView.animate(withDuration: transitionSpeed, animations: {
            self.apiTargetField.alpha = 1
            self.apiTargetField.becomeFirstResponder()
        })
    }
    
    func hideTargetField() {
        apiTargetField.alpha = 0
    }

    func vendorPickerView(didSelectVendor targetURL: String, signupURL: String) {
        if signupURL != "" {
            apiTargetField.isEnabled = false
            apiTargetField.textColor = UIColor.lightGray
            apiTargetField.text = targetURL
            hideTargetField()
        } else {
            let urlString = "https://"
            apiTargetField.isEnabled = true
            apiTargetField.textColor = UIColor.darkGray
            apiTargetField.text = urlString
            showTargetField()
        }
    }
    
    func showTargetForm() {
        UIView.animate(withDuration: transitionSpeed, animations: {
            self.apiTargetView.alpha = 1
            self.apiTargetView.transform = CGAffineTransform(translationX: 0, y: 0)
        })
    }
    
    func hideTargetForm() {
        UIView.animate(withDuration: transitionSpeed, animations: {
            self.apiTargetView.alpha = 0
            self.apiTargetView.transform = CGAffineTransform(translationX: 0, y: -50)
        })
    }
    
    func startButtonSpinner(_ button: UIButton, spinner: UIActivityIndicatorView) {
        spinner.startAnimating()
        button.alpha = 0
    }
    
    func stopButtonSpinner(_ button: UIButton, spinner: UIActivityIndicatorView) {
        spinner.stopAnimating()
        button.alpha = 1
    }
    
    func target() {
        let urlString = self.apiTargetField.text!
        
        if (urlString.isValidURL()) {
            // TODO: Refactor
            startButtonSpinner(targetButton, spinner: apiTargetSpinner)
            CFApi.info(apiURL: urlString) { (info: CFInfo?, error: Error?) in
                self.stopButtonSpinner(self.targetButton, spinner: self.apiTargetSpinner)
                
                if let e = error {
                    Alert.show(self, title: "Error", message: "\(urlString) \(e.localizedDescription)")
                    return
                }
                
                if let i = info {
                    self.apiInfo = i
                    self.hideTargetForm()
                    self.showLoginForm()
                }
            }
        } else {
            Alert.show(self, title: "Invalid URL", message: "The URL you've entered seems to be invalid. Please check and try again.")
        }
    }
    
    func login() {
        self.startButtonSpinner(self.loginButton, spinner: self.loginSpinner)
        
        let account = CFAccount(
            target: self.apiTargetField.text!,
            username: self.usernameField.text!,
            password: self.passwordField.text!,
            info: self.apiInfo!
        )
        CFApi.login(account: account) { (error: Error?) in
            self.stopButtonSpinner(self.loginButton, spinner: self.loginSpinner)
            
            if let e = error {
                Alert.show(self, title: "Error", message: e.localizedDescription)
                return
            }
            
            do {
                try AccountStore.create(account)
                
                if let navController = self.navigationController {
                    navController.dismiss(animated: true, completion: nil)
                } else {
                    self.performSegue(withIdentifier: "apps", sender: nil)
                }
            } catch {
                Alert.show(self, title: "Error", message: "Could not save account.")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "apps") {
            let navController = segue.destination as! UINavigationController
            let appsViewController = navController.topViewController as! AppsViewController
            let delegate = UIApplication.shared.delegate as! AppDelegate
            
            self.hidesBottomBarWhenPushed = false;
        }
    }
    
    @IBAction func usernameNextPressed(_ sender: AnyObject) {
        passwordField.becomeFirstResponder()
    }
    
    @IBAction func cancelPushed(_ sender: AnyObject) {
        setup()
    }
    
    @IBAction func loginPushed(_ sender: UIButton) {
        login()
    }
    
    @IBAction func keyboardLoginAction(_ sender: AnyObject) {
        login()
    }
    
    @IBAction func targetPushed(_ sender: AnyObject) {
        target()
    }
    
    @IBAction func keyboardTargetAction(_ sender: AnyObject) {
        target()
    }
}
