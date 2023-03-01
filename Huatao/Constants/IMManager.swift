//
//  IMManager.swift
//  Huatao
//
//  Created on 2023/1/16.
//

import Foundation

class IMManager: NSObject {
    
    static let shared = IMManager()
    
    func updateUser(_ model: FriendDetailModel, completion: ((RCUserInfo?) -> Void)? = nil) {
        // 预加载背景图
        DataManager.cacheImage(model.backgroundImg)
        // 保存数据到临时缓存
        let name = model.remarkName.isEmpty ? model.name : model.remarkName
        let userInfo = RCUserInfo(userId: "\(model.userId)", name: name, portrait: model.avatar)
        RCIM.shared().refreshUserInfoCache(userInfo, withUserId: "\(model.userId)")
        // 保存数据到本地数据库
        let imUser = IMUserInfo.from(model)
        SSCacheSaver.saveIMUser(imUser)
        // 闭包回调
        DispatchQueue.main.async {
            completion?(userInfo)
        }
    }
    
    func updateGroup(_ model: TeamSettingModel, completion: ((RCGroup?) -> Void)? = nil) {
        // 保存数据到本地数据库
        let imGroup = IMGroupInfo.from(model)
        SSCacheSaver.saveIMGroup(imGroup)
        // 保存数据到临时缓存
        let groupInfo = RCGroup(groupId: "\(model.teamId)", groupName: model.title, portraitUri: imGroup.images)
        RCIM.shared().refreshGroupInfoCache(groupInfo, withGroupId: "\(model.teamId)")
        // 闭包回调
        DispatchQueue.main.async {
            completion?(groupInfo)
        }
    }
}

extension IMManager: RCIMGroupInfoDataSource {
    func getGroupInfo(withGroupId groupId: String!, completion: ((RCGroup?) -> Void)!) {
        DispatchQueue.global().async { [weak self] in
            if let groupInfo = RCIM.shared().getGroupInfoCache(groupId) {
                completion?(groupInfo)
            } else {
                SSCacheLoader.loadIMGroup(from: groupId.intValue) { data in
                    if let group = data {
                        // 先返回本地数据库数据
                        let groupInfo = RCGroup(groupId: groupId, groupName: group.title, portraitUri: group.images)
                        RCIM.shared().refreshGroupInfoCache(groupInfo, withGroupId: groupId)
                        // 闭包回调
                        DispatchQueue.main.async {
                            completion?(groupInfo)
                        }
                        // 判断是否需要更新本地数据库数据
                        let now = Date().toString(.custom(APP.dateFormat))
                        if group.updated != now {
                            // 请求网络数据
                            HttpApi.Chat.getTeamMaster(teamId: groupId.intValue).done { data in
                                let model = data.kj.model(TeamSettingModel.self)
                                self?.updateGroup(model, completion: completion)
                            }
                        }
                    } else {
                        HttpApi.Chat.getTeamMaster(teamId: groupId.intValue).done { data in
                            let model = data.kj.model(TeamSettingModel.self)
                            self?.updateGroup(model, completion: completion)
                        }.catch { error in
                            // 闭包回调
                            DispatchQueue.main.async {
                                completion?(nil)
                            }
                        }
                    }
                }
            }
        }
    }
}

extension IMManager: RCIMUserInfoDataSource {
    
    func getUserInfo(withUserId userId: String!, completion: ((RCUserInfo?) -> Void)!) {
        DispatchQueue.global().async { [weak self] in
            if let userInfo = RCIM.shared().getUserInfoCache(userId) {
                DispatchQueue.main.async {
                    completion?(userInfo)
                }
            } else {
                if userId.intValue == APP.loginData.userId {
                    let userInfo = RCUserInfo(userId: userId, name: APP.userInfo.name, portrait: APP.userInfo.avatar)
                    RCIM.shared().refreshUserInfoCache(userInfo, withUserId: userId)
                    DispatchQueue.main.async {
                        completion?(userInfo)
                    }
                } else {
                    SSCacheLoader.loadIMUser(from: userId.intValue) { data in
                        if let user = data {
                            // 先返回本地数据库的数据
                            let name = user.remark.isEmpty ? user.name : user.remark
                            let userInfo = RCUserInfo(userId: "\(user.userId)", name: name, portrait: user.avatar)
                            RCIM.shared().refreshUserInfoCache(userInfo, withUserId: userId)
                            // 闭包回调
                            DispatchQueue.main.async {
                                completion?(userInfo)
                            }
                            // 判断是否需要更新本地数据库
                            let now = Date().toString(.custom(APP.dateFormat))
                            if user.updated != now {
                                // 请求网络数据
                                HttpApi.Chat.getFriendDetail(userId: userId.intValue).done { data in
                                    let model = data.kj.model(FriendDetailModel.self)
                                    self?.updateUser(model, completion: completion)
                                }
                            }
                        } else {
                            HttpApi.Chat.getFriendDetail(userId: userId.intValue).done { data in
                                let model = data.kj.model(FriendDetailModel.self)
                                self?.updateUser(model, completion: completion)
                            }.catch { _ in
                                // 闭包回调
                                DispatchQueue.main.async {
                                    completion?(nil)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

extension IMManager: RCIMConnectionStatusDelegate {
    
    func onRCIMConnectionStatusChanged(_ status: RCConnectionStatus) {
        switch status {
        case .ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT:
            // 其他设备登录，被踢下线
            SSMainAsync {
                SS.keyWindow?.rootViewController?.showAlert(title: "提示", message: "你的账号已在其他设备上登录，请重新登录", buttonTitles: ["确定"], completion: { _ in
                    APP.logout()
                })
            }
        case .ConnectionStatus_DISCONN_EXCEPTION:
            SSMainAsync {
                SS.keyWindow?.rootViewController?.showAlert(title: "提示", message: "你的IM账号已被封禁，请重新登录", buttonTitles: ["确定"], completion: { _ in
                    APP.logout()
                })
            }
        case .ConnectionStatus_Timeout:
            // 自动链接超时，需要做超时处理，然后主动调用connectWithToken进行连接
            break
        default:
            break
        }
    }
    
}

extension IMManager: RCIMReceiveMessageDelegate {

    func onRCIMReceived(_ message: RCMessage!, left nLeft: Int32, offline: Bool, hasPackage: Bool) {
        // 接收到新消息
        
    }
    
    func onRCIMCustomLocalNotification(_ message: RCMessage!, withSenderName senderName: String!) -> Bool {
        // APP处于后台时是否显示自定义本地通知，返回false显示默认本地通知
        return false
    }
    
    func onRCIMCustomAlertSound(_ message: RCMessage!) -> Bool {
        // APP处于前台时是否播放自定义提示音，返回false播放默认提示音
        return false
    }
    
    func messageDidRecall(_ message: RCMessage!) {
        // 消息被撤回
    }
    
    func interceptMessage(_ message: RCMessage!) -> Bool {
        // 是否拦截该消息，不在UI上显示
        return false
    }
    
}
