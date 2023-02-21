//
//  IMManager.swift
//  Huatao
//
//  Created on 2023/1/16.
//

import Foundation

class IMManager: NSObject {
    
    static let shared = IMManager()
    
    
    
}

extension IMManager: RCIMGroupInfoDataSource {
    func getGroupInfo(withGroupId groupId: String!, completion: ((RCGroup?) -> Void)!) {
        DispatchQueue.global().async {
            if let groupInfo = RCIM.shared().getGroupInfoCache(groupId) {
                completion?(groupInfo)
            } else {
                HttpApi.Chat.getTeamMaster(teamId: groupId.intValue).done { data in
                    let model = data.kj.model(TeamSettingModel.self)
                    let images = model.listAvatar.compactMap({ $0.avatar }).joined(separator: ",")
                    let groupInfo = RCGroup(groupId: groupId, groupName: model.title, portraitUri: images)
                    RCIM.shared().refreshGroupInfoCache(groupInfo, withGroupId: groupId)
                    DispatchQueue.main.async {
                        completion?(groupInfo)
                    }
                }.catch { error in
                    DispatchQueue.main.async {
                        completion?(nil)
                    }
                }
            }
        }
    }
}

extension IMManager: RCIMUserInfoDataSource {
    
    func getUserInfo(withUserId userId: String!, completion: ((RCUserInfo?) -> Void)!) {
        DispatchQueue.global().async {
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
                    HttpApi.Chat.getFriendDetail(userId: userId.intValue).done { data in
                        let model = data.kj.model(FriendDetailModel.self)
                        let userInfo = RCUserInfo(userId: "\(model.userId)", name: model.name, portrait: model.avatar)
                        RCIM.shared().refreshUserInfoCache(userInfo, withUserId: userId)
                        DispatchQueue.main.async {
                            completion?(userInfo)
                        }
                    }.catch { _ in
                        DispatchQueue.main.async {
                            completion?(nil)
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
