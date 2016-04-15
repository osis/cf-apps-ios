import Foundation
import UIKit

class LogsViewController: UIViewController, CFLogger {
    @IBOutlet var logView: UITextView!
    
    var appGuid: String?
    var logs: CFLogs?
    
    let notificationCenter = NSNotificationCenter.defaultCenter()

    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(applicationBecameActive(_:)),
                                                         name: UIApplicationDidBecomeActiveNotification,
                                                         object: nil)
        self.logs = CFLogs(appGuid: self.appGuid!)
        startLogging()
    }
    
    override func viewWillDisappear(animated: Bool) {
        stopLogging()
    }
    
    func applicationBecameActive(notification: NSNotification) {
        self.logs!.reconnect()
    }
    
    func startLogging() {
        UIApplication.sharedApplication().idleTimerDisabled = true
        self.logs!.delegate = self
        self.logs!.connect()
    }
    
    func logsMessage(text: NSMutableAttributedString) {
        let logs = self.logView.attributedText.mutableCopy() as! NSMutableAttributedString
        logs.appendAttributedString(text)
        self.logView.attributedText = logs
        self.logView.scrollRangeToVisible(self.logView.selectedRange)
    }
    
    func stopLogging() {
        UIApplication.sharedApplication().idleTimerDisabled = false
        self.logs?.disconnect()
    }
}