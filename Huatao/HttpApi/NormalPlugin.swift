//
//  NormalPlugin.swift
//  Huatao
//
//  Created on 2023/2/28.
//  
	

import Foundation

struct NormalPlugin: PluginType {
    public func willSend(_ request: HttpRequest) {
        print("发起请求：\(request.fullPath)")
    }
    
    func didReceive(_ request: HttpRequest, response: HttpResponse) -> HttpResponse {
        var res = response
        switch res.statusCode {
        case 200:
            if let json = res.json as? [String: Any], let errorCode = json["error_code"] as? Int, let errorMsg = json["error_msg"] as? String {
                res.error = HttpError.custom(code: res.statusCode, message: "错误码：\(errorCode) \(errorMsg)")
            }
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
