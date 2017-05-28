import Foundation

class Vendor {
    fileprivate static var otherOption: NSDictionary {
            let params = [
                "Name": "Other",
                "Target": "https://",
                "URL" : ""
            ]
        
            return NSDictionary(dictionary: params)
    }
    
    static var list: NSArray {
        let list = Bundle.main.path(forResource: "vendors", ofType: "plist")!
        return NSArray(contentsOfFile: list)!
    }
    
    static var options: NSArray {
        return list.adding(otherOption) as NSArray
    }
}
