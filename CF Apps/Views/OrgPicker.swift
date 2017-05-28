import Foundation
import UIKit

@objc(OrgPicker)

class OrgPicker: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    var data: NSArray = ["something"]
     func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return data[row] as? String
    }
}
