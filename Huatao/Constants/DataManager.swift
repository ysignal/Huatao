//
//  DataManager.swift
//  Charming
//
//  Created by minse on 2022/11/3.
//

import Foundation

struct DataManager {
    
    static var cacheVideoImage: [String: UIImage] = [:]
    
    static var randomTotal: Int = Int.random(in: 10000...9999999)
    static var randomRelease: Int = Int.random(in: 1000...randomTotal)
    
    static var vipList: [String] = ["普通会员","铜牌会员","银牌会员","金牌会员","一星会员","二星会员"]
    
}
