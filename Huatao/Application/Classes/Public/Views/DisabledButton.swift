//
//  DisabledButton.swift
//  Huatao
//
//  Created on 2023/1/12.
//

import Foundation

class DisabledButton: UIButton {

    override var isEnabled: Bool {
        didSet {
            if isEnabled {
                backgroundColor = .ss_theme
            } else {
                backgroundColor = .hex("dddddd")
            }
        }
    }

}
