import Foundation
import UIKit

protocol EndpointPickerDelegate: NSObjectProtocol {
    func endpointPickerView(didSelectURL url: String?)
}

class EndpointPicker: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    var pickerData: [String] = [
        "Atos", "IBM BlueMix", "Pivotal Web Services", "Predix", "Other"
    ]
    var pickerValues: [String?] = [
        "https://api.sys.eu01.cf.canopy-cloud.com", "https://api.ng.bluemix.net", "https://api.run.pivotal.io", "https://api.system.aws-usw02-pr.ice.predix.io", nil
    ]
    var endpointPickerDelegate: EndpointPickerDelegate?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        delegate = self
        dataSource = self
        self.selectRow(2, inComponent: 0, animated: false)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: pickerData[row], attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let endpointValue = pickerValues[row] {
            endpointPickerDelegate?.endpointPickerView(didSelectURL: endpointValue)
        } else {
            endpointPickerDelegate?.endpointPickerView(didSelectURL: nil)
        }
    }
}