import Foundation
import SwiftWebSocket
import ProtocolBuffers

protocol CFLogger: NSObjectProtocol {
    func logsMessage(text: NSMutableAttributedString)
    func recentLogsFetched()
}

class CFLogs: NSObject {
    let font = UIFont.init(name: "Courier", size: 11.00)!
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
    
    func recent() {
        logMessage(LogMessageString.out("Fetching Recent Logs..."))
        let request = CFRequest.RecentLogs(self.appGuid)
        CFApi().dopplerRequest(request) { (request, response, data, rError) in
            if (response?.statusCode == 401) {
                self.handleAuthFail()
            } else {
                self.handleRecent(response, data: data)
            }
        }
    }
    
    func connect() {
        logMessage(LogMessageString.out("Connecting..."))
        tail()
    }
    
    func reconnect() {
        logMessage(LogMessageString.out("Reconnecting..."))
        tail()
    }
    
    func disconnect() {
        self.ws?.close()
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
        let data = bytes as! NSData
        var text: NSMutableAttributedString?
        
        do {
            let envelope = try Events.Envelope.parseFromData(data)
            let logm = envelope.logMessage
            
            if envelope.hasLogMessage {
                let message = String(data: logm.message_, encoding: NSASCIIStringEncoding)!
                text = LogMessageString.message(logm.sourceType, sourceID: logm.sourceInstance, message: message, type: logm.messageType)
            }
        } catch {
            print("Message parsing failed")
            text = NSMutableAttributedString(string: String(data: data, encoding: NSASCIIStringEncoding)!)
        }
        
        if let msg = text {
            logMessage(msg)
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
        let endpoint = account.info.dopplerLoggingEndpoint
        let url = NSURL(string: "\(endpoint)/apps/\(self.appGuid)/stream")
        let request = NSMutableURLRequest(URL: url!)
        request.addValue("bearer \(CFSession.oauthToken!)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func handleAuthFail() {
        // TODO: Delegate this
        CFSession.logout(true)
    }
}

private extension CFLogs {
    func logMessage(message: NSMutableAttributedString) {
        self.delegate?.logsMessage(message)
    }
    
    func handleRecent(response: NSHTTPURLResponse?, data: NSData?) {
        if let contentType = response?.allHeaderFields["Content-Type"] as! String? {
            let boundary = contentType.componentsSeparatedByString("boundary=").last!
            let chunks = self.chunkMessage(data!, boundary: boundary)
            
            for log in chunks {
                do {
                    let envelope = try Events.Envelope.parseFromData(log)
                    self.message(envelope.data())
                } catch {
                    print(error)
                }
            }
            delegate?.recentLogsFetched()
        }
    }
    
    func handleAuthError() {
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
    
    func chunkMessage(data: NSData, boundary: String) -> ArraySlice<NSData> {
        let sepdata = String("--\(boundary)").dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: false)!
        var chunks : [NSData] = []
        
        // Find first occurrence of separator:
        var searchRange = NSMakeRange(0, data.length)
        var foundRange = data.rangeOfData(sepdata, options: NSDataSearchOptions(), range: searchRange)
        while foundRange.location != NSNotFound {
            // Append chunk without \r\n\r\n & \r\n (if not empty):
            if foundRange.location - 6 > searchRange.location + 4 {
                chunks.append(data.subdataWithRange(NSMakeRange(searchRange.location+4, foundRange.location-6 - searchRange.location)))
            }
            // Search next occurrence of separator:
            searchRange.location = foundRange.location + foundRange.length
            searchRange.length = data.length - searchRange.location
            foundRange = data.rangeOfData(sepdata, options: NSDataSearchOptions(), range: searchRange)
        }
        // Check for final chunk:
        if searchRange.length > 0 {
            chunks.append(data.subdataWithRange(searchRange))
        }
        return chunks.dropLast().suffix(100)
    }
}