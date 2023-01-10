//
//  String+SS.swift
//  SimpleSwift
//
//  Created by user on 2021/4/20.
//

import Foundation
import CommonCrypto

public enum CryptoAlgorithm {
    case md5,
         sha1,
         sha224,
         sha256,
         sha384,
         sha512
    
    var hmacAlgorithm: CCHmacAlgorithm {
        switch self {
        case .md5:
            return CCHmacAlgorithm(kCCHmacAlgMD5)
        case .sha1:
            return CCHmacAlgorithm(kCCHmacAlgSHA1)
        case .sha224:
            return CCHmacAlgorithm(kCCHmacAlgSHA224)
        case .sha256:
            return CCHmacAlgorithm(kCCHmacAlgSHA256)
        case .sha384:
            return CCHmacAlgorithm(kCCHmacAlgSHA384)
        case .sha512:
            return CCHmacAlgorithm(kCCHmacAlgSHA512)
        }
    }
    
    var digestLength: Int32 {
        switch self {
        case .md5:
            return CC_MD5_DIGEST_LENGTH
        case .sha1:
            return CC_SHA1_DIGEST_LENGTH
        case .sha224:
            return CC_SHA224_DIGEST_LENGTH
        case .sha256:
            return CC_SHA256_DIGEST_LENGTH
        case .sha384:
            return CC_SHA384_DIGEST_LENGTH
        case .sha512:
            return CC_SHA512_DIGEST_LENGTH
        }
    }
}

public extension String {
    /// base64 解码
    var base64Decoded: String? {
        let remainder = count % 4
        let padding = remainder > 0 ? String(repeating: "=", count: 4 - remainder) : ""
        guard let data = Data(base64Encoded: self + padding, options: .ignoreUnknownCharacters) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    /// base64 编码
    var base64Encoded: String? {
        return data(using: .utf8)?.base64EncodedString()
    }
    
    /// md5
    var md5: String {
        return crypto(algorithm: .md5)
    }
    
    /// sha1
    var sha1: String {
        return crypto(algorithm: .sha1)
    }
    
    /// sha224
    var sha224: String {
        return crypto(algorithm: .sha224)
    }
    
    /// sha256
    var sha256: String {
        return crypto(algorithm: .sha256)
    }
    
    /// sha384
    var sha384: String {
        return crypto(algorithm: .sha384)
    }
    
    /// sha512
    var sha512: String {
        return crypto(algorithm: .sha512)
    }
    
    private func crypto(algorithm: CryptoAlgorithm) -> String {
        guard let data = self.data(using: .utf8) else { return "" }
        let digestLen = algorithm.digestLength
        let result = data.withUnsafeBytes { (bytes) -> [UInt8] in
            var h = [UInt8](repeating: 0, count: Int(digestLen))
            switch algorithm {
            case .md5:
                if #available(iOS 13.0, *) {
                    // iOS 13.0以后会弃用该api，不推荐使用md5
                } else {
                    CC_MD5(bytes.baseAddress, CC_LONG(data.count), &h)
                }
            case .sha1:
                CC_SHA1(bytes.baseAddress, CC_LONG(data.count), &h)
            case .sha224:
                CC_SHA224(bytes.baseAddress, CC_LONG(data.count), &h)
            case .sha256:
                CC_SHA256(bytes.baseAddress, CC_LONG(data.count), &h)
            case .sha384:
                CC_SHA384(bytes.baseAddress, CC_LONG(data.count), &h)
            case .sha512:
                CC_SHA512(bytes.baseAddress, CC_LONG(data.count), &h)
            }
            return h
        }
        return result.map({ String(format: "%02X", $0) }).joined()
    }
}
