//
//  NSObject+SS.swift
//  SimpleSwift
//
//  Created by user on 2021/4/20.
//

import Foundation

public extension NSObject {
    class var named: String {
        return NSStringFromClass(self).components(separatedBy: ".").last ?? ""
    }
    
    var named: String {
        return NSStringFromClass(type(of: self)).components(separatedBy: ".").last ?? ""
    }
}
