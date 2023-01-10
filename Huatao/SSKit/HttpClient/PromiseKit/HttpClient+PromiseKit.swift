//
//  HttpClient+PromiseKit.swift
//  SimpleSwift
//
//  Created by user on 2021/4/21.
//

import Foundation
import PromiseKit

public extension HttpClient {
    func request(_ req: HttpRequest) -> Promise<HttpResponse> {
        return Promise<HttpResponse> { seal in
            self.request(req, success: { response in
                seal.fulfill(response)
            }, failure: { error in
                seal.reject(error)
            })
        }
    }
    
    func upload(_ req: HttpRequest, uploadProgress: ((Float) -> ())? = nil) -> Promise<HttpResponse> {
        return Promise<HttpResponse> { seal in
            self.upload(req, progress: { progress in
                let pro = Float(progress.completedUnitCount)/Float(progress.totalUnitCount)
                uploadProgress?(pro)
            }, success: { response in
                seal.fulfill(response)
            }, failure: { error in
                seal.reject(error)
            })
        }
    }
}
