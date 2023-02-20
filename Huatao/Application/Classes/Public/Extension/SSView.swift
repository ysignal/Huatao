//
//  SSView.swift
//  Huatao
//
//  Created on 2023/1/23.
//

import Foundation

extension UIView {
    
    func drawThemeGradient(_ size: CGSize) {
        drawGradient(start: UIColor.hex("#F5A41B"), end: .hex("#FF8100"), size: size, direction: .t2b)
    }
    
    func drawDisable(_ size: CGSize) {
        drawGradient(start: UIColor.hex("#dddddd"), end: .hex("#dddddd"), size: size, direction: .t2b)
    }
    
}
