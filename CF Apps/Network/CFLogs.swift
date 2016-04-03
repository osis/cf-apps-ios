//
//  CFLogs.swift
//  CF Apps
//
//  Created by Dwayne Forde on 2016-03-27.
//  Copyright © 2016 Dwayne Forde. All rights reserved.
//

import Foundation
import SwiftWebSocket
import ProtocolBuffers

protocol CFLogger: NSObjectProtocol {
    func logsConnected()
    func logsError(description: String)
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
    
    func tail() {
        do {
            let ws = try createSocket()
            
            ws.event.open = opened
            ws.event.close = closed
            ws.event.error = error
            ws.event.message = message
        } catch {
            print("--- Logs Connection Failed")
            self.delegate?.logsError("Logs connection failed. Please try again")
        }
    }
    
    func createSocket() throws -> WebSocket {
        let request = try createSocketRequest()
        
        self.ws = WebSocket(request: request)
        self.ws!.binaryType = WebSocketBinaryType.NSData
        return self.ws!
    }
    
    func createSocketRequest() throws -> NSMutableURLRequest {
        let endpoint = try Keychain.getLoggingURL()
        let url = NSURL(string: "\(endpoint)/tail/?app=\(self.appGuid)")
        let request = NSMutableURLRequest(URL: url!)
        request.addValue("bearer \(CFSession.oauthToken!)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func opened() {
        self.delegate?.logsConnected()
    }
    
    func closed(code: Int, reason: String, wasClean: Bool) {
        print("--- Logs Connection Closed")
    }
    
    func error(error: ErrorType) {
        let errorString = String(error)
        if (errorString == "InvalidResponse(HTTP/1.1 401 Unauthorized)") {
            handleAuthError()
        } else {
            print("--- Logs \(error)")
            dispatch_async(dispatch_get_main_queue(),{
                self.delegate?.logsError(errorString)
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
            
            text = formatMessage(logm.sourceName, sourceID: logm.sourceId, message: message, type: logm.messageType)
        } catch {
            print("Message parsing failed")
            text = NSMutableAttributedString(string: String(data: data, encoding: NSASCIIStringEncoding)!)
        }
        
        self.delegate?.logsMessage(text!)
    }
    
    func formatMessage(sourceName: String, sourceID: String, message: String, type: LogMessage.MessageType) -> NSMutableAttributedString {
        let prefix = "\n\n\(sourceName)[\(sourceID)]:"
        let text = NSMutableAttributedString(string: "\(prefix) \(message)", attributes: [NSFontAttributeName: font])
        
        let textString = NSString(string: text.string)
        let prefixRange = textString.rangeOfString(prefix)
        let messageRange = textString.rangeOfString(message)
        let messageColor = (type == LogMessage.MessageType.Out) ? outColor : errColor
        
        text.addAttribute(NSForegroundColorAttributeName, value: prefixColor, range: prefixRange)
        text.addAttribute(NSForegroundColorAttributeName, value: messageColor, range: messageRange)
        
        return text
    }
    
    func disconnect() {
        self.ws?.close()
    }
    
    private func handleAuthError() {
        do {
            let (authURL, _, username, password) = try Keychain.getCredentials()
            let loginURLRequest = CFRequest.Login(authURL, username, password)
            
            CFApi().request(loginURLRequest, success: { _ in
                self.tail()
            }, error: { _, _ in
                self.handleAuthFail()
            })
        } catch {
            self.handleAuthFail()
        }
    }
    
    func handleAuthFail() {
        CFSession.logout()
    }
}