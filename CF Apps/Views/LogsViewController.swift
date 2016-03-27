//
//  LogsViewController.swift
//  CF Apps
//
//  Created by Dwayne Forde on 2016-03-26.
//  Copyright © 2016 Dwayne Forde. All rights reserved.
//

import Foundation
import UIKit
import SwiftWebSocket

class LogsViewController: UIViewController {
    @IBOutlet var logView: UITextView!
    
    var appGuid: String?
    var ws: WebSocket?
    
    override func viewDidLoad() {
        startLogging()
    }
    
    override func viewWillDisappear(animated: Bool) {
        stopLogging()
    }
    
    func startLogging() {
        do {
            let ws = try createSocket()
            
            ws.event.open = logsOpened
            ws.event.close = logsClosed
            ws.event.error = logsError
            ws.event.message = logReceived
        } catch {
            print("--- Logs Connection Failed")
            self.logView.text = "Logs connection failed. Please try again"
        }
    }
    
    func logsOpened() {
        print("--- Logs Connection Opened")
        self.logView.text = ""
    }
    
    func logsClosed(code: Int, reason: String, wasClean: Bool) {
        print("--- Logs Connection Closed")
    }
    
    func logsError(error: ErrorType) {
        print("--- Logs \(error)")
        self.logView.text = String(error)
    }
    
    func logReceived(message: Any) {
        print("--- Log Received")
        let data = message as! NSData
        let text = String(data: data, encoding: NSASCIIStringEncoding)
        
        self.logView.text = self.logView.text.stringByAppendingString("\n\(text!)")
        self.logView.scrollRangeToVisible(self.logView.selectedRange)
    }
    
    func stopLogging() {
        self.ws?.close()
    }
    
    func createSocket() throws -> WebSocket {
        let endpoint = try Keychain.getLoggingURL()
        let url = NSURL(string: "\(endpoint)/tail/?app=\(self.appGuid!)")
        let request = NSMutableURLRequest(URL: url!)
        
        request.addValue("bearer \(CFSession.oauthToken!)", forHTTPHeaderField: "Authorization")
        
        self.ws = WebSocket(request: request)
        self.ws!.binaryType = WebSocketBinaryType.NSData
        return self.ws!
    }
}