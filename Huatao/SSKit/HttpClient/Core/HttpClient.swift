//
//  HttpClient.swift
//  SimpleSwift
//
//  Created by user on 2021/4/21.
//

import Foundation
import Alamofire

public struct HttpClient {
    public private(set) var baseURL: String?
    public private(set) var plugins: [PluginType] = []

    public init(baseURL: String? = nil, plugins: [PluginType] = []) {
        self.baseURL = baseURL
        self.plugins = plugins
        URLSessionConfiguration.af.default.timeoutIntervalForRequest = 10
    }

    public func request(_ req: HttpRequest, success: @escaping (_ response: HttpResponse) -> Void, failure: @escaping (_ error: Error) -> Void) {
        var newReq = req
        if newReq.isSign {
            newReq.sign()
        }
        plugins.forEach { newReq = $0.prepare(newReq) }
        let url = generateURL(newReq)
        newReq.fullPath = url.absoluteString
        plugins.forEach { $0.willSend(newReq) }
        
        AF.request(url, method: newReq.method, parameters: newReq.params, encoding: newReq.encoding, headers: HTTPHeaders(newReq.headers)).responseData { response in
            var httpRes = HttpResponse()
            httpRes.statusCode = response.response?.statusCode ?? 0
            switch response.result {
            case let .success(data):
                self.decodeResponseData(data, req: newReq, res: httpRes, success: success, failure: failure)
            case let .failure(error):
                self.requestError(error, req: newReq, res: httpRes, failure: failure)
            }
        }
    }

    public func upload(_ req: HttpRequest, progress: ((_ progress: Progress) -> Void)? = nil, success: @escaping (_ response: HttpResponse) -> Void, failure: @escaping (_ error: Error) -> Void) {
        guard let files = req.files else {
            print("files不能为空")
            return
        }
        var newReq = req
        plugins.forEach { newReq = $0.prepare(newReq) }
        let url = generateURL(newReq)
        newReq.fullPath = url.absoluteString
        plugins.forEach { $0.willSend(newReq) }
        AF.upload(multipartFormData: {
            if let params = newReq.params {
                for (key, value) in params {
                    if let data = String(describing: value).data(using: .utf8) {
                        $0.append(data, withName: key)
                    }
                }
            }
            for file in files {
                $0.append(file.data, withName: file.name ?? "", fileName: file.fileName ?? "", mimeType: file.mineType ?? "")
            }
        }, to: url, headers: HTTPHeaders(newReq.headers))
            .uploadProgress {
                progress?($0)
            }
            .responseData { response in
                let httpRes = HttpResponse()
                switch response.result {
                case let .success(data):
                    self.decodeResponseData(data, req: newReq, res: httpRes, success: success, failure: failure)
                case let .failure(error):
                    self.requestError(error, req: newReq, res: httpRes, failure: failure)
                }
            }
    }

    private func generateURL(_ req: HttpRequest) -> URL {
        if req.path.hasPrefix("http") {
            // 如果请求链接是完整链接，直接返回不用拼接
            return URL(string: req.path)!
        }
        var urlString = baseURL ?? ""
        var path = req.path
        if urlString.last == "/" { urlString.removeLast() }
        if path.first == "/" { path.removeFirst() }
        urlString += "/" + path
        return URL(string: urlString)!
    }

    /// 解析响应数据
    private func decodeResponseData(_ data: Data, req: HttpRequest, res: HttpResponse, success: @escaping (_ response: HttpResponse) -> Void, failure: @escaping (_ error: Error) -> Void) {
        var newHttpRes = res
        newHttpRes.data = data
        newHttpRes.json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
        plugins.forEach { newHttpRes = $0.didReceive(req, response: newHttpRes) }
        if newHttpRes.error != nil {
            failure(newHttpRes.error!)
            return
        }
        success(newHttpRes)
    }

    /// 处理请求出错
    private func requestError(_ error: Error, req: HttpRequest, res: HttpResponse, failure: @escaping (_ error: Error) -> Void) {
        var newHttpRes = res
        newHttpRes.error = error
        plugins.forEach { newHttpRes = $0.didReceive(req, response: newHttpRes) }
        failure(error)
    }
    
    
}
