//
//  SSPickerView.swift
//  Charming
//
//  Created by minse on 2022/10/15.
//

import UIKit

protocol SSPickerViewDelegate: NSObjectProtocol {

    func pickerView(_ pickerView: SSPickerView, widthForComponent component: Int) -> CGFloat

    func pickerView(_ pickerView: SSPickerView, rowHeightForComponent component: Int) -> CGFloat

    func pickerView(_ pickerView: SSPickerView, titleForRow row: Int, forComponent component: Int) -> String?

    func pickerView(_ pickerView: SSPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString?

    func pickerView(_ pickerView: SSPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView

    func pickerView(_ pickerView: SSPickerView, didSelectRow row: Int, inComponent component: Int)
}

protocol SSPickerViewDataSource: NSObjectProtocol {
    
    func numberOfComponents(in pickerView: SSPickerView) -> Int
    
    func pickerView(_ pickerView: SSPickerView, numberOfRowsInComponent component: Int) -> Int
    
}

class SSPickerView: UIControl {
    
    weak var dalegate: SSPickerViewDelegate?
    weak var dataSource: SSPickerViewDataSource?
    
    var picker: UIPickerView? = nil


}
