//
//  SSCacheModel.swift
//  Huatao
//
//  Created by minse on 2023/1/16.
//

import FMDB

enum SSTable: String {
    case user = "user"
    
    var key: String {
        switch self {
        case .user:
            return "user_id"
        }
    }
}

protocol CacheModel {
    
    /// 数据库列表，枚举类型，防止出现误差
    func dbTable() -> SSTable
    
    /// 获取数据模型的字典数据
    /// - Returns: 字典数据
    func jsonObject() -> [String: Any]

    /// 从字典中解析当前模型数据并返回一个新的对象
    /// - Parameter json: 数据字典
    /// - Returns: 缓存模型对象
    func seriation(_ json: [String: Any]) -> CacheModel
    
    /// 从字典中解析当前模型数据并加载数据到当前对象
    /// - Parameter json: 数据字典
    /// - Returns: 缓存模型对象
    mutating func loadJson(_ json: [String: Any])
}

extension CacheModel {
    
    /// 将数据库搜索到的数据集合解析成字典
    /// - Returns: 模型数据字典
    func parse(_ resultSet: FMResultSet) -> [String: Any] {
        var json = [String: Any]()
        let property = jsonObject()
        property.forEach { (key: String, value: Any) in
            if let rv = resultSet.string(forColumn: key) {
                json[key] = rv
            }
        }
        return json
    }

    /// 读取当前模型中缓存key对应储存的数值
    /// - Returns: 缓存key对应的值
    func keyValue() -> String {
        let property = jsonObject()
        return property[dbTable().key] as? String ?? ""
    }
}
