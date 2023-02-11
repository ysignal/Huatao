//
//  MineModel.swift
//  Huatao
//
//  Created on 2023/1/15.
//

import Foundation

struct MineModel {
    
    static var menuList = [MineMenuItem(action: "team", icon: "ic_mine_tab_01", title: "我的团队"),
                           MineMenuItem(action: "trade", icon: "ic_mine_tab_02", title: "交易大厅"),
                           MineMenuItem(action: "wallet", icon: "ic_mine_tab_03", title: "我的钱包"),
                           MineMenuItem(action: "promotion", icon: "ic_mine_tab_04", title: "我要推广"),
                           MineMenuItem(action: "circle", icon: "ic_mine_tab_05", title: "我的朋友圈"),
                           MineMenuItem(action: "password", icon: "ic_mine_tab_06", title: "支付密码"),
                           MineMenuItem(action: "history", icon: "ic_mine_tab_07", title: "购买记录"),
                           MineMenuItem(action: "car", icon: "ic_mine_tab_08", title: "购物车"),
                           MineMenuItem(action: "delegate", icon: "ic_mine_tab_09", title: "成为代理商"),
                           MineMenuItem(action: "service", icon: "ic_mine_tab_10", title: "联系客服"),
                           MineMenuItem(action: "task", icon: "ic_mine_tab_11", title: "任务提醒"),
                           MineMenuItem(action: "card", icon: "ic_mine_tab_12", title: "卡包"),
                           MineMenuItem(action: "pay", icon: "ic_mine_tab_13", title: "公益基金"),
                           MineMenuItem(action: "setting", icon: "ic_mine_tab_14", title: "设置"),
                           MineMenuItem(action: "vipbag", icon: "ic_mine_tab_15", title: "会员礼包"),
                           MineMenuItem(action: "tovip", icon: "ic_mine_tab_16", title: "成为会员")]
    
}

struct MineMenuItem {
    
    /// 菜单事件
    var action: String = ""
    
    /// 菜单图标
    var icon: String = ""
    
    /// 菜单标题
    var title: String = ""
    
}

struct MineTeamListModel: SSConvertible {
    
    /// 分页数据总数
    var total: Int = 0
    
    /// 直推总数
    var promoteNum: Int = 0
    
    /// 间推总数
    var nextNum: Int = 0
    
    /// 推荐人数列表
    var list: [MineTeamListItem] = []
    
}

struct MineUserInfo: SSConvertible {
    
    /// 菜单事件
    var avatar: String = ""
    
    /// 菜单图标
    var name: String = ""
    
    /// 菜单标题
    var mobile: String = ""
    
    /// 会员级别
    var levelName: String = ""
    
}

struct MineTeamListItem: SSConvertible {
    
    /// 用户ID
    var userId: Int = 0
    
    /// 用户头像
    var avatar: String = ""
    
    /// 用户昵称
    var name: String = ""
    
    /// 手机号
    var mobile: String = ""
    
    /// 实名审核状态，1-通过、2-待审核、3-拒绝
    var cardStatus: Int = 0
    
    /// 进入任务是否完成，0-未完成，1-已完成
    var isTodayTask: Int = 0
    
    /// 消费总额
    var consumMoney: String = ""
    
    /// 注册人数
    var registerTotal: Int = 0
    
    /// 认证人数
    var authTotal: Int = 0
    
    /// 注册时间
    var createdAt: String = ""
    
}

struct TradeHallModel: SSConvertible {
    
    /// 可卖总数
    var canSaleTotal: Int = 0
    
    /// 可买总数
    var canBuyTotal: Int = 0
    
    /// 销毁总数
    var destructeTotal: Int = 0
    
    /// 金豆价格
    var startPrice: String = ""
    
}

struct TradeHallLineItem: SSConvertible {
    
    /// 时间
    var time: String = ""
    
    /// 金豆价格
    var startPrice: String = ""
    
}

struct TradeBuyListItem: SSConvertible {
    
    /// 购买订单ID
    var buyId: Int = 0
    
    /// 交易量
    var total: Int = 0
    
    /// 订单状态
    var status: Int = 0
    
    /// 订单创建时间
    var createdAt: String = ""
    
}

struct TradeSaleListItem: SSConvertible {
    
    /// 售出订单ID
    var saleId: Int = 0
    
    /// 交易量
    var total: Int = 0
    
    /// 订单状态 0-待处理, 1-完成
    var status: Int = 0
    
    /// 订单创建时间
    var createdAt: String = ""
    
    /// 购买记录列表
    var buyList: [TradeSaleBuyItem] = []
}

struct TradeSaleBuyItem: SSConvertible {
    
    /// 购买订单ID
    var buyId: Int = 0
    
    /// 交易量
    var total: Int = 0
    
    /// 支付金额
    var money: String = ""
    
    /// 交易状态 0-待匹配, 1-完成, 2-待确认, 3-待上传, 4-拒绝
    var status: Int = 0
    
    /// 支付凭证
    var uploadImage: String = ""
    
    /// 出价金额
    var price: String = ""

}

struct TradeUploadModel: SSConvertible {
    
    /// 交易凭证
    var tradeImage: String = ""
    
    /// 交易方式
    var tradeType: Int = 0
    
    /// 姓名
    var name: String = ""
    
    /// 卡号
    var card: String = ""
    
    /// 开户行
    var bankAddress: String = ""
    
    /// 付款金额
    var money: String = ""
    
}

struct UpgradeRuleModel: SSConvertible {
    
    /// 当前等级名称
    var currentLevel: String = ""
    
    /// 升级等级名称
    var nextLevel: String = ""
    
    /// 我的A区业绩
    var myAPerformance: String = ""
    
    /// 升级所需A区业绩
    var needAPerformance: String = ""
    
    /// 我的B区业绩
    var myBPerformance: String = ""
    
    /// 升级所需B区业绩
    var needBPerformance: String = ""
    
    /// 活跃点
    var activeNum: Int = 0
    
    /// 升级所需活跃点
    var needActiveNum: Int = 0
    
    /// 是否购买了卡包 0未购买，1已购买
    var isHaveCard: Int = 0
    
    /// 是否最大等级 0不是，1是
    var isBiggestLevel: Int = 0
    
    /// 持有卡包名称
    var haveCardName: String = ""
    
    /// 赠送卡包名称
    var giveCardName: String = ""
    
    /// 提示
    var remark: String = ""
    
}

struct MyBagModel: SSConvertible {
    
    /// 余额
    var money: String = ""
    
    /// 银豆数量
    var silverBean: String = ""
    
    /// 金豆数量
    var goldBean: String = ""
    
    /// 贡献值
    var contributionValue: String = ""
    
}

struct WalletRecordItem: SSConvertible {
    
    /// 记录ID
    var recordId: Int = 0
    
    /// 类型，0-支出，1-收入
    var type: Int = 0
    
    /// 描述
    var desc: String = ""
    
    /// 金额
    var money: String = ""
    
    /// 创建时间
    var createdAt: String = ""
    
}

struct ConversionGoldModel: SSConvertible {
    
    /// 兑换数列表
    var moneyList: [Int] = []
    
    /// 费率
    var rate: String = ""
    
    /// 会员名称
    var name: String = ""
    
}
