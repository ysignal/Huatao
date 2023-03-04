//
//  HTRedMessage.swift
//  Huatao
//
//  Created on 2023/3/2.
//  
	

import Foundation

struct RCRedModel: SSConvertible {
    
    /// 红包发送者昵称
    var name: String = ""
    
    /// 红包发送者头像
    var avatar: String = ""
    
    /// 红包ID
    var redid: Int = 0
    
    /// 红包描述
    var message: String = ""
    
    /// 红包类型
    var type: Int = 0
    
    /// 红包总金额
    var money: String = ""
    
}

class HTRedMessage: RCMessageContent {
    
    var model: RCRedModel?
    
    /// 必须实现一个不带参数的初始化方法
    override init() {
        
    }
    
    /// 带参数初始化
    /// - Parameters:
    ///   - name: 红包发送者昵称
    ///   - avatar: 红包发送者头像
    ///   - redid: 红包ID
    ///   - message: 红包描述
    ///   - type: 红包类型
    ///   - money: 红包总金额
    init(name: String, avatar: String, redid: Int, message: String, type: Int, money: String) {
        model = RCRedModel(name: name, avatar: avatar, redid: redid, message: message, type: type, money: money)
    }
    
    /// 必须实现的一个数据编码方法
    override func encode() -> Data? {
        return model?.kj.JSONObject().toData()
    }
    
    /// 必须实现的一个数据解码方法
    override func decode(with data: Data) {
        model = data.kj.model(RCRedModel.self)
    }
    
    /// 提供消息类目，Swift类会带项目名称前缀，需要用代码去除或者直接返回固定的类名
    /// - Returns: 类名字符串
    override class func getObjectName() -> String {
        return "HTRedMessage"
    }
    
    /// 自定义消息搜索关键字
    /// - Returns: 关键字列表
    override func getSearchableWords() -> [String]? {
        return nil
    }
    
    /// 返回消息存储类型
    /// - Returns: 支持离线，存入历史消息
    override class func persistentFlag() -> RCMessagePersistent {
        return .MessagePersistent_ISCOUNTED
    }
    
    /// 内容摘要，在本地会话列表和本地通知中显示
    /// - Returns: 内容摘要
    override func conversationDigest() -> String? {
        return "[红包]"
    }
    
}
