//
//  SSView.swift
//  Huatao
//
//  Created by minse on 2023/1/23.
//

import Foundation

extension UIView {
    
    func drawThemeGradient(_ size: CGSize) {
        drawGradient(start: UIColor.hex("#F5A41B"), end: .hex("#FF8100"), size: size, direction: .t2b)
    }
    
}
