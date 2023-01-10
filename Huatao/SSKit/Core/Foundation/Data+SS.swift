//
//  Data+SS.swift
//  SimpleSwift
//
//  Created by user on 2021/4/20.
//

import Foundation

// MARK: Properties
public extension Data {
    /// 转成bytes
    var bytes: [UInt8] {
        return [UInt8](self)
    }
}

// MARK: Methods
public extension Data {

    /// sting转Data
    ///
    /// - Parameter encoding: encoding.
    /// - Returns: String by encoding Data using the given encoding (if applicable).
    func string(encoding: String.Encoding) -> String? {
        return String(data: self, encoding: encoding)
    }

    /// 从给定的JSON数据返回一个基础对象。
    ///
    /// - Parameter options: Options for reading the JSON data and creating the Foundation object.
    ///
    ///   For possible values, see `JSONSerialization.ReadingOptions`.
    /// - Returns: A Foundation object from the JSON data in the receiver, or `nil` if an error occurs.
    /// - Throws: An `NSError` if the receiver does not represent a valid JSON object.
    func jsonObject(options: JSONSerialization.ReadingOptions = []) throws -> Any {
        return try JSONSerialization.jsonObject(with: self, options: options)
    }

}

public extension Data {

    // Inspired by: https://stackoverflow.com/a/38024025/2115352

    /// Converts the required number of bytes, starting from `offset`
    /// to the value of return type.
    ///
    /// - parameter offset: The offset from where the bytes are to be read.
    /// - returns: The value of type of the return type.
    func read<R: FixedWidthInteger>(fromOffset offset: Int = 0) -> R {
        let length = MemoryLayout<R>.size
        
        #if swift(>=5.0)
        return subdata(in: offset ..< offset + length).withUnsafeBytes { $0.load(as: R.self) }
        #else
        return subdata(in: offset ..< offset + length).withUnsafeBytes { $0.pointee }
        #endif
    }
    
    func readBigEndian<R: FixedWidthInteger>(fromOffset offset: Int = 0) -> R {
        let r: R = read(fromOffset: offset)
        return r.bigEndian
    }
}

// Source: http://stackoverflow.com/a/42241894/2115352

protocol DataConvertible {
    static func + (lhs: Data, rhs: Self) -> Data
    static func += (lhs: inout Data, rhs: Self)
}

extension DataConvertible {
    
    static func + (lhs: Data, rhs: Self) -> Data {
        var value = rhs
        let data = withUnsafePointer(to: &value) { pointer -> Data in
            return Data(buffer: UnsafeBufferPointer(start: pointer, count: 1))
        }
        return lhs + data
    }
    
    static func += (lhs: inout Data, rhs: Self) {
        lhs = lhs + rhs
    }
    
}

extension UInt8  : DataConvertible { }
extension UInt16 : DataConvertible { }
extension UInt32 : DataConvertible { }
extension Int8   : DataConvertible { }
extension Int16  : DataConvertible { }
extension Int32  : DataConvertible { }

extension Int    : DataConvertible { }
extension UInt   : DataConvertible { }
extension Float  : DataConvertible { }
extension Double : DataConvertible { }

extension String : DataConvertible {
    
    static func + (lhs: Data, rhs: String) -> Data {
        guard let data = rhs.data(using: .utf8) else { return lhs }
        return lhs + data
    }
    
}

extension Data : DataConvertible {
    
    static func + (lhs: Data, rhs: Data) -> Data {
        var data = Data()
        data.append(lhs)
        data.append(rhs)
        
        return data
    }
    
    static func + (lhs: Data, rhs: Data?) -> Data {
        guard let rhs = rhs else {
            return lhs
        }
        var data = Data()
        data.append(lhs)
        data.append(rhs)
        
        return data
    }
    
}
