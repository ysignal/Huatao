//
//  HttpError.swift
//  SimpleSwift
//
//  Created by user on 2021/4/21.
//

import Foundation

public enum HttpError: LocalizedError {
    case decode
    case custom(code: Int, message: String)

    public var errorDescription: String? {
        switch self {
        case .decode:
            return "数据解析失败"
        case let .custom(_, message):
            return message
        }
    }
}
