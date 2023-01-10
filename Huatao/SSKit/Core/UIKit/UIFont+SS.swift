//
//  UIFont+SS.swift
//  SimpleSwift
//
//  Created by user on 2021/4/20.
//

import UIKit

public extension UIFont {
    static func ss_regular(size: CGFloat) -> UIFont {
        return UIFont(name: "PingFangSC-Regular", size: size) ?? .systemFont(ofSize: size)
    }
    
    static func ss_semibold(size: CGFloat) -> UIFont {
        return UIFont(name: "PingFangSC-Semibold", size: size) ?? .systemFont(ofSize: size)
    }
    
    static func ss_medium(size: CGFloat) -> UIFont{
        return UIFont(name: "PingFangSC-Medium", size: size) ?? .systemFont(ofSize: size)
    }
}
