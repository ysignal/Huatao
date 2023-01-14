//
//  HttpApi.swift
//  SimpleSwift
//
//  Created by user on 2021/4/22.
//

import Foundation
import PromiseKit
import Alamofire

struct HttpApi {}

// MARK: - 文件处理接口
extension HttpApi {
    struct File {
        static func uploadImage(data: Data, fileName: String, mineType: String = "", uploadProgress: ((Float) -> ())? = nil) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/upload/uploadImage", method: .post)
            req.headers["Content-Type"] = "multipart/x-www-form-urlencoded"
            req.files = [HttpRequestFormFile(data: data, name: "file", fileName: fileName, mineType: mineType)]
            
            return APP.httpClient.upload(req, uploadProgress: uploadProgress).map({ ($0.json as? [String: Any] ?? [:]) })
        }
    }
}

// MARK: - 登录相关接口
extension HttpApi {

    struct Login {
        
        /// 发送验证码
        /// - Parameters:
        ///   - mobile: 手机号码
        ///   - sign: 场景[1短信注册,2,短信登录,3,重置密码4,更换手机号]
        /// - Returns: 无返回值
        static func sendSms(mobile: String, sign: Int) -> Promise<Void> {
            var req = HttpRequest(path: "/api/verify/sendSms", method: .post)
            req.paramsType = .json
            req.params = ["mobile": mobile, "sign": sign]
            
            return APP.httpClient.request(req).asVoid()
        }
        
        /// 验证码登录
        /// - Parameters:
        ///   - mobile: 手机号码
        ///   - code: 验证码
        /// - Returns: 用户基础信息
        static func codeLogin(mobile: String, code: String) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/login/codeLogin", method: .post)
            req.paramsType = .json
            req.params = ["mobile": mobile, "code": code]
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:]) })
        }
        
        /// 密码登录
        /// - Parameters:
        ///   - mobile: 手机号码
        ///   - password: 登录密码
        /// - Returns: 用户基础信息
        static func pwdLogin(mobile: String, password: String) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/login/pwdLogin", method: .post)
            req.paramsType = .json
            req.params = ["mobile": mobile, "password": password]
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:]) })
        }
        
        /// 忘记密码
        /// - Parameters:
        ///   - mobile: 手机号码
        ///   - password: 密码
        ///   - passwordConfirmation: 确认密码
        ///   - code: 验证码
        /// - Returns: 无返回值
        static func forgetPwd(mobile: String, password: String, passwordConfirmation: String, code: String) -> Promise<Void> {
            var req = HttpRequest(path: "/api/login/forgetPwd", method: .put)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = ["mobile": mobile, "password": password, "password_confirmation": passwordConfirmation, "code": code]

            return APP.httpClient.request(req).asVoid()
        }
        
        /// 获取用户详情
        /// - Returns: 返回结果
        static func getUserInfo() -> Promise<[String: Any]> {
            let req = HttpRequest(path: "/api/login/getUserInfo", method: .get)
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 退出登录
        /// - Returns: 无返回值
        static func authLogout() -> Promise<Void> {
            let req = HttpRequest(path: "/api/auth/logout", method: .delete)
            
            return APP.httpClient.request(req).asVoid()
        }
    }

}

// MARK: - 商城请求接口
extension HttpApi {
    struct Shop {
        
        /// 获取礼包列表
        /// - Returns: 返回结果
        static func getGiftList() -> Promise<[String: Any]> {
            let req = HttpRequest(path: "/api/gift_list", method: .get)
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 获取卡包列表
        /// - Returns: 返回结果
        static func getCardList() -> Promise<[String: Any]> {
            let req = HttpRequest(path: "/api/card_list", method: .get)
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 购买礼包
        /// - Parameters:
        ///   - giftId: 礼包ID
        ///   - payType: 支付方式
        /// - Returns: 返回结果
        static func postGiftPay(giftId: Int, payType: String) -> Promise<Void> {
            var req = HttpRequest(path: "/api/gift_pay", method: .post)
            req.paramsType = .json
            req.params = ["gift_id": giftId, "pay_type": payType, "pay_way": "app"]
            
            return APP.httpClient.request(req).asVoid()
        }
        
        
        
    }
}

// MARK: - 任务大厅请求接口
extension HttpApi {
    struct Task {
        
        /// 获取转发推广海报列表
        /// - Returns: 返回结果
        static func getSendMaterialList() -> Promise<[String: Any]> {
            let req = HttpRequest(path: "/api/send_material_list", method: .get)
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 获取转发推广海报详情
        /// - Returns: 返回结果
        static func getSendMaterialDetail() -> Promise<[String: Any]> {
            let req = HttpRequest(path: "/api/send_material_detail", method: .get)
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 提交任务图片
        /// - Parameter image: 图片链接
        /// - Returns: 无返回值
        static func postTaskUpload(image: String) -> Promise<Void> {
            var req = HttpRequest(path: "/api/task_upload", method: .post)
            req.paramsType = .json
            req.params = ["image": image]
            
            return APP.httpClient.request(req).asVoid()
        }
        
        /// 提交实名认证
        /// - Parameters:
        ///   - realName: 姓名
        ///   - cardId: 身份证号码
        /// - Returns: 无返回值
        static func putCardAuth(realName: String, cardId: String) -> Promise<Void> {
            var req = HttpRequest(path: "/api/card_auth", method: .put)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = ["real_name": realName, "card_id": cardId]

            return APP.httpClient.request(req).asVoid()
        }
        
        /// 设置交易密码
        /// - Parameters:
        ///   - tradePassword: 交易密码
        ///   - confirmPassword: 确认密码
        /// - Returns: 无返回值
        static func putTradePassword(tradePassword: String, confirmPassword: String) -> Promise<Void> {
            var req = HttpRequest(path: "/api/set_trade_password", method: .put)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = ["trade_password": tradePassword, "confirm_password": confirmPassword]

            return APP.httpClient.request(req).asVoid()
        }
        
        /// 设置归属地
        /// - Parameters:
        ///   - provinceCode: 省份code码
        ///   - cityCode: 省份code码
        /// - Returns: 无返回值
        static func putSetLocation(provinceCode: String, cityCode: String) -> Promise<Void> {
            var req = HttpRequest(path: "/api/card_auth", method: .put)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = ["province_code": provinceCode, "city_code": cityCode]

            return APP.httpClient.request(req).asVoid()
        }
        
        /// 获取任务列表
        /// - Returns: 返回结果
        static func getTaskList() -> Promise<[String: Any]> {
            let req = HttpRequest(path: "/api/send_material_detail", method: .get)
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
    }
}

// MARK: - 星球页面请求接口
extension HttpApi {
    
    struct Star {
        
        /// 获取星球推荐用户
        /// - Parameter type: 视角类型 1-男视角，2-女视角
        /// - Returns: 返回结果
        static func getHomeList(type: Int) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/home_list", method: .get)
            req.params = ["type": type]
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 星球推荐用户滑动切换 右滑-喜欢|讨厌
        /// - Parameters:
        ///   - userId: 用户ID
        ///   - type: 投票类型，0-喜欢，1-讨厌
        /// - Returns: 无返回值
        static func postUserVote(userId: Int, type: Int) -> Promise<Void> {
            var req = HttpRequest(path: "/api/user/vote_post", method: .post)
            req.paramsType = .json
            req.params = ["user_id": userId, "type": type]
            
            return APP.httpClient.request(req).asVoid()
        }
        
        /// 获取当前用户的上一个用户
        /// - Parameter userId: 当前用户的ID
        /// - Returns: 返回结果
        static func getBackPre(userId: Int) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/home/back_pre", method: .get)
            req.params = ["user_id": userId]
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 提交喜欢用户
        /// - Parameter userId: 用户ID
        /// - Returns: 无返回结果
        static func getPointLike(userId: Int) -> Promise<Void> {
            var req = HttpRequest(path: "/api/home/point_like", method: .get)
            req.params = ["user_id": userId]
            
            return APP.httpClient.request(req).asVoid()
        }
        
        /// 获取排行榜列表
        /// - Parameters:
        ///   - type: 视角类型 1-男视角，2--女视角
        ///   - page: 数据页数  `page_size` 每页数据个数
        /// - Returns: 返回结果
        static func getRankList(type: Int, page: Int) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/home/rank_list", method: .get)
            req.params = ["type": type, "page": page]
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 获取排行榜列表
        /// - Parameters:
        ///   - type: 视角类型 1-男视角，2--女视角
        ///   - page: 数据页数  `page_size` 每页数据个数
        /// - Returns: 返回结果
        static func getActiveRankList(type: Int, page: Int) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/home/active_rank_list", method: .get)
            req.params = ["type": type, "page": page]
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 获取礼物列表
        /// - Parameter page: 数据页数
        /// - Returns: 返回结果
        static func getGiftList(page: Int) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/my/gift_list", method: .get)
            req.params = ["page": page]
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 赠送礼物
        /// - Parameters:
        ///   - giftId: 礼物ID
        ///   - toUserId: 赠送用户ID
        ///   - number: 礼物数量
        /// - Returns: 无返回值
        static func postGiftSend(giftId: Int, toUserId: Int, number: Int) -> Promise<Void> {
            var req = HttpRequest(path: "/api/my/gift_send", method: .post)
            req.paramsType = .json
            req.params = ["gift_id": giftId, "to_user_id": toUserId, "number": number]
            
            return APP.httpClient.request(req).asVoid()
        }
        
    }
}

// MARK: - 消息页面请求接口
extension HttpApi {
    struct Message {
        
        /// 获取通知数量
        /// - Returns: 返回结果
        static func getNotice() -> Promise<[String: Any]> {
            let req = HttpRequest(path: "/api/notice", method: .get)
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 获取消息列表总览
        /// - Returns: 返回结果
        static func getNoticeDetail() -> Promise<[String: Any]> {
            let req = HttpRequest(path: "/api/notice_detail", method: .get)
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 获取通知消息的历史记录
        /// - Parameters:
        ///   - type: 消息类型 0-系统通知，1-俱乐部通知，2-聚会活动通知
        ///   - page: 数据页数
        /// - Returns: 返回结果
        static func getNoticeList(type: Int, page: Int) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/notice_list", method: .get)
            req.params = ["type": type, "page": page]
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 获取同城动态列表
        /// - Parameter page: 数据页数
        /// - Returns: 返回结果
        static func getCityDynamicList(page: Int) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/city_dynamic_list", method: .get)
            req.params = ["page": page]
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 获取用户亲密度
        /// - Parameter userId: 用户ID
        /// - Returns: 返回结果
        static func getUserIntimacy(userId: Int) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/user_intimacy", method: .get)
            req.params = ["user_id": userId]
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 获取用户的语音通话价格
        /// - Parameter userId: 用户ID
        /// - Returns: 返回结果
        static func getCallStart(userId: Int) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/call_start", method: .get)
            req.params = ["user_id": userId]
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 告知服务器通话开始
        /// - Parameters:
        ///   - userId: 用户ID
        ///   - callId: 通话ID，默认为0新增，有值是更新
        ///   - type: 通话类型，0-语音聊天，1-视频通话
        /// - Returns: 返回结果
        static func putCallStart(userId: Int, callId: Int, type: Int) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/call_start?user_id=\(userId)", method: .put)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = ["call_id": callId, "type": type]

            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 告知服务器语音通话结束
        /// - Parameter callId: 语音通话ID
        /// - Returns: 无返回值
        static func putCallEnd(callId: Int) -> Promise<Void> {
            var req = HttpRequest(path: "/api/call_end", method: .put)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = ["call_id": callId]
            
            return APP.httpClient.request(req).asVoid()
        }
        
        /// 获取用户备注名称
        /// - Returns: 返回数据
        static func getEditFriendName(userId: Int) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/edit_friend_name", method: .get)
            req.paramsType = .url
            req.params = ["user_id": userId]
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 修改用户备注
        /// - Parameters:
        ///   - userId: 被备注用户的ID
        ///   - name: 备注
        /// - Returns: 无返回值
        static func putEditFriendName(userId: Int, name: String) -> Promise<Void> {
            var req = HttpRequest(path: "/api/edit_friend_name", method: .put)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = ["user_id": userId, "name": name]
            
            return APP.httpClient.request(req).asVoid()
        }
        
        /// 购买用户
        /// - Parameters:
        ///   - userId: 用户id
        ///   - money: 金额
        /// - Returns: 无返回值
        static func postTradeUser(userId: Int, money: Int) -> Promise<Void> {
            var req = HttpRequest(path: "/api/trade_user?user_id=\(userId)", method: .post)
            req.paramsType = .json
            req.params = ["money": money]
            
            return APP.httpClient.request(req).asVoid()
        }
        
        /// 获取主人游戏信息
        /// - Parameter userId: 用户ID
        /// - Returns: 返回结果
        static func getTradeUser(userId: Int) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/trade_user", method: .get)
            req.paramsType = .url
            req.params = ["user_id": userId]
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 发送群聊红包
        /// - Parameters:
        ///   - chatId: 群聊ID，俱乐部、活动群组、群聊房间
        ///   - number: 红包人数
        ///   - type: 红包类型：0-群聊，1-俱乐部红包，2-聚会活动
        ///   - gold: 金币数量
        ///   - description: 红包描述
        /// - Returns: 返回 `red_id`
        static func postSendClubRed(chatId: String, number: Int, type: Int, gold: Int, description: String) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/club/send_club_red", method: .post)
            req.paramsType = .json
            req.params = ["chat_id": chatId, "number": number, "description": description, "type": type, "gold": gold]
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 发送群聊礼物
        /// - Parameters:
        ///   - chatId: 群聊ID，俱乐部、活动群组
        ///   - number: 红包人数
        ///   - type: 红包类型：0-群聊，1-俱乐部红包，2-聚会活动
        ///   - giftId: 礼物ID
        ///   - gold: 金币数量
        ///   - description: 礼物描述
        /// - Returns: 返回 `red_id`
        static func postSendClubGift(chatId: String, number: Int, type: Int, giftId: Int, gold: Int, description: String = "") -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/club/send_club_red", method: .post)
            req.paramsType = .json
            req.params = ["chat_id": chatId, "number": number, "description": description, "type": type, "gold": gold, "gift_id": giftId]
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 领取红包
        /// - Parameters:
        ///   - redId: 红包ID
        ///   - chatId: 聊天ID
        /// - Returns: 返回结果
        static func putGetRed(redId: Int, chatId: String) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/world/get_red", method: .put)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = ["red_id": redId, "chat_id": chatId]
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 领取礼物
        /// - Parameters:
        ///   - redId: 包裹ID
        ///   - chatId: 聊天ID
        /// - Returns: 返回结果
        static func putGetGiftRed(redId: Int, chatId: String) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/world/get_gift_red", method: .put)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = ["red_id": redId, "chat_id": chatId]
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 群聊广场红包
        /// - Parameters:
        ///   - chatId: 群聊房间
        ///   - number: 人数，发送礼物为礼物数
        ///   - type: 0-发送金币红包，1-发送礼物红包
        ///   - gold: 金币总数
        ///   - giftId: 礼物ID
        ///   - description: 描述
        /// - Returns: 返回 `red_id`
        static func postSendWorldRed(chatId: String, number: Int, type: Int, gold: Int, giftId: Int, description: String = "") -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/world/send_red", method: .post)
            req.paramsType = .json
            req.params = ["chat_id": chatId, "number": number, "description": description, "type": type, "gold": gold, "gift_id": giftId]
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }

    }
}

// MARK: - 个人中心页面请求接口
extension HttpApi {
    struct Mine {
        /// 获取用户信息
        /// - Returns: 用户信息对象
        static func getUserInfo() -> Promise<[String: Any]> {
            let req = HttpRequest(path: "/api/login/getUserInfo", method: .get)
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        static func getUserDetail(userId: Int) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/user/user_detail", method: .get)
            req.paramsType = .url
            req.params = ["user_id": userId]
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        static func getUserInfo(userId: Int) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/my/my_info", method: .get)
            req.paramsType = .url
            req.params = ["to_user_id": userId]
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }

        /// 获取编辑资料
        /// - Returns: 用户编辑的信息对象
        static func getEditUserInfo() -> Promise<[String: Any]> {
            let req = HttpRequest(path: "/api/my/edit_myinfo", method: .get)
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 提交更新的用户数据
        /// - Parameter data: 更新数据的数据模型
        /// - Returns: 无返回值
        static func putEditUserInfo(params: [String: Any]) -> Promise<Void> {
            var req = HttpRequest(path: "/api/my/edit_myinfo", method: .put)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = params
            
            return APP.httpClient.request(req).asVoid()
        }
        
        /// 获取用户的微信号
        /// - Parameter userId: 用户ID
        /// - Returns: 返回结果
        static func getUserWechat(userId: Int) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/user/look_wechat", method: .get)
            req.params = ["user_id": userId]
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 获取我的关注列表
        /// - Parameter page: 数据页数
        /// - Returns: 返回结果
        static func getMyFollowList(page: Int) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/my_follow_list", method: .get)
            req.params = ["page": page]
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 获取我的粉丝列表
        /// - Parameter page: 数据页数
        /// - Returns: 返回结果
        static func getMyFansList(page: Int) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/my_fans_list", method: .get)
            req.params = ["page": page]
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 获取我的主人游戏列表
        /// - Parameter page: 数据页数
        /// - Returns: 返回结果
        static func getMyGameList(page: Int) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/my_game_list", method: .get)
            req.params = ["page": page]
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 获取我的解锁列表
        /// - Parameter page: 数据页数
        /// - Returns: 返回结果
        static func getMyHistoryList(page: Int) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/history_list", method: .get)
            req.params = ["page": page]
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 获取我的访客列表
        /// - Parameter page: 数据页数
        /// - Returns: 返回结果
        static func getLookMyList(page: Int) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/look_my_list", method: .get)
            req.params = ["page": page]
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 获取关注用户
        /// - Parameter userId: 用户ID
        /// - Returns: 返回列表
        static func putMyFollow(userId: Int) -> Promise<Void> {
            var req = HttpRequest(path: "/api/my_follow", method: .put)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = ["to_user_id": userId]
            
            return APP.httpClient.request(req).asVoid()
        }
        
        /// 获取我的钱包
        /// - Returns: 我的钱包数据对象
        static func getMyWallet() -> Promise<[String: Any]> {
            let req = HttpRequest(path: "/api/currency/my_bag", method: .get)
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 获取邀请好友数据
        /// - Returns: 邀请数据对象
        static func getInviteDetail() -> Promise<[String: Any]> {
            let req = HttpRequest(path: "/api/invite_detail", method: .get)
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 获取曝光任务列表
        /// - Returns: 曝光任务列表数据
        static func getExposureList() -> Promise<[String: Any]> {
            let req = HttpRequest(path: "/api/user/exposure_list", method: .get)
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 获取认证中心数据
        /// - Returns: 认证中心数据字典
        static func getMyAuth() -> Promise<[String: Any]> {
            let req = HttpRequest(path: "/api/my/my_auth", method: .get)
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 获取百度只能认证的token
        /// - Returns: 获取到的token字典 ["access_token":""]
        static func getAuthToken() -> Promise<[String: Any]> {
            let req = HttpRequest(path: "/api/get_baidu_token", method: .get)
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 上传真人认证数据
        /// - Parameter url: 认证图片
        /// - Returns: 无返回值
        static func putRealAuth(url: String) -> Promise<Void> {
            var req = HttpRequest(path: "/api/my/real_auth", method: .put)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = ["auth_pic": url]
            
            return APP.httpClient.request(req).asVoid()
        }
        
        /// 上传实名认证数据
        /// - Parameter realName: 身份证姓名
        /// - Parameter cardID: 身份证号码
        /// - Returns: 无返回值
        static func putCardAuth(realName: String, cardID: String) -> Promise<Void> {
            var req = HttpRequest(path: "/api/my/card_auth", method: .put)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = ["real_name": realName, "card_id": cardID]
            
            return APP.httpClient.request(req).asVoid()
        }
        
        /// 提交女神认证数据
        /// - Parameters:
        ///   - avatar: 认证图片
        ///   - wechat: 认证微信
        ///   - video: 认证视频
        ///   - images: 认证相册，6张 图片链接用逗号隔开
        /// - Returns: 提交结果
        static func putGoddessAuth(avatar: String, wechat: String, video: String, images: String) -> Promise<Void> {
            var req = HttpRequest(path: "/api/my/card_auth", method: .put)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = ["avatar": avatar, "wechat": wechat, "video": video, "images": images]
            
            return APP.httpClient.request(req).asVoid()
        }
        
        /// 获取提现记录数组
        /// - Parameter page: 数据页数
        /// - Returns: 数据数组
        static func getWithdrawList(page: Int) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/currency/withdraw_list", method: .get)
            req.params = ["page": page]
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 获取充值记录数组
        /// - Parameter page: 数据页数
        /// - Returns: 数据数组
        static func getRechargeRecordList(page: Int) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/currency/recharge_record_list", method: .get)
            req.params = ["page": page]
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 获取提现账户列表
        /// - Returns: 返回数据
        static func getBankList() -> Promise<[String: Any]> {
            let req = HttpRequest(path: "/api/currency/bank_list", method: .get)
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 提交提现账户数据
        /// - Parameters:
        ///   - name: 持卡人姓名
        ///   - bankNo: 银行卡号
        ///   - bankName: 银行名称
        ///   - subBranch: 开户支行
        ///   - mobile: 银行预留手机号
        /// - Returns: 无返回值
        static func postUserBank(name: String, bankNo: String, bankName: String, subBranch: String, mobile: String) -> Promise<Void> {
            var req = HttpRequest(path: "/api/currency/user_bank", method: .post)
            req.paramsType = .json
            req.params = ["name": name,
                          "card_no": bankNo,
                          "bank_name": bankName,
                          "sub_branch": subBranch,
                          "mobile": mobile]
            
            return APP.httpClient.request(req).asVoid()
        }
        
        /// 删除绑定的提现账户
        /// - Parameter cardNo: 提现账户
        /// - Returns: 无返回值
        static func deleteUserBank(cardNo: String) -> Promise<Void> {
            var req = HttpRequest(path: "/api/currency/user_bank_delete", method: .delete)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = ["card_no": cardNo]
            
            return APP.httpClient.request(req).asVoid()
        }
        
        /// 获取账户明细
        /// - Parameters:
        ///   - page: 数据页数
        ///   - tradeType: 交易类型
        ///   - time: 交易时间
        /// - Returns: 返回数据
        static func getMoneyDetail(page: Int, tradeType: Int, time: String) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/currency/my_money_detail", method: .get)
            req.params = ["page": page,
                          "trade_type": tradeType,
                          "time": time]
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 获取余额明细
        /// - Parameter page: 数据页数
        /// - Returns: 返回数据
        static func getBalanceDetail(page: Int) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/currency/my_balance_detail", method: .get)
            req.params = ["page": page]

            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 上传相册json
        /// - Parameter json: 相册JSON
        /// - Returns: 无返回值
        static func putUserAlbum(json: String) -> Promise<Void> {
            var req = HttpRequest(path: "/api/my/upload_album", method: .put)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = ["album": json]
            
            return APP.httpClient.request(req).asVoid()
        }
        
        /// 获取注销满足条件
        /// - Returns: 返回结果
        static func getCancelAccount() -> Promise<[String: Any]> {
            let req = HttpRequest(path: "/api/currency/cancel_acount", method: .get)

            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 获取积分提现数据
        /// - Returns: 返回结果
        static func getCreditWithdraw() -> Promise<[String: Any]> {
            let req = HttpRequest(path: "/api/currency/credit_withdraw", method: .get)

            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 提交提现申请
        /// - Parameter cardNo: 提现账户
        /// - Returns: 无返回值
        static func postMoneyWithdraw(cardNo: String) -> Promise<Void> {
            var req = HttpRequest(path: "/api/currency/money_withdraw_post", method: .post)
            req.paramsType = .json
            req.params = ["card_no": cardNo]
            
            return APP.httpClient.request(req).asVoid()
        }
        
        /// 获取提现记录详情
        /// - Parameter withdrawId: 提现记录ID
        /// - Returns: 返回结果
        static func getWithdrawDetail(withdrawId: Int) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/currency/withdraw_detail", method: .get)
            req.params = ["withdraw_id": withdrawId]

            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 获取金币充值列表
        /// - Returns: 返回结果
        static func getRechargeGoldList() -> Promise<[String: Any]> {
            let req = HttpRequest(path: "/api/my/recharge_gold_list", method: .get)

            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 获取会员列表数据
        /// - Returns: 返回结果
        static func getVipList() -> Promise<[String: Any]> {
            let req = HttpRequest(path: "/api/my/vip_list", method: .get)

            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 获取免打扰设置
        /// - Returns: 返回结果
        static func getNoDisturbSet() -> Promise<[String: Any]> {
            let req = HttpRequest(path: "/api/my/no_disturb_set", method: .get)

            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 提交免打扰设置
        /// - Parameter param: 提交参数
        /// - Returns: 无返回值
        static func putNoDisturbSet(param: [String: Any]) -> Promise<Void> {
            var req = HttpRequest(path: "/api/my/no_disturb_set", method: .put)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = param

            return APP.httpClient.request(req).asVoid()
        }
        
        /// 提交积分转余额
        /// - Parameter money: 余额数量
        /// - Returns: 无返回值
        static func putCreditToMoney(money: Int) -> Promise<Void> {
            var req = HttpRequest(path: "/api/currency/credit_to_money", method: .put)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = ["money": money]

            return APP.httpClient.request(req).asVoid()
        }
        
        /// 提交积分转金币
        /// - Parameter money: 金币数量
        /// - Returns: 无返回值
        static func putCreditToGold(money: Int) -> Promise<Void> {
            var req = HttpRequest(path: "/api/currency/credit_to_gold", method: .put)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = ["money": money]

            return APP.httpClient.request(req).asVoid()
        }
        
        /// 获取魅力特质列表
        /// - Returns: 返回结果
        static func getCharmList() -> Promise<[String: Any]> {
            let req = HttpRequest(path: "/api/user/charm_list", method: .get)

            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 添加魅力特质
        /// - Parameters:
        ///   - charmId: 特质ID
        ///   - images: 图片
        ///   - video: 视频
        ///   - type: 类型
        /// - Returns: 无返回结果
        static func postCharmAdd(charmId: Int, images: String, video: String, type: Int, des: String) -> Promise<Void> {
            var req = HttpRequest(path: "/api/user/charm_add", method: .post)
            req.paramsType = .json
            req.params = ["charm_id": charmId, "images": images, "video": video, "type": type, "des": des]
            
            return APP.httpClient.request(req).asVoid()
        }
        
        /// 获取我的写真集列表
        /// - Returns: 返回结果
        static func getMyCharmList() -> Promise<[String: Any]> {
            let req = HttpRequest(path: "/api/user/my_charm_list", method: .get)

            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 获取特征详情
        /// - Parameters:
        ///   - charmId: 特征ID
        ///   - page: 数据页数
        /// - Returns: 返回结果
        static func getMyCharmDetail(charmId: Int, page: Int) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/user/my_charm_detail", method: .get)
            req.params = ["charm_id": charmId, "page": page]

            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 特征写真点赞
        /// - Parameter recordId: 魅力特质记录ID
        /// - Returns: 无返回值
        static func getMyCharmLike(recordId: Int) -> Promise<Void> {
            var req = HttpRequest(path: "/api/user/my_charm_like", method: .get)
            req.params = ["record_id": recordId]

            return APP.httpClient.request(req).asVoid()
        }
        
        /// 特征分类点赞
        /// - Parameter charmId: 魅力特质分类ID
        /// - Returns: 无返回值
        static func getCharmCateLike(charmId: Int) -> Promise<Void> {
            var req = HttpRequest(path: "/api/user/charm_cate_like", method: .get)
            req.params = ["charm_id": charmId]

            return APP.httpClient.request(req).asVoid()
        }
        
        /// 获取评价的印象列表，根据自身性别获取不同的评价列表
        /// - Returns: 返回数据
        static func getSendComment() -> Promise<[[String: Any]]> {
            let req = HttpRequest(path: "/api/my/send_comment", method: .get)

            return APP.httpClient.request(req).map({ ($0.json as? [[String: Any]] ?? [])})
        }
        
        /// 获取别人对我的评价列表
        /// - Returns: 返回数据
        static func getMyComment() -> Promise<[[String: Any]]> {
            let req = HttpRequest(path: "/api/my/my_get_label", method: .get)

            return APP.httpClient.request(req).map({ ($0.json as? [[String: Any]] ?? [])})
        }
        
        /// 提交评价印象
        /// - Parameters:
        ///   - userId: 用户Id
        ///   - ids: 印象ID数组
        /// - Returns: 无返回值
        static func putComment(userId: Int, ids: [Int]) -> Promise<Void> {
            var req = HttpRequest(path: "/api/my/send_comment", method: .put)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            var params = ["to_user_id": userId]
            for (i, item) in ids.enumerated() {
                params["label_ids[\(i)]"] = item
            }
            req.params = params

            return APP.httpClient.request(req).asVoid()
        }
        
        /// 获取财富值升级信息
        /// - Returns: 返回结果
        static func getWealthLevelNeed() -> Promise<[String: Any]> {
            let req = HttpRequest(path: "/api/wealthlevel_need", method: .get)

            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 获取魅力值升级信息
        /// - Returns: 返回结果
        static func getCharmLevelNeed() -> Promise<[String: Any]> {
            let req = HttpRequest(path: "/api/charmlevel_need", method: .get)

            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
    }

}

// MARK: - 支付请求接口
extension HttpApi {
    struct Pay {

        /// 购买VIP
        /// - Parameters:
        ///   - levelId: vip等级
        ///   - payWay: 支付类型 wechat-微信支付，alipay-支付宝，balance-余额支付
        /// - Returns: 支付字符串
        static func postBuyVip(levelId: Int, payWay: String) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/my/buy_vip", method: .post)
            req.paramsType = .json
            req.params = ["level_id": levelId, "pay_way": payWay, "pay_type": "app"]
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 充值金币
        /// - Parameters:
        ///   - levelId: 金币等级ID
        ///   - payWay: 支付类型 wechat-微信支付，alipay-支付宝，balance-余额支付
        /// - Returns: 支付字符串
        static func postRechargeGold(rechargeId: Int, payWay: String) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/my/recharge_gold", method: .post)
            req.paramsType = .json
            req.params = ["recharge_id": rechargeId, "pay_way": payWay, "pay_type": "app"]
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        
        
    }
}

