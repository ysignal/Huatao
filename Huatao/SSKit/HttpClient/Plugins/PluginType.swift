//
//  PluginType.swift
//  SimpleSwift
//
//  Created by user on 2021/4/21.
//

public protocol PluginType {
    /// 将要生成URLRequest
    func prepare(_ request: HttpRequest) -> HttpRequest
    /// 将要发起请求
    func willSend(_ request: HttpRequest)
    /// 收到响应
    func didReceive(_ request: HttpRequest, response: HttpResponse) -> HttpResponse
}

public extension PluginType {
    func prepare(_ request: HttpRequest) -> HttpRequest {
        return request
    }

    func willSend(_ request: HttpRequest) {}
    
    func didReceive(_ request: HttpRequest, response: HttpResponse) -> HttpResponse {
        return response
    }
}
