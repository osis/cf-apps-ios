import Foundation
import UIKit

protocol VendorPickerDelegate: NSObjectProtocol {
    func vendorPickerView(didSelectVendor target: String, signupURL: String)
}

class VendorPicker: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    var vendorPickerDelegate: VendorPickerDelegate?
    let initialIndex = 8
    let vendors = Vendor.options

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        delegate = self
        dataSource = self
        
        self.selectRow(initialIndex, inComponent: 0, animated: false)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return vendors.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let title = (vendors[row] as AnyObject).value(forKey: "Name") as! String
        return NSAttributedString(string: title, attributes: [.foregroundColor:UIColor.white])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let target = (vendors[row] as AnyObject).value(forKey: "Target") as! String
        let url = (vendors[row] as AnyObject).value(forKey: "URL") as! String
        
        vendorPickerDelegate?.vendorPickerView(didSelectVendor: target, signupURL: url)
    }
}
