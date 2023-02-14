//
//  FileTool.swift
//  Charming
//
//  Created on 2022/11/4.
//

import Foundation
import Alamofire

struct FileTool {
    
    // 文件服务器地址
    static var fileDomain: String {
        return APP.state.uploadUrl
    }
    // 文件服务器头
    static let fileRequestHeader = ["User-Agent":"Mozilla/5.0 (compatible; mobile; ios;android; acs;)"]
    //  结果
    enum fileUploadResultType {
        case error(errorStr: String)
        case success(filePath: AvatarUrl)
    }
    
    // 文件上传
    static func upload(fileData: Data,
                       fileName: String,
                       uploadProgress: ((CGFloat) -> ())? = nil,
                       resultCallBack: @escaping ((fileUploadResultType)->())) {
        guard let fileURL = URL(string: fileDomain) else {
            resultCallBack(fileUploadResultType.error(errorStr: "上传链接错误"))
            return
        }
        AF.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(fileData, withName: "file", fileName: fileName, mimeType: "image/png")
        }, to: fileURL).uploadProgress { (progress) in
            let percent = CGFloat(progress.completedUnitCount)/CGFloat(progress.totalUnitCount)
            uploadProgress?(percent)
        }.responseJSON { (response) in
            if let theResult = response.value as? [String: Any] {
                let avatar = theResult.kj.model(AvatarUrl.self)
                if !avatar.url.isEmpty {
                    resultCallBack(fileUploadResultType.success(filePath: avatar))
                } else {
                    resultCallBack(fileUploadResultType.error(errorStr: "网络错误,上传文件失败"))
                }
            }else{
                resultCallBack(fileUploadResultType.error(errorStr: "网络错误,上传文件失败"))
            }
        }.response { response in
            switch response.result {
            case .success(let data):
                if let jsonData = data, let obj = try? JSONSerialization.jsonObject(with: jsonData) {
                    SS.log(obj)
                }
            case .failure(let error):
                resultCallBack(fileUploadResultType.error(errorStr: error.localizedDescription))
            }
        }
    }
    
    // 文件下载
    static func download(fileUrl: URL,
                         localUrl: URL,
                         downLoadProgress: ((CGFloat)->())? = nil,
                         resultCallBack: @escaping ((fileUploadResultType) -> ())) {
//        AF.download(fileUrl).downloadProgress { (progress) in
//            let percent = CGFloat(progress.completedUnitCount)/CGFloat(progress.totalUnitCount)
//            downLoadProgress?(percent)
//        }.responseData { (response) in
//            guard let theData = response.value else {
//                resultCallBack(fileUploadResultType.error(errorStr: "文件错误"))
//                return
//            }
//            do {
//                try theData.write(to: localUrl)
//                resultCallBack(fileUploadResultType.success(filePath: localUrl.absoluteString))
//            } catch {
//                resultCallBack(fileUploadResultType.error(errorStr: "文件保存本地出错"))
//            }
//        }
    }
}
