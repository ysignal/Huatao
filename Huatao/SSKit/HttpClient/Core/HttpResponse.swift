//
//  HttpResponse.swift
//  SimpleSwift
//
//  Created by user on 2021/4/21.
//

import Foundation

public struct HttpResponse {
    /// 响应内容
    public var data: Data?
    /// json数据
    public var json: Any?
    /// 请求失败，错误
    public var error: Error?
    /// http响应状态码
    public var statusCode: Int = 0
    /// 是否请求成功
    public var isSuccess: Bool {
        return error == nil && data != nil
    }

    /// 附加参数，用户扩展自定义信息
    public var userInfo: [String: Any] = [:]
}
