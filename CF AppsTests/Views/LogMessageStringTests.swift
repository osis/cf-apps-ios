import Foundation
import XCTest

@testable import CF_Apps
class LogMessageStringTests: XCTestCase {
    func testMessageFormat() {
        let message = LogMessageString.message("SRC", sourceID: "0", message: "Message", type: Events.LogMessage.MessageType.out)
        
        XCTAssertEqual(message.string, "SRC[0]: Message\n\n")
        
        var srcRange = NSString(string: message.string).range(of: "SRC[0]:")
        
        let srcAttributes = message.attributes(at: 0, effectiveRange: &srcRange)
        let srcFont = srcAttributes["NSFont"] as! UIFont
        let srcColor = srcAttributes["NSColor"] as! UIColor
        
        XCTAssertEqual(srcFont, LogMessageString.font)
        XCTAssertEqual(srcColor, LogMessageString.prefixColor)
        
        var msgRange = NSString(string: message.string).range(of: "Message")
        let msgAttributes = message.attributes(at: 8, effectiveRange: &msgRange)
        let msgFont = msgAttributes["NSFont"] as! UIFont
        let msgColor = msgAttributes["NSColor"] as! UIColor
        
        XCTAssertEqual(msgFont, LogMessageString.font)
        XCTAssertEqual(msgColor, LogMessageString.outColor)
    }
    
    func testMessageErrorFormat() {
        let message = LogMessageString.message("SRC", sourceID: "0", message: "Message", type: Events.LogMessage.MessageType.err)
        
        var msgRange = NSString(string: message.string).range(of: "Message")
        let msgAttributes = message.attributes(at: 8, effectiveRange: &msgRange)
        
        let msgColor = msgAttributes["NSColor"] as! UIColor
        
        XCTAssertEqual(msgColor, LogMessageString.errColor)
    }
}
