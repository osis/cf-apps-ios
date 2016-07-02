import Foundation
import UIKit

protocol VendorPickerDelegate: NSObjectProtocol {
    func vendorPickerView(didSelectVendor target: String?, signupURL: String?)
}

class VendorPicker: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    var vendorPickerDelegate: VendorPickerDelegate?
    var vendors: NSArray {
        let list = NSBundle.mainBundle().pathForResource("Vendors", ofType: "plist")!
        return NSArray(contentsOfFile: list)!
    }
    let initialIndex = 5

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        delegate = self
        dataSource = self
        self.selectRow(initialIndex, inComponent: 0, animated: false)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return vendors.count
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let title = vendors[row].valueForKey("Name") as! String
        return NSAttributedString(string: title, attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let api = vendors[row].valueForKey("Target") as? String
        let url = vendors[row].valueForKey("URL") as? String
        if let target = api {
            vendorPickerDelegate?.vendorPickerView(didSelectVendor: target, signupURL: url!)
        } else {
            vendorPickerDelegate?.vendorPickerView(didSelectVendor: nil, signupURL: nil)
        }
    }
}
