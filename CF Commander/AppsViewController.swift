//
//  AppsViewController.swift
//  CF Commander
//
//  Created by Dwayne Forde on 2015-06-14.
//  Copyright (c) 2015 Dwayne Forde. All rights reserved.
//

import UIKit
import Alamofire

class AppsViewController: UIViewController {
    var token:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadApplications()
    }
    
    func loadApplications() {
        Alamofire.request(CF.Orgs())
            .validate()
            .responseJSON { (request, response, data, error) in
                if (error != nil) {
                } else {
                }
        }
    }
}