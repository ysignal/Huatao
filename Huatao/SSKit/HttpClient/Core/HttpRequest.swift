//
//  HttpRequest.swift
//  SimpleSwift
//
//  Created by user on 2021/4/21.
//

import Foundation
import Alamofire

public struct HttpRequest {
    /// 请求路径，相对路径
    public var path: String
    /// 全路径
    public var fullPath: String = ""
    /// 请求方式
    public var method: HTTPMethod
    /// HTTPHeaders
    public var headers: [String: String] = [:]
    /// 请求参数
    public var params: [String: Any]?
    /// 参数类型
    public var paramsType: ParamsType = .url {
        didSet {
            switch paramsType {
            case .url:
                encoding = URLEncoding.default
            case .json:
                encoding = JSONEncoding.default
            }
        }
    }
    
    public let privateKey = "!QWArfeedde#%^&aa"
    
    /// 是否签名
    public var isSign: Bool = false
    
    /// 文件
    public var files: [HttpRequestFormFile]?
    /// 传参方式
    public var encoding: ParameterEncoding = URLEncoding.default

    /// 附加参数，用户扩展自定义信息
    public var userInfo: [String: Any] = [:]

    public enum ParamsType {
        case url
        case json
    }

    public init(path: String, method: HTTPMethod = .get, isEncode: Bool = true) {
        self.path = path
        self.method = method
        if !APP.token.isEmpty && isEncode {
            self.headers = ["Authorization": APP.token]
        }
    }
    
    mutating func sign() {
        var params = self.params ?? [:]
        params["random_str"] = "\(Int.random(in: 100000...999999))"
        params["time_stamp"] = Int(Date().timeIntervalSince1970)
        // 签名
        let sortKeys = params.keys.sorted()
        var paramsList = [String]()
        sortKeys.forEach { key in
            paramsList.append("\(key)=\(params[key] ?? "")")
        }
        let signStr = "\(paramsList.joined(separator: "&"))\(privateKey)"
        let makeSign = signStr.md5.lowercased().md5.lowercased()
        params["make_sign"] = makeSign
        self.params = params
    }
}

public struct HttpRequestFormFile {
    var data: Data
    var name: String?
    var fileName: String?
    var mineType: String?

    public init(data: Data, name: String?, fileName: String?, mineType: String?) {
        self.data = data
        self.name = name
        self.fileName = fileName
        self.mineType = mineType
    }
}
