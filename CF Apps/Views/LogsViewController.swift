import Foundation
import UIKit
import CFoundry

class LogsViewController: UIViewController, CFLogger {
    @IBOutlet var logView: UITextView!
    
    var appGuid: String?
    var logs: CFLogs?
    
    let notificationCenter = NotificationCenter.default

    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(applicationBecameActive(_:)),
                                                         name: NSNotification.Name.UIApplicationDidBecomeActive,
                                                         object: nil)
        self.logs = CFLogs(appGuid: self.appGuid!)
        startLogging()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        stopLogging()
    }
    
    @objc func applicationBecameActive(_ notification: Notification) {
        self.logs!.reconnect()
    }
    
    func startLogging() {
        UIApplication.shared.isIdleTimerDisabled = true
        self.logs!.delegate = self
        self.logs!.recent()
    }
    
    func logsMessage(_ text: NSMutableAttributedString) {
        let logs = self.logView.attributedText.mutableCopy() as! NSMutableAttributedString
        logs.append(text)
        self.logView.attributedText = logs
        self.logView.scrollRangeToVisible(self.logView.selectedRange)
    }
    
    func recentLogsFetched() {
        self.logs!.connect()
    }
    
    func stopLogging() {
        UIApplication.shared.isIdleTimerDisabled = false
        self.logs?.disconnect()
    }
}
