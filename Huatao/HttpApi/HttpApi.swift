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
            req.isSign = true
            
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
        static func getSendMaterialList(page: Int) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/send_material_list", method: .get)
            req.params = ["page": page]

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
            let req = HttpRequest(path: "/api/task_list", method: .get)
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 轮播图列表
        /// - Parameter sign: 类型 home-首页、task-任务大厅
        /// - Returns: 返回结果
        static func getBannerList(sign: String) -> Promise<[[String: Any]]> {
            var req = HttpRequest(path: "/api/banner/list", method: .get)
            req.params = ["sign": sign]
            
            return APP.httpClient.request(req).map({ ($0.json as? [[String: Any]] ?? [])})
        }
    }
}

// MARK: - 星球页面请求接口
extension HttpApi {
    
    struct Find {
        
        /// 发布图片动态
        /// - Parameters:
        ///   - content: 动态内容
        ///   - images: 图片链接数组
        /// - Returns: 无返回值
        static func postImageDynamic(content: String, images: [String]) -> Promise<Void> {
            var req = HttpRequest(path: "/api/add_dynamic", method: .post)
            req.paramsType = .json
            req.params = ["content": content, "type": 0, "images": images]
            
            return APP.httpClient.request(req).asVoid()
        }
        
        /// 发布视频动态
        /// - Parameters:
        ///   - content: 动态内容
        ///   - video: 视频链接
        /// - Returns: 无返回值
        static func postVideoDynamic(content: String, video: String) -> Promise<Void> {
            var req = HttpRequest(path: "/api/add_dynamic", method: .post)
            req.paramsType = .json
            req.params = ["content": content, "type": 1, "video": video]
            
            return APP.httpClient.request(req).asVoid()
        }
        
        ///
        /// - Parameter
        ///   - isMy:
        /// - Returns: 返回结果
        
        /// 获取动态列表
        /// - Parameters:
        ///   - isMy: 动态类型，0-所有，1-我的
        ///   - page: 数据页数
        /// - Returns: 返回结果
        static func getDynamicList(isMy: Int, page: Int = 0) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/dynamic_list", method: .get)
            req.params = ["is_my": isMy]
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 点赞动态
        /// - Parameter dynamicId: 动态ID
        /// - Returns: 无返回值
        static func putDynamicLike(dynamicId: Int) -> Promise<Void> {
            var req = HttpRequest(path: "/api/dynamic_like", method: .put)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = ["dynamic_id": dynamicId]

            return APP.httpClient.request(req).asVoid()
        }
        
        /// 评论动态
        /// - Parameters:
        ///   - dynamicId: 动态ID
        ///   - content: 评论内容
        ///   - toUserId: 回复的用户ID
        ///   - topPid: 顶级评论的ID，为0就是评论贴主
        /// - Returns: 无返回值
        static func postDynamicComment(dynamicId: Int, content: String, toUserId: Int, topPid: Int) -> Promise<Void> {
            var req = HttpRequest(path: "/api/dynamic_comment", method: .post)
            req.paramsType = .json
            req.params = ["dynamic_id": dynamicId, "content": content, "to_user_id": toUserId, "top_pid": topPid]
        
            return APP.httpClient.request(req).asVoid()
        }
        
        /// 获取动态详情
        /// - Parameter dynamicId: 动态ID
        /// - Returns: 返回数据
        static func getDynamicDetail(dynamicId: Int) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/dynamic_detail", method: .get)
            req.params = ["dynamic_id": dynamicId]
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 点赞评论
        /// - Parameter commentId: 评论ID
        /// - Returns: 无返回值
        static func putCommentLike(commentId: Int) -> Promise<Void> {
            var req = HttpRequest(path: "/api/dynamic_comment_like", method: .put)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = ["comment_id": commentId]

            return APP.httpClient.request(req).asVoid()
        }
        
        /// 删除动态
        /// - Parameter dynamicId: 动态ID
        /// - Returns: 无返回值
        static func deleteDynamic(dynamicId: Int) -> Promise<Void> {
            var req = HttpRequest(path: "/api/dynamic_delete", method: .delete)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = ["dynamic_id": dynamicId]

            return APP.httpClient.request(req).asVoid()
        }
        
        /// 获取互动消息列表
        /// - Returns: 返回结果
        static func getInteractMessageList() -> Promise<[String: Any]> {
            let req = HttpRequest(path: "/api/Interact_message_list", method: .get)
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 获取发现页面右上角小红点
        /// - Returns: 返回结果
        static func getDynamicRedNotice() -> Promise<[String: Any]> {
            let req = HttpRequest(path: "/api/dynamic_red_notice", method: .get)
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }

        
    }
}

// MARK: - 消息页面请求接口
extension HttpApi {
    struct Chat {
        
        /// 根据手机号码搜索用户
        /// - Returns: 返回结果
        static func getSearchFriend(mobile: String) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/search_friend", method: .get)
            req.params = ["mobile": mobile]
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 提交添加好友申请
        /// - Parameters:
        ///   - userId: 用户ID
        ///   - desc: 申请描述
        ///   - name: 备注名
        /// - Returns: 无返回值
        static func postAddFriend(userId: Int, desc: String, name: String) -> Promise<Void> {
            var req = HttpRequest(path: "/api/add_friend", method: .post)
            req.paramsType = .json
            req.params = ["user_id": userId, "desc": desc, "name": name]
        
            return APP.httpClient.request(req).asVoid()
        }
        
        /// 获取好友申请通知
        /// - Returns: 返回结果
        static func getNoticeFriend(page: Int, pageSize: Int = 100) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/notice_friend", method: .get)
            req.params = ["page": page, "page_size": pageSize]
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 添加好友审批
        /// - Parameters:
        ///   - noticeId: 通知ID
        ///   - status: 出来状态，1-同意，2-拒绝
        /// - Returns: 返回结果
        static func putCheckFriend(noticeId: Int, status: Int) -> Promise<Void> {
            var req = HttpRequest(path: "/api/check_friend", method: .put)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = ["notice_id": noticeId, "status": status]

            return APP.httpClient.request(req).asVoid()
        }
        
        /// 获取通讯录列表
        /// - Returns: 返回结果
        static func getFriendList(page: Int = 1, pageSize: Int = 100) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/friend_list", method: .get)
            req.params = ["page": page, "page_size": pageSize]
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 获取群聊设置
        /// - Parameter teamId: 群组ID
        /// - Returns: 返回结果
        static func getTeamMaster(teamId: Int) -> Promise<[String: Any]> {
            let req = HttpRequest(path: "/api/team_master", method: .get)
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 获取群主列表
        /// - Returns: 返回结果
        static func getTeamList() -> Promise<[String: Any]> {
            let req = HttpRequest(path: "/api/team_list", method: .get)
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 修改群名称
        /// - Parameters:
        ///   - title: 群名称
        ///   - teamId: 群组ID
        /// - Returns: 无返回值
        static func putTeamEdit(title: String, teamId: Int) -> Promise<Void> {
            var req = HttpRequest(path: "/api/team_edit", method: .put)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = ["title": title, "team_id": teamId]

            return APP.httpClient.request(req).asVoid()
        }
        
        /// 获取群组管理员设置
        /// - Parameters:
        ///   - teamId: 群组ID
        ///   - keyword: 关键词
        /// - Returns: 返回结果
        static func getTeamSet(teamId: Int, keyword: String) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/team_set", method: .get)
            req.params = ["keyword": keyword, "team_id": teamId]

            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 设置群组管理员
        /// - Parameters:
        ///   - teamId: 群组ID
        ///   - keyword: 关键词
        /// - Returns: 返回结果
        static func putTeamSet(teamId: Int, userId: Int) -> Promise<Void> {
            var req = HttpRequest(path: "/api/team_set", method: .put)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = ["user_id": userId, "team_id": teamId]

            return APP.httpClient.request(req).asVoid()
        }
        
        /// 删除群员
        /// - Parameters:
        ///   - teamId: 群组ID
        ///   - userIds: 群员ID数组
        /// - Returns: 无返回值
        static func deleteTeamUser(teamId: Int, userIds: [Int]) -> Promise<Void> {
            var req = HttpRequest(path: "/api/team_delete_user", method: .delete)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = ["user_ids": userIds, "team_id": teamId]

            return APP.httpClient.request(req).asVoid()
        }
        
        /// 发个人红包
        /// - Parameters:
        ///   - userId: 对象ID
        ///   - type: 类型 0-银豆，1-现金红包
        ///   - payType: 支付类型，0-余额支付，1-微信支付，2-支付宝支付
        ///   - money: 数额
        ///   - orderSn: 支付订单号
        /// - Returns: 无返回值
        static func putUserSendRed(userId: Int, type: Int, payType: Int, money: Int, orderSn: String) -> Promise<Void> {
            var req = HttpRequest(path: "/api/team_set", method: .put)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = ["user_id": userId, "type": type, "pay_type": payType, "money": money, "order_sn": orderSn]

            return APP.httpClient.request(req).asVoid()
        }
        
        /// 发放群组红包
        /// - Parameters:
        ///   - teamId: 群组ID
        ///   - type: 类型 0-银豆，1-现金红包
        ///   - payType: 支付类型，0-余额支付，1-微信支付，2-支付宝支付
        ///   - money: 数额
        ///   - number: 份数
        ///   - orderSn: 支付订单号
        ///   - redType: 红包类型，0-普通红包，1-拼手气红包
        ///   - totalMoney: 总金额
        /// - Returns: 无返回值
        static func putTeamSendRed(teamId: Int, type: Int, payType: Int, money: Int, number: Int, orderSn: String, redType: Int, totalMoney: Int) -> Promise<Void> {
            var req = HttpRequest(path: "/api/team_set", method: .put)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = ["team_id": teamId, "type": type, "pay_type": payType, "money": money, "number": number, "order_sn": orderSn, "red_type": redType, "total_money": totalMoney]

            return APP.httpClient.request(req).asVoid()
        }
        
        /// 提交红包支付
        /// - Parameters:
        ///   - money: 金额
        ///   - payType: 支付方式，wechat-微信，alipay-支付宝
        ///   - payWay: 支付方法，miniapp-小程序，app-APP支付，scan-扫码支付
        /// - Returns: 无返回值
        static func postRedPay(money: String, payType: String, payWay: Int) -> Promise<Void> {
            var req = HttpRequest(path: "/api/add_friend", method: .post)
            req.paramsType = .json
            req.params = ["money": money, "pay_type": payType, "pay_way": payWay]
        
            return APP.httpClient.request(req).asVoid()
        }
        
        /// 获取好友详情
        /// - Parameter userId: 用户ID
        /// - Returns: 返回结果
        static func getFriendDetail(userId: Int) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/friend_detail", method: .get)
            req.params = ["user_id": userId]

            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 获取下级关系
        /// - Parameter userId: 用户ID
        /// - Returns: 返回结果
        static func getChildrenList(userId: Int) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/children_list", method: .get)
            req.params = ["user_id": userId]

            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
    }
}

// MARK: - 个人中心页面请求接口
extension HttpApi {
    
    struct Mine {
        
        /// 获取个人中心数据
        /// - Returns: 返回结果
        static func getMyUserInfo() -> Promise<[String: Any]> {
            let req = HttpRequest(path: "/api/my/user_info", method: .get)
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 获取我的团队数据
        /// - Returns: 返回结果
        static func getMyTeam() -> Promise<[String: Any]> {
            let req = HttpRequest(path: "/api/my_team", method: .get)
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 获取交易大厅数据
        /// - Returns: 返回数据
        static func getTradingHall() -> Promise<[String: Any]> {
            let req = HttpRequest(path: "/api/trading_hall", method: .get)
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 获取交易大厅-折线图数据
        /// - Parameter type: 类型, 0-7天, 1-14天, 2-30天
        /// - Returns: 返回结果
        static func getTradingHallLine(type: Int) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/trading_hall_line", method: .get)
            req.params = ["type": type]

            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 提交金豆卖出申请
        /// - Parameters:
        ///   - total: 卖出总额
        ///   - tradeType: 收款类型
        ///   - name: 姓名
        ///   - card: 卡号
        ///   - bankAddress: 开户行
        ///   - tradeImage: 收款图片
        ///   - tradePassword: 交易密码
        /// - Returns: 无返回值
        static func postGoldSale(total: CGFloat, tradeType: Int, name: String, card: String, bankAddress: String, tradeImage: String, tradePassword: String) -> Promise<Void> {
            var req = HttpRequest(path: "/api/gold_sale", method: .post)
            req.paramsType = .json
            req.params = ["total": total, "trade_type": tradeType, "name": name, "card": card, "bank_address": bankAddress, "trade_image": tradeImage, "trade_password": tradePassword]
        
            return APP.httpClient.request(req).asVoid()
        }
        
        /// 提交金豆购买申请
        /// - Parameters:
        ///   - total: 购买金豆总额
        ///   - price: 购买单价
        /// - Returns: 无返回值
        static func postGoldBuy(total: Int, price: CGFloat) -> Promise<Void> {
            var req = HttpRequest(path: "/api/gold_buy", method: .post)
            req.paramsType = .json
            req.params = ["total": total, "price": price]
        
            return APP.httpClient.request(req).asVoid()
        }
        
        /// 获取金豆购入记录
        /// - Parameter page: 数据页数
        /// - Returns: 返回结果
        static func getTradeBuyList(page: Int) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/trade_buy_list", method: .get)
            req.params = ["page": page]

            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 获取金豆售出记录
        /// - Parameter page: 数据页数
        /// - Returns: 返回结果
        static func getTradeSaleList(page: Int) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/trade_sale_list", method: .get)
            req.params = ["page": page]

            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 金豆出售订单确认
        /// - Parameters:
        ///   - buyId: 购买订单id
        ///   - status: 订单状态
        /// - Returns: 无返回值
        static func putTradeConfirm(buyId: Int, status: Int) -> Promise<Void> {
            var req = HttpRequest(path: "/api/trade_comfirm", method: .put)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = ["buy_id": buyId, "status": status]

            return APP.httpClient.request(req).asVoid()
        }
        
        /// 获取订单交易凭证
        /// - Parameter buyId: 订单ID
        /// - Returns: 返回结果
        static func getTradeUpload(buyId: Int) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/trade_upload", method: .get)
            req.params = ["buy_id": buyId]

            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 上传交易凭证
        /// - Parameters:
        ///   - buyId: 交易ID
        ///   - uploadImage: 交易凭证截图
        /// - Returns: 无返回值
        static func putTradeUpload(buyId: Int, uploadImage: String) -> Promise<Void> {
            var req = HttpRequest(path: "/api/trade_upload", method: .put)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = ["buy_id": buyId, "upload_image": uploadImage]

            return APP.httpClient.request(req).asVoid()
        }
        
        /// 交易完成
        /// - Parameter buyId: 交易ID
        /// - Returns: 无返回值
        static func putTradeComplete(buyId: Int) -> Promise<Void> {
            var req = HttpRequest(path: "/api/trade_complete", method: .put)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = ["buy_id": buyId]

            return APP.httpClient.request(req).asVoid()
        }
        
        /// 获取升级规则
        /// - Returns: 返回结果
        static func getUpgradeRule() -> Promise<[String: Any]> {
            let req = HttpRequest(path: "/api/upgrade_rule", method: .get)
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 获取我的钱包
        /// - Returns: 返回结果
        static func getMyBag() -> Promise<[String: Any]> {
            let req = HttpRequest(path: "/api/my_bag", method: .get)
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 获取记录列表
        /// - Parameters:
        ///   - way: 方式，0-余额记录，1-银豆记录，2-金豆记录，3-贡献记录
        ///   - type: 类型，0-支出，1-收入
        ///   - page: 数据页数
        /// - Returns: 返回结果
        static func getRecordList(way: Int, type: Int, page: Int) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/record_list", method: .get)
            req.params = ["way": way, "type": type, "page": page]

            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 兑换金豆
        /// - Parameter money: 兑换数量
        /// - Returns: 无返回值
        static func putConversionGold(money: Int) -> Promise<Void> {
            var req = HttpRequest(path: "/api/conversion_gold", method: .put)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = ["money": money]

            return APP.httpClient.request(req).asVoid()
        }
        
        /// 获取兑换金豆数量列表
        /// - Returns: 返回结果
        static func getConversionGold() -> Promise<[String: Any]> {
            let req = HttpRequest(path: "/api/conversion_gold", method: .get)

            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 获取兑换记录列表
        /// - Parameter page: 数据页数
        /// - Returns: 返回结果
        static func getConversionList(page: Int) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/conversion_list", method: .get)
            req.params = ["page": page]

            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 获取卡包列表
        /// - Parameter page: 页数
        /// - Returns: 返回结果
        static func getCardList(page: Int) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/my_card_list", method: .get)
            req.params = ["page": page]

            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 获取卡包返回数据
        /// - Returns: 返回结果
        static func getCardReturn() -> Promise<[String: Any]> {
            let req = HttpRequest(path: "/api/my_card_return", method: .get)

            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 获取已完成卡包列表
        /// - Parameter page: 页数
        /// - Returns: 返回结果
        static func getCompleteCardList(page: Int) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/complete_card_list", method: .get)
            req.params = ["page": page]

            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 兑换卡包
        /// - Parameter cardId: 卡包ID
        /// - Returns: 无返回值
        static func putConversionCard(cardId: Int) -> Promise<Void> {
            var req = HttpRequest(path: "/api/conversion_card", method: .put)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = ["card_id": cardId]

            return APP.httpClient.request(req).asVoid()
        }

        /// 获取任务提醒直推和间推列表
        /// - Parameters:
        ///   - page: 数据页数
        ///   - type: 数据类型  0-直推，1-间推
        /// - Returns: 返回结果
        static func getTaskNotice(page: Int, type: Int) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/task_notice", method: .get)
            req.params = ["page": page, "type": type]

            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 提醒做任务
        /// - Parameter userIds: 用户ID数组
        /// - Returns: 返回结果
        static func putTaskSendNotice(userIds: [Int]) -> Promise<Void> {
            var req = HttpRequest(path: "/api/task_send_notice", method: .put)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .json
            req.encoding = URLEncoding.httpBody
            req.params = ["user_ids": userIds]

            return APP.httpClient.request(req).asVoid()
        }
        
        /// 获取任务弹窗
        /// - Returns: 返回结果
        static func getTaskAlert() -> Promise<[String: Any]> {
            let req = HttpRequest(path: "/api/task_alert", method: .get)

            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 更新任务弹窗
        /// - Returns: 无返回值
        static func getUpdateAlert() -> Promise<Void> {
            let req = HttpRequest(path: "/api/update_alert", method: .get)

            return APP.httpClient.request(req).asVoid()
        }
        
        /// 获取代理列表
        /// - Returns: 返回结果
        static func getAgentList() -> Promise<[String: Any]> {
            let req = HttpRequest(path: "/api/become_agent", method: .get)

            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 提交代理申请
        /// - Parameters:
        ///   - mobile: 手机号
        ///   - name: 姓名
        ///   - provinceCode: 省份号码
        ///   - cityCode: 城市号码
        /// - Returns: 无返回值
        static func putBecomeAgent(mobile: String, name: String, provinceCode: String, cityCode: String) -> Promise<Void> {
            var req = HttpRequest(path: "/api/become_agent", method: .put)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = ["mobile": mobile, "name": name, "province_code": provinceCode, "city_code": cityCode]

            return APP.httpClient.request(req).asVoid()
        }

        /// 修改头像
        /// - Parameter avatar: 头像
        /// - Returns: 无返回值
        static func putMyAvatar(avatar: String) -> Promise<Void> {
            var req = HttpRequest(path: "/api/my/editMyJobhunter", method: .put)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = ["avatar": avatar]

            return APP.httpClient.request(req).asVoid()
        }
        
        /// 修改昵称
        /// - Parameter name: 昵称
        /// - Returns: 无返回值
        static func putMyName(name: String) -> Promise<Void> {
            var req = HttpRequest(path: "/api/my/editMyJobhunter", method: .put)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = ["name": name]

            return APP.httpClient.request(req).asVoid()
        }
        
        /// 修改个性签名
        /// - Parameter personSign: 个性签名
        /// - Returns: 无返回值
        static func putMyPersonSign(personSign: String) -> Promise<Void> {
            var req = HttpRequest(path: "/api/my/editMyJobhunter", method: .put)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = ["person_sign": personSign]

            return APP.httpClient.request(req).asVoid()
        }
        
        /// 修改职业
        /// - Parameter jobName: 职业
        /// - Returns: 无返回值
        static func putMyJobName(jobName: String) -> Promise<Void> {
            var req = HttpRequest(path: "/api/my/editMyJobhunter", method: .put)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = ["job_name": jobName]

            return APP.httpClient.request(req).asVoid()
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

