//
//  LoggerPlugin.swift
//  SimpleSwift
//
//  Created by user on 2021/4/21.
//

import Foundation

public class LoggerPlugin: PluginType {
    public func willSend(_ request: HttpRequest) {
        print("发起请求：\(request.fullPath)，参数：\(request.params ?? [:])")
    }

    public func didReceive(_ request: HttpRequest, response: HttpResponse) -> HttpResponse {
        if !response.isSuccess {
            print("请求失败：\(request.fullPath)，错误：\(response.error!.localizedDescription)")
            return response
        }
        var data: Any
        if response.json != nil {
            data = response.data?.prettyPrintedJSONString ?? ""
        } else {
            data = String(data: response.data!, encoding: .utf8) ?? ""
        }
        print("请求结束：\(request.fullPath)，响应内容：\(data)")
        return response
    }

    public init() {}
}

fileprivate extension Data {
    var prettyPrintedJSONString: NSString? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
            let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
            let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }

        return prettyPrintedString
    }
}
