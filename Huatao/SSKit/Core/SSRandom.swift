//
//  SSRandom.swift
//  SimpleSwift
//
//  Created by user on 2021/4/20.
//

import Foundation

public extension SS {
    
    static func between(left: Int, right: Int) -> Int {
//        return Int(arc4random_uniform(self))
        return Int(arc4random()%UInt32(right)) + left
    }
}
