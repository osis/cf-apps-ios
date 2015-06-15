//
//  ViewController.swift
//  CF Commander
//
//  Created by Dwayne Forde on 2015-06-11.
//  Copyright (c) 2015 Dwayne Forde. All rights reserved.
//

import UIKit
import Alamofire
import QuartzCore
import SwiftyJSON

class ViewController: UIViewController {
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var apiTargetField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var targetButton: UIButton!
    
    var authEndpoint: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        apiTargetField.text = "https://api.run.pivotal.io"
        
        hideLoginForm()
    }
    
    override func viewDidAppear(animated: Bool) {
//        showLoginForm()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showLoginForm() {
        UIView.animateWithDuration(1, animations: {
            self.usernameField.alpha = 1
            self.usernameField.transform = CGAffineTransformIdentity
            
            self.passwordField.alpha = 1
            self.passwordField.transform = CGAffineTransformIdentity
            
            self.loginButton.alpha = 1
            self.loginButton.transform = CGAffineTransformIdentity
        })
    }
    
    func hideLoginForm() {
        usernameField.alpha = 0
        usernameField.transform = CGAffineTransformMakeTranslation(0, 50)
        
        passwordField.alpha = 0
        passwordField.transform = CGAffineTransformMakeTranslation(0, 50)
        
        loginButton.alpha = 0
        loginButton.transform = CGAffineTransformMakeTranslation(0, 50)
    }
    
    func showTargetForm() {
//        apiTargetField.
    }
    
    func hideTargetForm() {
        UIView.animateWithDuration(1, animations: {
            self.apiTargetField.alpha = 0
            self.apiTargetField.transform = CGAffineTransformMakeTranslation(0, -50)
            
            self.targetButton.alpha = 0
            self.targetButton.transform = CGAffineTransformMakeTranslation(0, -50)
        })
    }
    
    @IBAction func loginPushed(sender: UIButton) {
        let url = authEndpoint! + "/oauth/token"

        
//        let credential = NSURLCredential(user: "cf", password: "", persistence: .ForSession)
//                    .authenticate(usingCredential: credential)

        Alamofire.request(CF.Login(usernameField.text, passwordField.text))
            .validate()
            .responseJSON { (request, response, data, error) in
                if (error != nil) {
                    self.passwordField.layer.borderColor = UIColor.redColor().CGColor
                    self.passwordField.layer.borderWidth = 1
                    self.passwordField.layer.masksToBounds = true
                } else {
                    let json = JSON(data!)
                    let token = json["access_token"].string
                    CF.oauthToken = token
                    self.performSegueWithIdentifier("loginSegue", sender: nil)
                }
            }
    }
    
    @IBAction func targetPushed(sender: AnyObject) {
        var url = apiTargetField.text + "/v2/info"
        Alamofire.request(CF.Info())
            .validate()
            .responseJSON { (request, response, data, error) in
                if (error != nil) {
                    self.apiTargetField.layer.borderColor = UIColor.redColor().CGColor
                    self.apiTargetField.layer.borderWidth = 1
                    self.apiTargetField.layer.masksToBounds = true
                } else {
                    let json = JSON(data!)
                    self.authEndpoint = json["authorization_endpoint"].string
                    self.hideTargetForm()
                    self.showLoginForm()
                }
        }
    }
}