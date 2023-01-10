//
//  ParamsPlugin.swift
//  SimpleSwift
//
//  Created by user on 2021/4/22.
//

import Foundation

struct ParamsPlugin: PluginType {
    func didReceive(_ request: HttpRequest, response: HttpResponse) -> HttpResponse {
        var res = response
        let complete = {
            if let json = response.json as? [String: Any],
                let status = json["code"] as? Int,
                let message = json["message"] as? String {
                switch status {
                case 1:
                    res.json = json["data"]
                default:
                    res.error = HttpError.custom(code: status, message: message)
                }
            } else {
                res.error = HttpError.custom(code: res.statusCode, message: "服务器发生未知错误")
                if let data = res.data { debugPrint(String(data: data, encoding: .utf8)!) }
            }
        }
        // 上传数据的情况下，请求的状态码为0，需要特殊处理
        if let files = request.files, files.count > 0 {
            complete()
            return res
        }
        
        switch res.statusCode {
        case 200:
            complete()
            return res
        default:
            if let data = response.data, data.count < 500 {
                res.error = HttpError.custom(code: res.statusCode, message: String(data: data, encoding: .utf8)!)
            } else {
                res.error = HttpError.custom(code: res.statusCode, message: "服务器发生未知错误")
                if let data = response.data { debugPrint(String(data: data, encoding: .utf8)!) }
            }
            return res
        }
    }
}
