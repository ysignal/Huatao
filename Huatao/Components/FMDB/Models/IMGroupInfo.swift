//
//  IMGroupInfo.swift
//  Huatao
//
//  Created on 2023/2/23.
//  
	

import Foundation

struct IMGroupInfo: CacheModel, SSConvertible {

    /// 群主ID
    var teamId: Int = 0
    
    /// IM群组ID，已废弃，使用teamId
    var groupId: String = ""
    
    /// 群名称
    var title: String = ""
    
    /// 用户ID
    var userId: Int = 0
    
    /// 群内昵称
    var name: String = ""
    
    /// 群组成员个数
    var joinTotal: Int = 0

    /// 用户头像图片数组拼接
    var images: String = ""

    /// 管理员ID，字符串存储，后续兼容多个管理员
    var managerId: String = ""
    
    /// 是否开启免打扰
    var isOpenDisturb: Int = 0
    
    /// 更新日期，隔日可更新缓存
    var updated: String = ""
    
    static func from(_ model: TeamSettingModel) -> IMGroupInfo {
        let images = model.listAvatar.compactMap({ $0.avatar }).joined(separator: ",")
        return IMGroupInfo(teamId: model.teamId,
                           groupId: model.groupId,
                           title: model.title,
                           userId: model.userId,
                           name: model.name,
                           joinTotal: model.joinTotal,
                           images: images,
                           managerId: "\(model.managerId)",
                           isOpenDisturb: model.isOpenDisturb)
    }
    
    //MARK: CacheModel Protocal
    
    func dbTable() -> SSTable {
        return .group
    }
    
    func jsonObject() -> [String : Any] {
        return kj.JSONObject()
    }
    
    func seriation(_ json: [String : Any]) -> CacheModel {
        return json.kj.model(IMGroupInfo.self)
    }
    
    mutating func loadJson(_ json: [String : Any]) {
        kj_m.convert(from: json)
    }
    
}
