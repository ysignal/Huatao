//
//  IMGroupUserInfo.swift
//  Huatao
//
//  Created on 2023/2/23.
//  
	

import Foundation

struct IMGroupUserInfo: CacheModel, SSConvertible {
    
    /// 表内唯一标识，是群组ID和用户ID的组合，如`groupId_userId`
    var tableId: String = ""
    
    /// 群主ID
    var teamId: Int = 0

    /// 用户ID
    var userId: Int = 0
    
    /// 昵称
    var name: String = ""

    /// 头像
    var avatar: String = ""

    /// 群内昵称
    var remark: String = ""

    /// 更新日期，隔日可更新缓存
    var updated: String = ""
    
    static func from(_ model: TeamUser, teamId: Int) -> IMGroupUserInfo {
        return IMGroupUserInfo(tableId: "\(teamId)_\(model.userId)",
                               teamId: teamId,
                               userId: model.userId,
                               name: model.name,
                               avatar: model.avatar,
                               remark: model.remark)
    }
    
    //MARK: CacheModel Protocal
    
    func dbTable() -> SSTable {
        return .groupUser
    }
    
    func jsonObject() -> [String : Any] {
        return kj.JSONObject()
    }
    
    func seriation(_ json: [String : Any]) -> CacheModel {
        return json.kj.model(IMGroupUserInfo.self)
    }
    
    mutating func loadJson(_ json: [String : Any]) {
        kj_m.convert(from: json)
    }
    
}
