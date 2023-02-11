//
//  SSModel.swift
//  Huatao
//
//  Created on 2023/1/10.
//

import KakaJSON

struct AvatarUrl: SSConvertible {
    
    /// 图片短链接
    var url: String = ""
    
    /// 图片全链接
    var allUrl: String = ""
    
}

/// 有分组需求的数据模型，支持泛型解析
struct ListModel<T: Convertible>: SSConvertible {
    
    /// 数据总数
    var total: Int = 0
    
    /// 数据列表，类型为泛型
    var list: [T] = []
    
}
