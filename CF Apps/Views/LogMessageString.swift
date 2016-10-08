import Foundation
import UIKit

class LogMessageString: NSMutableAttributedString {
    static let font = UIFont(name: "Courier", size: 11.00)!
    static let prefixColor = UIColor(red: 51/255, green: 140/255, blue: 231/255, alpha: 1.0)
    static let outColor = UIColor.whiteColor()
    static let errColor = UIColor.redColor()
    
    class func out(string: String) -> NSMutableAttributedString {
        return message("", sourceID: "", message: string, type: Events.LogMessage.MessageType.Out)
    }
    
    class func err(string: String) -> NSMutableAttributedString {
        return message("", sourceID: "", message: string, type: Events.LogMessage.MessageType.Err)
    }
    
    class func message(sourceName: String, sourceID: String, message: String, type: Events.LogMessage.MessageType) -> NSMutableAttributedString {
        let prefix = "\(sourceName)[\(sourceID)]:"
        let text = NSMutableAttributedString(string: "\(prefix) \(message)\n\n", attributes: [NSFontAttributeName: font])
        
        let textString = NSString(string: text.string)
        let prefixRange = textString.rangeOfString(prefix)
        let messageRange = textString.rangeOfString(message)
        let messageColor = (type == Events.LogMessage.MessageType.Out) ? outColor : errColor
        
        text.addAttribute(NSForegroundColorAttributeName, value: prefixColor, range: prefixRange)
        text.addAttribute(NSForegroundColorAttributeName, value: messageColor, range: messageRange)
        
        return text
    }
}