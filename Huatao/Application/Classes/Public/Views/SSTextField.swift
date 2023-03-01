//
//  SSTextField.swift
//  Huatao
//
//  Created on 2023/2/28.
//  
	

import UIKit

protocol SSTextFieldDelegate: UITextFieldDelegate {
    func textFieldDidDeleteBackward(_ textField: SSTextField)
}

class SSTextField: UITextField {

    weak var ssDelegate: SSTextFieldDelegate?
    
    override func deleteBackward() {
        super.deleteBackward()
        ssDelegate?.textFieldDidDeleteBackward(self)
    }
    
}
