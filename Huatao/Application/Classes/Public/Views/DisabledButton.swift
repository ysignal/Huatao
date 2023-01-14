//
//  DisabledButton.swift
//  Huatao
//
//  Created by minse on 2023/1/12.
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
