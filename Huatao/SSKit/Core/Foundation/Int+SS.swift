//
//  Int+SS.swift
//  SimpleSwift
//
//  Created by user on 2021/4/20.
//

import Foundation

public extension Int {
    var string: String {
        return "\(self)"
    }
    
    var random: Int {
        return Int(arc4random_uniform(UInt32(self)))
    }
}
