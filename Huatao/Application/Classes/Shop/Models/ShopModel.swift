//
//  ShopModel.swift
//  Huatao
//
//  Created on 2023/1/13.
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

struct PayResultModel: SSConvertible {
    
    /// 订单ID
    var partnerId: String = ""
    
    /// 支付ID
    var prepayId: String = ""
    
    /// 固定值
    var package: String = ""
    
    /// 加密字符串
    var nonceStr: String = ""
    
    /// 时间戳
    var timeStamp: String = ""
    
    /// 签名
    var sign: String = ""
    
    /// 支付宝订单
    var alipay: String = ""
}
