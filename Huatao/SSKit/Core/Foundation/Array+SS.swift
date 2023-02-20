//
//  Array+SS.swift
//  Huatao
//
//  Created on 2023/2/18.
//  
	

import Foundation

extension Array where Element: Equatable {
    
    /// 数组去重
    /// - Returns: 返回去重后的数组
    func uniqued() -> [Element] {
        var result = [Element]()
        for ele in self {
            if !self.contains(where: { $0 == ele }) {
                result.append(ele)
            }
        }
        return result
    }
}

