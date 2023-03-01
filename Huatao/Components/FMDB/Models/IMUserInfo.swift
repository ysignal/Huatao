//
//  IMUserInfo.swift
//  Huatao
//
//  Created on 2023/2/22.
//  
	

import Foundation

struct IMUserInfo: CacheModel, SSConvertible {
    
    /// 用户ID
    var userId: Int = 0
    
    /// 昵称
    var name: String = ""
    
    /// 头像
    var avatar: String = ""
    
    /// 聊天背景图
    var backgroundImage: String = ""
    
    /// 图片数组
    var images: String = ""
    
    /// 好友备注
    var remark: String = ""
    
    /// 是否好友
    var isFriend: Int = 0
    
    /// 是否星标用户
    var isStar: Int = 0
    
    /// 是否开启免打扰
    var isOpenDisturb: Int = 0
    
    /// 更新日期，隔日可更新缓存
    var updated: String = ""
    
    static func from(_ model: FriendDetailModel) -> IMUserInfo {
        return IMUserInfo(userId: model.userId,
                          name: model.name,
                          avatar: model.avatar,
                          backgroundImage: model.backgroundImg,
                          images: model.images.joined(separator: ","),
                          remark: model.remarkName,
                          isFriend: model.isFriend,
                          isStar: model.isStar,
                          isOpenDisturb: model.isOpenDisturb)
    }
    
    //MARK: CacheModel Protocal
    
    func dbTable() -> SSTable {
        return .user
    }
    
    func jsonObject() -> [String : Any] {
        return kj.JSONObject()
    }
    
    func seriation(_ json: [String : Any]) -> CacheModel {
        return json.kj.model(IMUserInfo.self)
    }
    
    mutating func loadJson(_ json: [String : Any]) {
        kj_m.convert(from: json)
    }
    
}
