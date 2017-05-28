import Foundation
import UIKit

class LogMessageString: NSMutableAttributedString {
    static let font = UIFont(name: "Courier", size: 11.00)!
    static let prefixColor = UIColor(red: 51/255, green: 140/255, blue: 231/255, alpha: 1.0)
    static let outColor = UIColor.white
    static let errColor = UIColor.red
    
    class func out(_ string: String) -> NSMutableAttributedString {
        return message("", sourceID: "", message: string, type: Events.LogMessage.MessageType.out)
    }
    
    class func err(_ string: String) -> NSMutableAttributedString {
        return message("", sourceID: "", message: string, type: Events.LogMessage.MessageType.err)
    }
    
    class func message(_ sourceName: String, sourceID: String, message: String, type: Events.LogMessage.MessageType) -> NSMutableAttributedString {
        let prefix = "\(sourceName)[\(sourceID)]:"
        let text = NSMutableAttributedString(string: "\(prefix) \(message)\n\n", attributes: [NSFontAttributeName: font])
        
        let textString = NSString(string: text.string)
        let prefixRange = textString.range(of: prefix)
        let messageRange = textString.range(of: message)
        let messageColor = (type == Events.LogMessage.MessageType.out) ? outColor : errColor
        
        text.addAttribute(NSForegroundColorAttributeName, value: prefixColor, range: prefixRange)
        text.addAttribute(NSForegroundColorAttributeName, value: messageColor, range: messageRange)
        
        return text
    }
}
