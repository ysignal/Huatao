//
//  LoginModel.swift
//  Huatao
//
//  Created by minse on 2023/1/13.
//

import Foundation

// MARK: 登录返回的数据模型
struct LoginData: SSConvertible {
    /// token
    var accessToken: String = ""
    
    /// 类型
    var tokenType: String = ""
    
    /// 过期时间
    var expiresIn: Int = 0
    
    /// 用户ID
    var userId: Int = 0
    
    /// 是否完善信息，0未完善，1已完善
    var isComplete: Int = 0
    
    /// 融云IMToken
    var imToken: String = ""
}

// MARK: 用户详情
struct UserInfo: SSConvertible {
    
    /// 用户ID
    var userId: Int = 0
    
    /// 手机号
    var mobile: String = ""
    
    /// 用户名
    var name: String = ""
    
    /// 头像
    var avatar: String = ""
    
    /// 性别
    var sex: Int = 0
    
    /// 类型
    var type: Int = 0
    
}
