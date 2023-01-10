//
//  HttpDecoder.swift
//  SimpleSwift
//
//  Created by user on 2021/4/21.
//

import Foundation

public struct HttpDecoder {
    var rootPath: String = ""
    
    public func decode<T: Codable>(_ json: Any, resultType: T.Type, path: String? = nil) throws -> T {
        var jsonObject = json
        var fullPath = rootPath
        if path != nil {
            if fullPath.count != 0 { fullPath += "." }
            fullPath += path!
        }
        if fullPath.count > 0 && jsonObject is [String : Any] {
            let paths = fullPath.components(separatedBy: ".")
            // 跳到指定路径
            paths.forEach { jsonObject = (jsonObject as! [String : Any])[$0]! }
        }
        let data = try JSONSerialization.data(withJSONObject: jsonObject, options: .fragmentsAllowed)
        do {
            return try JSONDecoder().decode(resultType, from: data)
        } catch {
            print(error)
            throw error
        }
    }
}
