//
//  ThirdLoginManager.swift
//  Huatao
//
//  Created on 2023/2/28.
//  
	

import Foundation

class ThirdLoginManager: NSObject, WXApiDelegate {
    
    static let shared = ThirdLoginManager()
    
    /// 完成回调
    private var wxComplete: StringBlock?

    func wxLogin(in vc: UIViewController, complete: StringBlock? = nil) {
        wxComplete = complete
        
        let req = SendAuthReq()
        req.scope = "snsapi_userinfo"
        req.state = "lianpai"
        WXApi.sendAuthReq(req, viewController: vc, delegate: self)
    }

    func onResp(_ resp: BaseResp) {
        if let auth = resp as? SendAuthResp, let code = auth.code, !code.isEmpty {
            SS.keyWindow?.ss.showHUDLoading()
            HttpApi.loginAuth(code: code).done { [weak self] data in
                guard let weakSelf = self else { return }
                let response = data.kj.model(WXResponse.self)
                APP.openId = response.openid
                SSMainAsync {
                    SS.keyWindow?.ss.hideHUD()
                    SS.keyWindow?.ss.showHUDLoading(text: "获取用户信息")
                    HttpApi.getWXUserInfo(accessToken: response.accessToken, openid: response.openid).done { json in
                        APP.wxModel = json.kj.model(WXModel.self)
                        SSMainAsync {
                            SS.keyWindow?.ss.hideHUD()
                            weakSelf.wxComplete?(response.openid)
                        }
                    }.catch { error in
                        SSMainAsync {
                            SS.keyWindow?.ss.hideHUD()
                            SS.keyWindow?.toast(message: error.localizedDescription)
                        }
                    }
                }
            }.catch { error in
                SSMainAsync {
                    SS.keyWindow?.ss.hideHUD()
                    SS.keyWindow?.toast(message: error.localizedDescription)
                }
            }
        } else {
            SS.keyWindow?.toast(message: "微信授权失败")
        }
    }
}

struct WXResponse: SSConvertible {
    
    /// 超时时间，秒
    var expiresIn: Int = 0
    
    /// 授权用户唯一标识
    var openid: String = ""
    
    /// 接口调用凭证
    var accessToken: String = ""
    
    /// 用户刷新access_token
    var refreshToken: String = ""
    
    /// 用户授权的作用域
    var scope: String = ""
    
    /// 移动设备授权ID
    var unionid: String = ""
    
}

struct WXModel: SSConvertible {
    
    /// 微信用户唯一标识
    var openid: String = ""
    
    /// 用户昵称
    var nickname: String = ""
    
    /// 用户性别，1-男性，2-女性
    var sex: Int = 0
    
    /// 所在省份
    var province: String = ""
    
    /// 所在城市
    var city: String = ""
    
    /// 所在国家
    var country: String = ""
    
    /// 用户头像
    var healimgurl: String = ""
    
    /// 用户统一标识
    var unionid: String = ""
    
}
