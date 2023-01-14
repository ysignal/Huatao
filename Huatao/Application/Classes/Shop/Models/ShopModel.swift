//
//  ShopModel.swift
//  Huatao
//
//  Created by minse on 2023/1/13.
//

import Foundation

struct ShopCardItem: SSConvertible {
    
    /// 会员卡ID
    var cardId: Int = 0
    
    /// 会员卡名称
    var name: String = ""
    
    /// 会员卡价格
    var money: String = ""
    
}

struct ShopGiftItem: SSConvertible {
    
    /// 礼包ID
    var giftId: Int = 0
    
    /// 礼包名称
    var name: String = ""
    
    /// 礼包价格
    var money: String = ""
    
    /// 礼包会员描述，升级会降低转金豆的费率
    var levelName: String = ""
    
}
