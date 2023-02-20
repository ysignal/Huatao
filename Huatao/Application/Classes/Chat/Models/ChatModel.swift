//
//  ChatModel.swift
//  Huatao
//
//  Created on 2023/1/16.
//

import Foundation

struct ChatModel {
    

    
}

struct ChatSectionItem {
    
    var icon: String = ""
    
    var title: String = ""
    
    var badge: Int = 0
    
}

struct FriendDetailModel: SSConvertible {
    
    /// 用户ID
    var userId: Int = 0
    
    /// 昵称
    var name: String = ""
    
    /// 头像
    var avatar: String = ""
    
    /// 朋友圈图片
    var images: [String] = []
    
    /// 是否是好友，0-不是，1-是
    var isFriend: Int = 0
    
}

struct NoticeFriendListModel: SSConvertible {
    
    /// 数据总数
    var total: Int = 0
    
    /// 待处理总数
    var waitTotal: Int = 0
    
    /// 列表
    var list: [NoticeFriendListItem] = []
    
}

class NoticeFriendListItem: SSConvertible {
    
    /// 通知ID
    var noticeId: Int = 0
    
    /// 名称
    var name: String = ""
    
    /// 头像
    var avatar: String = ""
    
    /// 状态，0-待处理、1-已同意、2-已拒绝
    var status: Int = 0
    
    /// 请求时间
    var createdAt: String = ""
    
    /// 申请描述
    var desc: String = ""
    
    /// 类型，0-我加别人，别人加我
    var type: Int = 0
    
    /// 是否展开
    var isOpen: Bool = false
    
    required init() {
        
    }
    
}

struct FriendListItem: SSConvertible {
    
    /// 用户ID
    var userId: Int = 0
    
    /// 首字母
    var initial: String = ""
    
    /// 用户昵称
    var name: String = ""
    
    /// 用户头像
    var avatar: String = ""
    
}

struct TeamSettingModel: SSConvertible {
    
    /// 群组ID
    var teamId: Int = 0
    
    /// IM群组ID
    var groupId: Int = 0
    
    /// 群名称
    var title: String = ""
    
    /// 群主用户ID
    var userId: Int = 0
    
    /// 当前用户ID
    var currentId: Int = 0
    
    /// 成员数量
    var joinTotal: Int = 0
    
    /// 群主昵称
    var name: String = ""
    
    /// 是否开启免打扰，0-未开启、1-已开启
    var isOpenDisturb: Int = 0
    
    /// 群组用户列表
    var listAvatar: [TeamUser] = []
    
}

struct TeamUser: SSConvertible {
    
    /// 用户ID
    var userId: Int = 0
    
    /// 用户昵称
    var name: String = ""
    
    /// 用户头像
    var avatar: String = ""
    
}

struct TeamListItem: SSConvertible {
    
    /// 群组ID
    var teamId: Int = 0
    
    /// IM群组ID
    var groupId: Int = 0
    
    /// 群名称
    var title: String = ""
    
    /// 成员数量
    var joinTotal: Int = 0
    
    /// 群组用户列表
    var listAvatar: [TeamUser] = []
    
}


struct ChildrenListItem: SSConvertible {
    
    /// 用户ID
    var userId: Int = 0
    
    /// 用户昵称
    var name: String = ""
    
    /// 用户头像
    var avatar: String = ""
    
    /// 下级列表
    var children: [ChildrenChildItem] = []
    
    /// 下级数量
    var count: Int = 0
    
}

struct ChildrenChildItem: SSConvertible {
    
    /// 用户ID
    var userId: Int = 0
    
    /// 用户昵称
    var name: String = ""
    
    /// 用户头像
    var avatar: String = ""
    
}
