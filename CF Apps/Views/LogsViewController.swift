//
//  LogsViewController.swift
//  CF Apps
//
//  Created by Dwayne Forde on 2016-03-26.
//  Copyright © 2016 Dwayne Forde. All rights reserved.
//

import Foundation
import UIKit

class LogsViewController: UIViewController, CFLogger {
    @IBOutlet var logView: UITextView!
    
    var appGuid: String?
    var logs: CFLogs?

    override func viewDidLoad() {
        self.logs = CFLogs(appGuid: self.appGuid!)
        startLogging()
    }
    
    override func viewWillDisappear(animated: Bool) {
        stopLogging()
    }
    
    func startLogging() {
        self.logs!.delegate = self
        self.logs!.tail()
    }
    
    func logsConnected() {
        self.logView.text = ""
    }
    
    func logsError(description: String) {
        self.logView.text = description
    }
    
    func logsMessage(text: NSMutableAttributedString) {
        let logs = self.logView.attributedText.mutableCopy() as! NSMutableAttributedString
        logs.appendAttributedString(text)
        self.logView.attributedText = logs
        self.logView.scrollRangeToVisible(self.logView.selectedRange)
    }
    
    func stopLogging() {
        self.logs?.disconnect()
    }
}