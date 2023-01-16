//
//  FindModel.swift
//  Huatao
//
//  Created by minse on 2023/1/15.
//

import Foundation

struct DynamicListItem: SSConvertible {
    
    /// 动态ID
    var dynamicId: Int = 0
    
    /// 用户ID
    var userId: Int = 0
    
    /// 用户头像
    var avatar: String = ""
    
    /// 用户昵称
    var name: String = ""
    
    /// 动态类型，0-图片，1-视频
    var type: Int = 0
    
    /// 动态内容
    var content: String = ""
    
    /// 动态图片数组
    var images: [String] = []
    
    /// 动态视频
    var video: String = ""
    
    /// 点赞数
    var likeCount: Int = 0
    
    /// 是否点赞
    var isLike: Int = 0
    
    /// 评论数
    var commentCount: Int = 0
    
    /// 评论列表
    var commentArray: [CommentListItem] = []
    
    /// 点赞列表
    var likeArray: [LikeListItem] = []
    
    /// 发布时间
    var createdAt: String = ""
    
}

struct DynamicDetailModel: SSConvertible {
    
    /// 动态ID
    var dynamicId: Int = 0
    
    /// 动态内容
    var content: String = ""
    
    /// 动态发送者信息
    var userinfo = DynamicSendUser()
    
    /// 动态类型，0-图片，1-视频
    var type: Int = 0
    
    /// 动态图片数组
    var images: [String] = []
    
    /// 动态视频
    var video: String = ""
    
    /// 点赞数
    var likeCount: Int = 0
    
    /// 评论列表
    var commentArray: [CommentListItem] = []
    
    /// 点赞列表
    var likeArray: [LikeListItem] = []
    
    /// 评论数
    var dynamicCommentCount: Int = 0
    
    /// 发布时间
    var createdAt: String = ""
    
}

struct DynamicSendUser: SSConvertible {
    
    /// 用户ID
    var userId: Int = 0
    
    /// 用户昵称
    var name: String = ""
    
    /// 用户头像
    var avatar: String = ""
}

struct CommentListItem: SSConvertible {
    
    /// 发送者昵称
    var sendUser: String = ""
    
    /// 发送者ID
    var sendUserId: Int = 0
    
    /// 发送者头像
    var sendUserAvatar: String = ""
    
    /// 接受者昵称
    var receiveUser: String = ""
    
    /// 接受者ID
    var receiveUserId: Int = 0
    
    /// 接受者头像
    var receiveUserAvater: String = ""
    
    /// 评论内容
    var content: String = ""
    
    /// 评论ID
    var commentId: Int = 0
    
    /// 是否顶级评论，0-评论贴主，1-评论指定用户
    var topPid: Int = 0
    
    /// 创建时间
    var createdAt: String = ""
    
    /// 是否点赞
    var isLike: Int = 0
    
    /// 点赞数
    var likeTotal: Int = 0
    
    /// 评论楼内楼
    var children: [CommentChildrenItem] = []

}

struct CommentChildrenItem: SSConvertible {
    
    /// 发送者昵称
    var sendUser: String = ""
    
    /// 发送者ID
    var sendUserId: Int = 0
    
    /// 发送者头像
    var sendUserAvatar: String = ""
    
    /// 接受者昵称
    var receiveUser: String = ""
    
    /// 接受者ID
    var receiveUserId: Int = 0
    
    /// 接受者头像
    var receiveUserAvater: String = ""
    
    /// 评论内容
    var content: String = ""
    
    /// 评论ID
    var commentId: Int = 0
    
    /// 是否顶级评论，0-评论贴主，1-评论指定用户
    var topPid: Int = 0
    
    /// 评论时间
    var createdAt: String = ""
    
    /// 是否点赞
    var isLike: Int = 0
    
    /// 点赞数
    var likeTotal: Int = 0
    
}

struct LikeListItem: SSConvertible {
    
    /// 用户昵称
    var userName: String = ""
    
    /// 用户头像
    var userAvatar: String = ""
    
    /// 点赞时间
    var createAt: String = ""
    
}

struct InteractMessageListItem: SSConvertible {
    
    /// 消息ID
    var messageId: Int = 0
    
    /// 通知类型，1-评论通知，2-消息通知
    var type: Int = 0
    
    /// 用户昵称
    var sendUserName: String = ""
    
    /// 用户头像
    var sendUserAvatar: String = ""
    
    /// 动态ID
    var dynamicId: Int = 0
    
    /// 创建时间
    var createAt: String = ""
    
}

struct DynamicRedNoticeModel: SSConvertible {
    
    /// 新通知数量
    var total: Int = 0
    
}
