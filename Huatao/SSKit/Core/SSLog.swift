//
//  SSLog.swift
//  SimpleSwift
//
//  Created by user on 2021/4/20.
//

import Foundation

public extension SS {
    static func log(_ items: Any...,
                    separator: String = " ",
                    terminator: String = "\n",
                    file: String = #file,
                    line: Int = #line,
                    method: String = #function)
    {
        guard APP.isDebug() else { return }
        print("-----------🖨🖨🖨 \(URL(fileURLWithPath: file).lastPathComponent)[\(line)], \(method) 🖨🖨🖨-----------:")
        var i = 0
        let j = items.count
        for a in items {
            i += 1
            print(" ",a, terminator:i == j ? terminator: separator)
        }
    }
}
