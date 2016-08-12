import Foundation
import SwiftWebSocket
import ProtocolBuffers

protocol CFLogger: NSObjectProtocol {
    func logsMessage(text: NSMutableAttributedString)
}

class CFLogs: NSObject {
    let font = UIFont(name: "Courier", size: 11.00)!
    let prefixColor = UIColor(red: 51/255, green: 140/255, blue: 231/255, alpha: 1.0)
    let outColor = UIColor.whiteColor()
    let errColor = UIColor.redColor()
    
    var appGuid: String
    var ws: WebSocket?
    var delegate: CFLogger?
    
    init(appGuid: String) {
        self.appGuid = appGuid
        super.init()
    }
    
    func connect() {
        logMessage(LogMessageString.out("Connecting"))
        tail()
    }
    
    func reconnect() {
        logMessage(LogMessageString.out("Reconnecting"))
        tail()
    }
    
    func tail() {
        do {
            let ws = try createSocket()
            
            ws.event.open = opened
            ws.event.close = closed
            ws.event.error = error
            ws.event.message = message
        } catch {
            print("--- Logs Connection Failed")
            logMessage(LogMessageString.out("Logs connection failed. Please try again"))
        }
    }
    
    func createSocket() throws -> WebSocket {
        let request = try createSocketRequest()
        
        self.ws = WebSocket(request: request)
        self.ws!.binaryType = WebSocketBinaryType.NSData
        return self.ws!
    }
    
    func createSocketRequest() throws -> NSMutableURLRequest {
        let account = CFSession.account()!
        let endpoint = account.info.loggingEndpoint
        let url = NSURL(string: "\(endpoint)/tail/?app=\(self.appGuid)")
        let request = NSMutableURLRequest(URL: url!)
        request.addValue("bearer \(CFSession.oauthToken!)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func opened() {
        logMessage(LogMessageString.out("Connected"))
    }
    
    func closed(code: Int, reason: String, wasClean: Bool) {
        logMessage(LogMessageString.out("Disconnected"))
    }
    
    func error(error: ErrorType) {
        let errorString = String(error)
        if (errorString == "InvalidResponse(HTTP/1.1 401 Unauthorized)") {
            handleAuthError()
        } else {
            print("--- Logs \(error)")
            dispatch_async(dispatch_get_main_queue(),{
                self.logMessage(LogMessageString.err(errorString))
            })
        }
    }
    
    func message(bytes: Any) {
        print("--- Log Message Received")
        let data = bytes as! NSData
        var text: NSMutableAttributedString?
        
        do {
            let logm = try LogMessage.parseFromData(data)
            let message = String(data: logm.message_, encoding: NSASCIIStringEncoding)!
            
            text = LogMessageString.message(logm.sourceName, sourceID: logm.sourceId, message: message, type: logm.messageType)
        } catch {
            print("Message parsing failed")
            text = NSMutableAttributedString(string: String(data: data, encoding: NSASCIIStringEncoding)!)
        }
        
        logMessage(text!)
    }
    
    func logMessage(message: NSMutableAttributedString) {
        self.delegate?.logsMessage(message)
    }
    
    func disconnect() {
        self.ws?.close()
    }
    
    private func handleAuthError() {
        if let account = CFSession.account() {
            let loginURLRequest = CFRequest.Login(account.info.authEndpoint, account.username, account.password)
            CFApi().request(loginURLRequest, success: { _ in
                self.tail()
            }, error: { _, _ in
                self.handleAuthFail()
            })
        } else {
            self.handleAuthFail()
        }
    }
    
    func handleAuthFail() {
        // TODO: Delegate this
        CFSession.logout(true)
    }
}