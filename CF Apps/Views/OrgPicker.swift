//
//  OrgPicker.swift
//  CF Apps
//
//  Created by Dwayne Forde on 2015-12-10.
//  Copyright © 2015 Dwayne Forde. All rights reserved.
//

import Foundation
import UIKit

@objc(OrgPicker)

class OrgPicker: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    var data: NSArray = ["something"]
     func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return data[row] as? String
    }
}