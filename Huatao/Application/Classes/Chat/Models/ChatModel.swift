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
    
    /// 备注名
    var remarkName: String = ""
    
    /// 个性签名
    var personSign: String = ""
    
    /// 聊天背景
    var backgroundImg: String = ""
    
    /// 是否星标好友，0-不是，1-是
    var isStar: Int = 0
    
    /// 是否开启免打扰，0-不是，1-是
    var isOpenDisturb: Int = 0
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
    
    //MARK: 本地字段
    
    /// 是否已经加入
    var isJoined: Bool = false
    
    static func from(_ user: TeamUser) -> FriendListItem {
        return FriendListItem(userId: user.userId, initial: user.name.firstLetter(), name: user.name, avatar: user.avatar)
    }
}

struct TeamSettingModel: SSConvertible {
    
    /// 群组ID
    var teamId: Int = 0
    
    /// IM群组ID
    var groupId: String = ""
    
    /// 群名称
    var title: String = ""
    
    /// 群主用户ID
    var userId: Int = 0
    
    /// 当前用户ID
    var currentId: Int = 0
    
    /// 成员数量
    var joinTotal: Int = 0

    /// 群昵称
    var name: String = ""
    
    /// 是否开启免打扰，0-未开启、1-已开启
    var isOpenDisturb: Int = 0
    
    /// 管理员ID
    var managerId: Int = 0
    
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
    
    /// 备注
    var remark: String = ""
    
    static func from(_ user: FriendListItem) -> TeamUser {
        return TeamUser(userId: user.userId, name: user.name, avatar: user.avatar)
    }
    
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
    
    /// 是否展开
    var isOpen: Bool = false
    
}

struct ChildrenChildItem: SSConvertible {
    
    /// 用户ID
    var userId: Int = 0
    
    /// 用户昵称
    var name: String = ""
    
    /// 用户头像
    var avatar: String = ""
    
}


struct RedDetailModel: SSConvertible {
    
    /// 领取到的红包金额
    var money: CGFloat = 0
    
    /// 是否领取到
    var isHaveGet: Int = 0
    
    /// 是否可以领
    var isCanGet: Int = 0
    
    /// 红包ID
    var redId: Int = 0
    
    /// 红包对象
    var redDetail = RedDetailItem()
    
}

struct RedDetailItem: SSConvertible {
    
    /// 描述
    var description: String = ""
    
    /// 红包个数
    var total: Int = 0
    
    /// 红包已领取个数
    var getTotal: Int = 0
    
    /// 红包总金额
    var totalMoney: String = ""
    
    /// 领取用户列表
    var list: [RedUserItem] = []
    
}

struct RedUserItem: SSConvertible {

    /// 用户昵称
    var name: String = ""
    
    /// 用户头像
    var avatar: String = ""
    
    /// 领取金额
    var money: String = ""
    
    /// 领取时间
    var createdAt: String = ""
    
}
