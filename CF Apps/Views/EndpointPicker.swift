import Foundation
import UIKit

protocol EndpointPickerDelegate: NSObjectProtocol {
    func endpointPickerView(didSelectURL url: String?)
}

class EndpointPicker: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    var endpointPickerDelegate: EndpointPickerDelegate?
    var vendors: NSArray {
        let list = NSBundle.mainBundle().pathForResource("Vendors", ofType: "plist")!
        return NSArray(contentsOfFile: list)!
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        delegate = self
        dataSource = self
        self.selectRow(4, inComponent: 0, animated: false)
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
        let target = vendors[row].valueForKey("Target") as? String
        if let endpointValue = target {
            endpointPickerDelegate?.endpointPickerView(didSelectURL: endpointValue)
        } else {
            endpointPickerDelegate?.endpointPickerView(didSelectURL: nil)
        }
    }
}
