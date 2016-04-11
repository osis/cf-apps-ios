import Foundation
import XCTest

@testable import CF_Apps
class LogMessageStringTests: XCTestCase {
    func testMessageFormat() {
        let message = LogMessageString.message("SRC", sourceID: "0", message: "Message", type: LogMessage.MessageType.Out)
        
        XCTAssertEqual(message.string, "SRC[0]: Message\n\n")
        
        var srcRange = NSString(string: message.string).rangeOfString("SRC[0]:")
        
        let srcAttributes = message.attributesAtIndex(0, effectiveRange: &srcRange)
        let srcFont = srcAttributes["NSFont"] as! UIFont
        let srcColor = srcAttributes["NSColor"] as! UIColor
        
        XCTAssertEqual(srcFont, LogMessageString.font)
        XCTAssertEqual(srcColor, LogMessageString.prefixColor)
        
        var msgRange = NSString(string: message.string).rangeOfString("Message")
        let msgAttributes = message.attributesAtIndex(8, effectiveRange: &msgRange)
        let msgFont = msgAttributes["NSFont"] as! UIFont
        let msgColor = msgAttributes["NSColor"] as! UIColor
        
        XCTAssertEqual(msgFont, LogMessageString.font)
        XCTAssertEqual(msgColor, LogMessageString.outColor)
    }
    
    func testMessageErrorFormat() {
        let message = LogMessageString.message("SRC", sourceID: "0", message: "Message", type: LogMessage.MessageType.Err)
        
        var msgRange = NSString(string: message.string).rangeOfString("Message")
        let msgAttributes = message.attributesAtIndex(8, effectiveRange: &msgRange)
        
        let msgColor = msgAttributes["NSColor"] as! UIColor
        
        XCTAssertEqual(msgColor, LogMessageString.errColor)
    }
}