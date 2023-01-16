//
//  MineModel.swift
//  Huatao
//
//  Created by minse on 2023/1/15.
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
                           MineMenuItem(action: "setting", icon: "ic_mine_tab_14", title: "设置")]
    
}

struct MineMenuItem {
    
    /// 菜单事件
    var action: String = ""
    
    /// 菜单图标
    var icon: String = ""
    
    /// 菜单标题
    var title: String = ""
    
}
