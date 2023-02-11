//
//  UITextField+SS.swift
//  Huatao
//
//  Created on 2023/1/12.
//

import Foundation

extension UITextField {
    
    private struct AssociatedKeys {
        static var maxLength = "kMaxLength"
    }
    
    @IBInspectable var maxLength: Int {
        get {
            if let length = objc_getAssociatedObject(self, &AssociatedKeys.maxLength) as? Int {
                return length
            } else {
                return .max
            }
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.maxLength, newValue, .OBJC_ASSOCIATION_RETAIN)
            addTarget(self, action: #selector(checkMaxLength), for: .editingChanged)
        }
    }
    
    @objc func checkMaxLength(textField: UITextField) {
        guard let prospectiveText = self.text,
              prospectiveText.count > maxLength else { return }

        let selection = selectedTextRange

        let indexEndOfText = prospectiveText.index(prospectiveText.startIndex, offsetBy: maxLength)
        let substring = prospectiveText[..<indexEndOfText]
        text = String(substring)
        selectedTextRange = selection
    }
    
    var trimedText: String? {
        return text?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
