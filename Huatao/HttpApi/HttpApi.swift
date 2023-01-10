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

// MARK: - 通用接口
extension HttpApi {
    
    /// 极光手机号码解析
    /// - Parameter loginToken: 授权获取到的loginToken
    /// - Returns: 解析的手机号数据
    static func jpushDecrypt(loginToken: String) -> Promise<[String: Any]> {
        var req = HttpRequest(path: "/api/jiguang_decrypt", method: .post)
        req.paramsType = .json
        req.params = ["loginToken": loginToken]
        
        return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:]) })
    }

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
    ///   - inviteCode: 邀请码
    /// - Returns: 用户基础信息
    static func codeLogin(mobile: String, code: String, inviteCode: String) -> Promise<[String: Any]> {
        var req = HttpRequest(path: "/api/login/codeLogin", method: .post)
        req.paramsType = .json
        req.params = ["mobile": mobile, "code": code, "invite_code": inviteCode]
        return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:]) })
    }
    
    /// 提交注销账号申请
    /// - Parameters:
    ///   - mobile: 注销账号的手机号
    ///   - code: 验证码
    /// - Returns: 无返回结果
    static func putCancelAccount(mobile: String, code: String) -> Promise<Void> {
        var req = HttpRequest(path: "/api/currency/logout_acount", method: .put)
        req.headers["Content-Type"] = "application/x-www-form-urlencoded"
        req.paramsType = .url
        req.encoding = URLEncoding.httpBody
        req.params = [
            "mobile": mobile,
            "code": code
        ]
        
        return APP.httpClient.request(req).asVoid()
    }
    
    /// 获取职业分类列表
    /// - Parameter job_cata_id: 分类id 当值为0时 获取顶级
    /// - Returns: 职业分类列表
    static func getJobCategory() -> Promise<[[String: Any]]> {
        var req = HttpRequest(path: "/api/job_category/list", method: .get)
        req.params = [:]
        return APP.httpClient.request(req).map({ ($0.json as? [[String: Any]] ?? [])})
    }
    
    /// 获取标签列表
    /// - Parameter: sexType: 标签类型，0-女士标签，1-男士标签
    /// - Returns: 标签列表
    static func getLabels(sexType: Int) -> Promise<[[String: Any]]> {
        var req = HttpRequest(path: "/api/user_label/list", method: .get)
        req.params = ["sex_type": sexType]
        
        return APP.httpClient.request(req).map({ ($0.json as? [[String: Any]] ?? [])})
    }
    

    static func getUserDetail(userId: Int) -> Promise<[String: Any]> {
        var req = HttpRequest(path: "/api/user/user_detail", method: .get)
        req.params = ["user_id": userId]
        
        return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
    }
    
    /// 添加黑名单用户
    /// - Parameter userId: 用户ID
    /// - Returns: 返回结果
    static func addBlack(userId: Int) -> Promise<Void> {
        var req = HttpRequest(path: "/api/add_black", method: .post)
        req.paramsType = .json
        req.params = ["to_user_id": userId]
        
        return APP.httpClient.request(req).asVoid()
    }
    
    /// 移除黑名单用户
    /// - Parameter userId: 用户ID
    /// - Returns: 返回结果
    static func deleteBlack(userId: Int) -> Promise<Void> {
        var req = HttpRequest(path: "/api/delete_black", method: .delete)
        req.paramsType = .json
        req.params = ["to_user_id": userId]
        
        return APP.httpClient.request(req).asVoid()
    }
    
    /// 获取黑名单列表
    /// - Parameter page: 数据页数，每页15条数据
    /// - Returns: 数据列表
    static func getBlackList(page: Int) -> Promise<[String: Any]> {
        var req = HttpRequest(path: "/api/black_list", method: .get)
        req.params = ["page": page]
        
        return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
    }
    
    /// 提交签到
    /// - Returns: 无返回值
    static func putTaskSign() -> Promise<Void> {
        var req = HttpRequest(path: "/api/task/add_sign", method: .put)
        req.headers["Content-Type"] = "application/x-www-form-urlencoded"
        req.paramsType = .url
        req.encoding = URLEncoding.httpBody
        req.params = [:]
        
        return APP.httpClient.request(req).asVoid()
    }
    
    /// 获取签到记录
    /// - Parameter type: 类型
    /// - Returns: 返回结果
    static func getTaslSignCode(type: Int) -> Promise<[String: Any]> {
        var req = HttpRequest(path: "/api/task/sign_code", method: .get)
        req.params = ["type": type]
        
        return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
    }
    
    /// 提交投诉举报
    /// - Parameters:
    ///   - userId: 用户ID
    ///   - type: 举报类型
    ///   - images: 举报图片 aaa.png,bb.png
    ///   - desc: 举报内容
    /// - Returns: 无返回值
    static func postAddReport(userId: Int, type: Int, images: String, desc: String) -> Promise<Void> {
        var req = HttpRequest(path: "/api/add_report", method: .post)
        req.paramsType = .json
        req.params = ["to_user_id": userId, "type": type, "images": images, "desc": desc]
        
        return APP.httpClient.request(req).asVoid()
    }
    
    
}

// MARK: - 首页页面请求接口
extension HttpApi {
    struct Home {
        
        static func getStarList(cityCode: String) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/star_list", method: .get)
            req.params = ["city_code": cityCode]
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 获取二级特征下面的列表数据
        /// - Parameters:
        ///   - Int: 特征二级分类ID
        ///   - isLocal: 是否查看同城，0-查看所有，1-查看同城
        ///   - page: 数据页数
        /// - Returns: 返回数据
        static func getMatchCharmList(charmId: Int, isLocal: Int, cityName: String, page: Int) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/user/match_charm_list", method: .get)
            req.params = ["charm_id": charmId, "is_local": isLocal, "city_name": cityName, "page": page]
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 获取投票用户
        /// - Returns: 返回数据
        static func getVoteDetail() -> Promise<[String: Any]> {
            let req = HttpRequest(path: "/api/user/vote_detail", method: .get)
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 获取俱乐部列表
        /// - Parameters:
        ///   - type: 列表类型，0-推荐俱乐部，1-我的俱乐部
        ///   - keyword: 搜索关键字
        ///   - page: 数据页数
        /// - Returns: 返回结果
        static func getClubList(type: Int, keyword: String, page: Int) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/club/club_list", method: .get)
            req.params = ["type": type, "keyword": keyword, "page": page]
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 申请加入俱乐部
        /// - Parameter clubId: 俱乐部ID
        /// - Returns: 无返回值
        static func putClubApply(clubId: Int) -> Promise<Void> {
            var req = HttpRequest(path: "/api/club/club_apply", method: .put)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = ["club_id": clubId]
            
            return APP.httpClient.request(req).asVoid()
        }
        
        /// 获取申请列表
        /// - Parameter clubId: 俱乐部ID
        /// - Returns: 返回结果
        static func getApplyList(clubId: Int) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/club/apply_list", method: .get)
            req.params = ["club_id": clubId]

            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 俱乐部申请处理
        /// - Parameters:
        ///   - applyId: 申请ID
        ///   - status: 处理方式，1-同意，2-拒绝
        /// - Returns: 无返回值
        static func putApplyAgree(applyId: Int, status: Int) -> Promise<Void> {
            var req = HttpRequest(path: "/api/club/apply_agree", method: .put)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = ["apply_id": applyId, "status": status]
            
            return APP.httpClient.request(req).asVoid()
        }
        
        /// 获取俱乐部详情
        /// - Parameter clubId: 俱乐部ID
        /// - Returns: 返回结果
        static func getClubDetail(clubId: Int) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/club/club_detail", method: .get)
            req.params = ["club_id": clubId]

            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 获取俱乐部详情
        /// - Parameter clubId: 俱乐部ID
        /// - Returns: 返回结果
        static func getClubDetail(groupId: String) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/club/club_detail", method: .get)
            req.params = ["group_id": groupId]

            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 群主视角-删除用户申请
        /// - Parameters:
        ///   - clubId: 俱乐部ID
        ///   - ids: 详情的`apply_id` 拼接 2,3
        /// - Returns: 无返回值
        static func deleteClubUsers(clubId: Int, ids: String) -> Promise<Void> {
            var req = HttpRequest(path: "/api/club/club_detail_delete", method: .delete)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = ["club_id": clubId, "ids": ids]
            
            return APP.httpClient.request(req).asVoid()
        }
        
        /// 群主-邀请用户
        /// - Parameters:
        ///   - clubId: 俱乐部ID
        ///   - userId: 用户ID
        /// - Returns: 无返回值
        static func postInviteUser(clubId: Int, userId: Int) -> Promise<Void> {
            var req = HttpRequest(path: "/api/club/invite_club_apply", method: .post)
            req.paramsType = .json
            req.params = ["club_id": clubId, "user_id": userId]
            
            return APP.httpClient.request(req).asVoid()
        }
        
        /// 用户同意加入邀请
        /// - Parameter clubId: 俱乐部ID
        /// - Returns: 无返回值
        static func putInviteAgree(clubId: Int) -> Promise<Void> {
            var req = HttpRequest(path: "/api/club/invite_agree", method: .delete)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = ["club_id": clubId]
            
            return APP.httpClient.request(req).asVoid()
        }
        
        /// 获取俱乐部成员列表
        /// - Parameter clubId: 俱乐部ID
        /// - Returns: 返回结果
        static func getClubUser(clubId: Int) -> Promise<[[String: Any]]> {
            var req = HttpRequest(path: "/api/club/club_user", method: .get)
            req.params = ["club_id": clubId]

            return APP.httpClient.request(req).map({ ($0.json as? [[String: Any]] ?? [])})
        }
        
        /// 获取俱乐部任务设置
        /// - Parameter clubId: 俱乐部ID
        /// - Returns: 返回结果
        static func getClubTask(clubId: Int) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/club/edit_club", method: .get)
            req.params = ["club_id": clubId]

            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 提交俱乐部任务设置
        /// - Parameters:
        ///   - clubId: 俱乐部ID
        ///   - taskWhite: `apply_id`拼接 2,3
        ///   - taskDesc: 任务描述
        ///   - isOpenTask: 是否开启任务
        /// - Returns: 无返回值
        static func putClubTask(clubId: Int, taskWhite: String, taskDesc: String, isOpenTask: Int) -> Promise<Void> {
            var req = HttpRequest(path: "/api/club/edit_club", method: .put)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = ["club_id": clubId, "task_white": taskWhite, "task_desc": taskDesc, "is_open_task": isOpenTask]
            
            return APP.httpClient.request(req).asVoid()
        }
        
        /// 提交任务完成申请
        /// - Parameters:
        ///   - clubId: 俱乐部ID
        ///   - images: 图片 逗号隔开 xxx.png,xxx.png
        ///   - video: 视频链接
        ///   - content: 申请内容
        /// - Returns: 无返回值
        static func postClubTaskAdd(clubId: Int, images: String, video: String, content: String) -> Promise<Void> {
            var req = HttpRequest(path: "/api/club/invite_club_apply", method: .post)
            req.paramsType = .json
            req.params = ["club_id": clubId, "images": images, "video": video, "content": content]
            
            return APP.httpClient.request(req).asVoid()
        }
        
        /// 获取俱乐部每日红包
        /// - Parameter clubId: 俱乐部ID
        /// - Returns: 返回结果
        static func getClubRed(clubId: Int) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/club/edit_club_red", method: .get)
            req.params = ["club_id": clubId]

            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 提交红包设置
        /// - Parameters:
        ///   - clubId: 俱乐部
        ///   - isOpenRed: 是否开启红包
        ///   - redMoney: 红包金额
        ///   - sendRedTime: 红包时间
        /// - Returns: 无返回值
        static func putClubRed(clubId: Int, isOpenRed: Int, redMoney: Int, sendRedTime: String) -> Promise<Void> {
            var req = HttpRequest(path: "/api/club/edit_club_red", method: .put)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = ["club_id": clubId,"is_open_red": isOpenRed, "red_money": redMoney, "send_red_time": sendRedTime]
            
            return APP.httpClient.request(req).asVoid()
        }
        
        /// 获取俱乐部秘书设置
        /// - Parameter clubId: 俱乐部ID
        /// - Returns: 返回结果
        static func getClubManage(clubId: Int) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/club/edit_club_manage", method: .get)
            req.params = ["club_id": clubId]

            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 提交俱乐部秘书设置
        /// - Parameters:
        ///   - clubId: 俱乐部ID
        ///   - userId: 用户ID
        /// - Returns: 无返回值
        static func putClubManage(clubId: Int, userId: Int) -> Promise<Void> {
            var req = HttpRequest(path: "/api/club/edit_club_manage?club_id=\(clubId)", method: .put)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = ["user_id": userId]

            return APP.httpClient.request(req).asVoid()
        }
        
        /// 提交支付金币加入申请
        /// - Parameters:
        ///   - clubId: 俱乐部ID
        ///   - gold: 支付金币
        /// - Returns: 无返回值
        static func postClubPayGold(clubId: Int, gold: Int) -> Promise<Void> {
            var req = HttpRequest(path: "/api/club/club_pay_gold", method: .post)
            req.paramsType = .json
            req.params = ["club_id": clubId, "gold": gold]

            return APP.httpClient.request(req).asVoid()
        }
        
        /// 群主解散俱乐部
        /// - Parameter clubId: 俱乐部ID
        /// - Returns: 无返回值
        static func deleteClub(clubId: Int) -> Promise<Void> {
            var req = HttpRequest(path: "/api/club/club_delete", method: .delete)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = ["club_id": clubId]

            return APP.httpClient.request(req).asVoid()
        }
        
        /// 群成员退出俱乐部
        /// - Parameter clubId: 俱乐部ID
        /// - Returns: 无返回值
        static func logoutClub(clubId: Int) -> Promise<Void> {
            var req = HttpRequest(path: "/api/club/club_logout", method: .delete)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = ["club_id": clubId]

            return APP.httpClient.request(req).asVoid()
        }
        
        /// 升级超级俱乐部
        /// - Parameter clubId: 俱乐部ID
        /// - Returns: 无返回值
        static func putClubUpgrade(clubId: Int) -> Promise<Void> {
            var req = HttpRequest(path: "/api/club/club_upgrade", method: .put)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = ["club_id": clubId]

            return APP.httpClient.request(req).asVoid()
        }
        
        /// 获取俱乐部免打扰
        /// - Parameter clubId: 俱乐部ID
        /// - Returns: 返回结果
        static func getClubDisturb(clubId: Int) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/club/edit_club_disturb", method: .get)
            req.params = ["club_id": clubId]

            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 提交俱乐部免打扰信息
        /// - Parameters:
        ///   - clubId: 俱乐部ID
        ///   - popularity: 人气等级
        ///   - wealthLevel: 财富等级
        ///   - needGold: 解锁金币
        /// - Returns: 无返回值
        static func putClubDisturb(clubId: Int, popularity: Int, wealthLevel: Int, needGold: Int) -> Promise<Void> {
            var req = HttpRequest(path: "/api/club/edit_club_disturb", method: .put)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = ["club_id": clubId, "popularity": popularity, "wealth_level": wealthLevel, "need_gold": needGold]

            return APP.httpClient.request(req).asVoid()
        }
        
        /// 阅后即焚
        /// - Parameter image: 图片json
        /// - Returns: 无返回值
        static func putReadDestroy(image: String) -> Promise<Void> {
            var req = HttpRequest(path: "/api/man/read_destroy", method: .put)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = ["image": image]

            return APP.httpClient.request(req).asVoid()
        }
        
        /// 红包图片-付费查看
        /// - Parameters:
        ///   - image: 图片json
        ///   - userId: 用户ID
        /// - Returns: 无返回值
        static func putLookMoney(image: String, userId: Int) -> Promise<Void> {
            var req = HttpRequest(path: "/api/man/look_money", method: .put)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = ["image": image, "to_user_id": userId]

            return APP.httpClient.request(req).asVoid()
        }
    }
}

// MARK: - 动态页面请求接口
extension HttpApi {
    struct Square {
        
        /// 获取轮播图
        /// - Parameter sign: 类型
        /// - Returns: 返回结果
        static func getBannerList(sign: String = "home") -> Promise<[[String: Any]]> {
            var req = HttpRequest(path: "/api/banner/list", method: .get)
            req.params = ["sign": sign]
            
            return APP.httpClient.request(req).map({ ($0.json as? [[String: Any]] ?? [])})
        }
        
        /// 获取活动信息
        /// - Returns: 返回结果
        static func getMatchList() -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/match_list", method: .get)
            req.params = [:]
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 提交投票报名
        /// - Parameters:
        ///   - matchId: 投票活动ID
        ///   - remark: 投票信息
        ///   - images: 投票图片
        /// - Returns: 无返回值
        static func putMatchApply(matchId: Int, remark: String, images: String) -> Promise<Void> {
            var req = HttpRequest(path: "/api/match_apply", method: .put)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = ["match_id": matchId, "remark": remark, "images": images]
            
            return APP.httpClient.request(req).asVoid()
        }
        
        /// 获取投票用户列表
        /// - Parameters:
        ///   - matchId: 活动ID
        ///   - keyword: 搜索关键词
        /// - Returns: 返回结果
        static func getMatchVoteList(matchId: Int, keyword: String) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/match_vote_list", method: .get)
            req.params = ["match_id": matchId, "keyword": keyword]
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 投票
        /// - Parameters:
        ///   - applyId: 活动申请ID
        ///   - giftId: 礼物ID
        ///   - giftNum: 礼物数量
        /// - Returns: 无返回值
        static func putMatchVote(applyId: Int, giftId: Int, giftNum: Int) -> Promise<Void> {
            var req = HttpRequest(path: "/api/match_vote", method: .put)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = ["apply_id": applyId, "gift_id": giftId, "gift_num": giftNum]
            
            return APP.httpClient.request(req).asVoid()
        }
        
        /// 获取广场动态列表
        /// - Parameter page: 数据页数
        /// - Returns: 返回结果
        static func getDynamicList(page: Int) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/my/dynamic_list", method: .get)
            req.params = ["page": page]
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 获取用户动态列表
        /// - Parameters:
        ///   - userId: 用户ID
        ///   - page: 数据页数
        /// - Returns: 返回结果
        static func getMyDynamicList(userId: Int, page: Int) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/my/my_dynamic_list", method: .get)
            req.params = ["user_id": userId,
                          "page": page]
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 发送动态
        /// - Parameter params: 动态数据
        /// - Returns: 无返回值
        static func sendDynamic(params: [String: Any]) -> Promise<Void> {
            var req = HttpRequest(path: "/api/my/send_dynamic", method: .post)
            req.paramsType = .json
            req.params = params
            
            return APP.httpClient.request(req).asVoid()
        }
        
        /// 动态点赞
        /// - Parameter dynamicId: 动态ID
        /// - Returns: 无返回值
        static func putDynamicLike(dynamicId: Int) -> Promise<Void> {
            var req = HttpRequest(path: "/api/my/dynamic_like", method: .put)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = ["dynamic_id": dynamicId]
            
            return APP.httpClient.request(req).asVoid()
        }
        
        /// 获取活动列表
        /// - Parameters:
        ///   - cityName: 城市名称
        ///   - type: 活动类型
        ///   - sort: asc-近期发布  desc-最新发布
        ///   - page: 数据页数
        /// - Returns: 返回数据
        static func getActivityList(cityName: String, type: Int, sort: String, page: Int) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/activity/activity_list", method: .get)
            req.params = ["city_name": cityName,
                          "type": type,
                          "sort": sort,
                          "is_my_activity": 0,
                          "page": page]
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 获取我发布的活动列表
        /// - Parameter page: 数据页数
        /// - Returns: 返回结果
        static func getMyActivityList(page: Int) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/activity/activity_list", method: .get)
            req.params = ["is_my_activity": 1,
                          "page": page]
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 获取活动详情
        /// - Parameter activityId: 活动ID
        /// - Returns: 返回结果
        static func getActivityDetail(activityId: Int) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/activity/activity_detail", method: .get)
            req.params = ["activity_id": activityId]
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 获取活动申请者列表
        /// - Returns: 返回结果
        static func getActivityApplyList() -> Promise<[[String: Any]]> {
            var req = HttpRequest(path: "/api/activity/apply_list", method: .get)
            req.params = [:]
            
            return APP.httpClient.request(req).map({ ($0.json as? [[String: Any]] ?? [])})
        }
        
        /// 审批活动申请
        /// - Parameters:
        ///   - applyId: 申请ID
        ///   - type: 状态 0-同意，1-拒绝
        /// - Returns: 无返回值
        static func putActivityAgreeApply(applyId: Int, messageId: Int, type: Int) -> Promise<Void> {
            var req = HttpRequest(path: "/api/activity/agree_apply", method: .put)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = ["apply_id": applyId, "message_id": messageId, "type": type]
            
            return APP.httpClient.request(req).asVoid()
        }
        
        /// 已通过活动申请，是否加入活动
        /// - Parameters:
        ///   - applyId: 申请ID
        ///   - status: 1-同意加入，2-拒绝
        /// - Returns: 无返回值
        static func putActivityAgreeJoin(applyId: Int, messageId: Int, status: Int) -> Promise<Void> {
            var req = HttpRequest(path: "/api/activity/agree_join", method: .put)
            req.headers["Content-Type"] = "application/x-www-form-urlencoded"
            req.paramsType = .url
            req.encoding = URLEncoding.httpBody
            req.params = ["apply_id": applyId, "message_id": messageId, "status": status]
            
            return APP.httpClient.request(req).asVoid()
        }
        
        /// 获取目的地列表
        /// - Parameters:
        ///   - activityAreaId: 区域ID
        ///   - keywords: 关键字
        /// - Returns: 返回结果
        static func getActivityAreaList(activityAreaId: Int, keywords: String) -> Promise<[[String: Any]]> {
            var req = HttpRequest(path: "/api/activity/activity_area_list", method: .get)
            req.params = ["activity_area_id": activityAreaId, "keywords": keywords]
            
            return APP.httpClient.request(req).map({ ($0.json as? [[String: Any]] ?? [])})
        }
        
        /// 获取活动标签列表
        /// - Returns: 返回结果
        static func getActivityLabelList() -> Promise<[String: Any]> {
            let req = HttpRequest(path: "/api/activity/activity_label_list", method: .get)
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }

        
        /// 提交运动类型活动-通用
        /// - Parameter params: 请求参数
        /// - Returns: 无返回值
        static func postActivitySport(params: [String: Any]) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/activity/activity_sport", method: .post)
            req.paramsType = .json
            req.params = params
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 发布征婚类活动
        /// - Parameter params: 请求参数
        /// - Returns: 无返回值
        static func postActivityMarry(params: [String: Any]) -> Promise<[String: Any]> {
            var req = HttpRequest(path: "/api/activity/activity_marray", method: .post)
            req.paramsType = .json
            req.params = params
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 获取活动健身运动列表
        /// - Returns: 返回结果
        static func getActivitySportList() -> Promise<[String: Any]> {
            let req = HttpRequest(path: "/api/activity/activity_sport_list", method: .get)
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 获取活动邀约对象列表
        /// - Returns: 返回结果
        static func getActivityObjectList() -> Promise<[String: Any]> {
            let req = HttpRequest(path: "/api/activity/activity_object_list", method: .get)
            
            return APP.httpClient.request(req).map({ ($0.json as? [String: Any] ?? [:])})
        }
        
        /// 获取活动购买方式列表
        /// - Returns: 返回结果
        static func getActivityBuyList() -> Promise<[String: Any]> {
            let req = HttpRequest(path: "/api/activity/activity_buy_list", method: .get)
            
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

