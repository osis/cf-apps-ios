import Foundation
import SwiftWebSocket
import ProtocolBuffers

protocol CFLogger: NSObjectProtocol {
    func logsMessage(_ text: NSMutableAttributedString)
    func recentLogsFetched()
}

class CFLogs: NSObject {
    let font = UIFont.init(name: "Courier", size: 11.00)!
    let prefixColor = UIColor(red: 51/255, green: 140/255, blue: 231/255, alpha: 1.0)
    let outColor = UIColor.white
    let errColor = UIColor.red
    
    var appGuid: String
    var ws: WebSocket?
    var delegate: CFLogger?
    
    init(appGuid: String) {
        self.appGuid = appGuid
        super.init()
    }
    
    func recent() {
        logMessage(LogMessageString.out("Fetching Recent Logs..."))
        let request = CFRequest.recentLogs(self.appGuid)
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
    
    func closed(_ code: Int, reason: String, wasClean: Bool) {
        logMessage(LogMessageString.out("Disconnected"))
    }
    
    func error(_ error: Error) {
        let errorString = String(describing: error)
        if (errorString == "InvalidResponse(HTTP/1.1 401 Unauthorized)") {
            handleAuthError()
        } else {
            print("--- Logs \(error)")
            DispatchQueue.main.async(execute: {
                self.logMessage(LogMessageString.err(errorString))
            })
        }
    }
    
    func message(_ bytes: Any) {
        let data = bytes as! Data
        var text: NSMutableAttributedString?
        
        do {
            let envelope = try Events.Envelope.parseFrom(data: data)
            
            if let logm = envelope.logMessage, envelope.hasLogMessage {
                let message = String(data: logm.message, encoding: String.Encoding.ascii)!
                text = LogMessageString.message(logm.sourceType, sourceID: logm.sourceInstance, message: message, type: logm.messageType)
            }
        } catch {
            print("Message parsing failed")
            text = NSMutableAttributedString(string: String(data: data, encoding: String.Encoding.ascii)!)
        }
        
        if let msg = text {
            logMessage(msg)
        }
    }
    
    func createSocket() throws -> WebSocket {
        let request = try createSocketRequest()
        
        self.ws = WebSocket(request: request as URLRequest)
        self.ws!.binaryType = WebSocketBinaryType.nsData
        return self.ws!
    }
    
    func createSocketRequest() throws -> NSMutableURLRequest {
        let account = CFSession.account()!
        let endpoint = account.info.dopplerLoggingEndpoint
        let url = URL(string: "\(endpoint)/apps/\(self.appGuid)/stream")
        let request = NSMutableURLRequest(url: url!)

        request.addValue("bearer \(CFSession.oauthToken!)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func handleAuthFail() {
        // TODO: Delegate this
        CFSession.logout(true)
    }
}

private extension CFLogs {
    func logMessage(_ message: NSMutableAttributedString) {
        self.delegate?.logsMessage(message)
    }
    
    func handleRecent(_ response: HTTPURLResponse?, data: Data?) {
        if let contentType = response?.allHeaderFields["Content-Type"] as! String? {
            let boundary = contentType.components(separatedBy: "boundary=").last!
            let chunks = self.chunkMessage(data!, boundary: boundary)
            
            for log in chunks {
                do {
                    let envelope = try Events.Envelope.parseFrom(data: data!)
                    self.message(envelope.logMessage.data())
                } catch {
                    print(error)
                }
            }
            delegate?.recentLogsFetched()
        }
    }
    
    func handleAuthError() {
        if let account = CFSession.account() {
            let loginURLRequest = CFRequest.login(account.info.authEndpoint, account.username, account.password)
            CFApi().request(loginURLRequest, success: { _ in
                self.tail()
                }, error: { _, _ in
                    self.handleAuthFail()
            })
        } else {
            self.handleAuthFail()
        }
    }
    
    func chunkMessage(_ data: Data, boundary: String) -> ArraySlice<Data> {
        let sepdata = String("--\(boundary)").data(using: String.Encoding.ascii, allowLossyConversion: false)!
        var chunks : [Data] = []
        
        // Find first occurrence of separator:
        var searchRange = NSMakeRange(0, data.count)
        var foundRange = data.range(of: sepdata, options: NSData.SearchOptions(), in: searchRange.toRange())

        while foundRange != nil {
            // Append chunk without \r\n\r\n & \r\n (if not empty):
            if foundRange!.lowerBound - 6 > searchRange.location + 4 {
                let newRange = NSMakeRange(searchRange.location+4, foundRange!.lowerBound-6 - searchRange.location)
                let d1 = data.subdata(in: newRange.toRange()!)
                chunks.append(d1)
            }
            // Search next occurrence of separator:
            searchRange.location = foundRange!.lowerBound + foundRange!.count
            searchRange.length = data.count - searchRange.location
            foundRange = data.range(of: sepdata, options: NSData.SearchOptions(), in: searchRange.toRange())
        }
        // Check for final chunk:
        if searchRange.length > 0 {
            chunks.append(data.subdata(in: searchRange.toRange()!))
        }
        return chunks.dropLast().suffix(100)
    }
}
