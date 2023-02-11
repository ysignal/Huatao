//
//  SSConvertible.swift
//  Huatao
//
//  Created on 2023/1/10.
//

import KakaJSON

/// 自定义协议遵从`KakaJSON`的`Convertible`协议，避免定义数据结构的每个页面都要引用
public protocol SSConvertible: Convertible {}

/// 定义swift驼峰式属性名和Json数据字段之间的映射
extension SSConvertible {
    /// 属性名映射, 这个key是从JSON数据源中读取的字段Key
    /// - Parameter property: 结构体属性
    /// - Returns: 属性映射到数据的Key
    public func kj_modelKey(from property: Property) -> ModelPropertyKey {
        // 将驼峰式属性名转换为下划线式属性名
        return property.name.kj.underlineCased()
    }
    
    /// 属性名映射
    /// - Parameter property: 结构体属性
    /// - Returns: 属性映射到数据的Key
    public func kj_JSONKey(from property: Property) -> JSONPropertyKey {
        // 将驼峰式属性名转换为下划线式属性名
        return property.name.kj.underlineCased()
    }
}
