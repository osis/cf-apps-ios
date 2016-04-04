//
//  ViewController.swift
//  CF Commander
//
//  Created by Dwayne Forde on 2015-06-11.
//  Copyright (c) 2015 Dwayne Forde. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import QuartzCore
import SwiftyJSON

class LoginViewController: UIViewController, EndpointPickerDelegate {
    @IBOutlet var loginView: UIView!
    @IBOutlet var apiTargetView: UIView!
    @IBOutlet var usernameField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet weak var apiTargetField: UITextField!
    @IBOutlet var apiTargetSpinner: UIActivityIndicatorView!
    @IBOutlet var loginSpinner: UIActivityIndicatorView!
    

    @IBOutlet var loginButton: UIButton!
    @IBOutlet var endpointPicker: EndpointPicker!
    @IBOutlet weak var targetButton: UIButton!
    
    var authError = false
    var authEndpoint: String?
    var loggingEndpoint: String?
    var pickerData: [String] = [String]()
    let transitionSpeed = 0.5
    
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
        CFSession.reset()
        endpointPicker.endpointPickerDelegate = self
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

    func endpointPickerView(didSelectURL url: String?) {
        if let targetURL = url {
            apiTargetField.enabled = false
            apiTargetField.textColor = UIColor.lightGrayColor()
            apiTargetField.text = targetURL
            hideTargetField()
        } else {
            apiTargetField.enabled = true
            apiTargetField.textColor = UIColor.darkGrayColor()
            apiTargetField.text = "https://"
            showTargetField()
        }
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
        let urlRequest = CFRequest.Info(self.apiTargetField.text!)
        CFApi().request(urlRequest, success: { (json) in
            self.authEndpoint = json["authorization_endpoint"].string
            self.loggingEndpoint = json["logging_endpoint"].string
            self.hideTargetForm()
            self.showLoginForm()
            self.stopButtonSpinner(self.targetButton, spinner: self.apiTargetSpinner)
        }, error: { statusCode, url in
            self.showAlert("Error", message: CFResponse.stringForLoginStatusCode(statusCode, url: url))
            self.stopButtonSpinner(self.targetButton, spinner: self.apiTargetSpinner)
        })
    }
    
    func login() {
        self.startButtonSpinner(self.loginButton, spinner: self.loginSpinner)
        let urlRequest = CFRequest.Login(self.authEndpoint!, usernameField.text!, passwordField.text!)
        CFApi().request(urlRequest, success: { json in
            CFSession.save(self.apiTargetField.text!, authURL: self.authEndpoint!, loggingURL: self.loggingEndpoint!, username: self.usernameField.text!, password: self.passwordField.text!)
            self.performSegueWithIdentifier("loginSegue", sender: nil)
            self.stopButtonSpinner(self.loginButton, spinner: self.loginSpinner)
        }, error: { statusCode, url in
            self.showAlert("Error", message: CFResponse.stringForLoginStatusCode(statusCode, url: url))
            self.stopButtonSpinner(self.loginButton, spinner: self.loginSpinner)
        })
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
}