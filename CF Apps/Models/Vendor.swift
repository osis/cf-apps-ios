import Foundation

class Vendor {
    private static var otherOption: NSDictionary {
            let params = [
                "Name": "Other",
                "Target": "https://",
                "URL" : ""
            ]
        
            return NSDictionary(dictionary: params)
    }
    
    static var list: NSArray {
        let list = NSBundle.mainBundle().pathForResource("vendors", ofType: "plist")!
        return NSArray(contentsOfFile: list)!
    }
    
    static var options: NSArray {
        return list.arrayByAddingObject(otherOption)
    }
}