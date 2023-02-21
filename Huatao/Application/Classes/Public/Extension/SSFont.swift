//
//  SSFont.swift
//  Huatao
//
//  Created on 2023/1/16.
//

import Foundation

extension UIFont {
    
    static func ss_dinbold(size: CGFloat) -> UIFont {
        return UIFont(name: "DIN Alternate", size: size) ?? .ss_semibold(size: size)
    }
    
}
