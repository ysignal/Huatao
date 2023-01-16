//
//  APP.swift
//  SimpleSwift
//
//  Created by user on 2021/4/21.
//

import UIKit
import IQKeyboardManagerSwift

enum APPState {
    case debug
    case release
    
    var baseUrl: String {
        switch self {
        case .debug:
            return "http://192.168.1.17:8765"
        case .release:
            return "http://huatao.gou39.cn/"
        }
    }
    
    var uploadUrl: String {
        return baseUrl + "/api/upload/uploadImage"
    }
}

public struct APP {
    
    static let state: APPState = .release
    
    struct SDKKey {
        static let WXAppID = "wx66831e7dc3edf060"
        static let WXSecret = "007b2188fb8752dfa323069bf141ce79"
        static let WXUniversalLink = "https://1pnh9f.xinstall.com.cn/tolink/"
        static let QQUniversalLink = "https://1pnh9f.xinstall.com.cn/qq_conn/102024811"
        // 百度定位 AppKey
        static let BMKKey = "QA3aN2b86WKGNp2GbynA5bewEWjY0zud"
        
        static let AlipayScheme = "alipay2021003143628782"
        // 融云IM AppKey
        static let RCIMAPPKey = "25wehl3u2v5tw"
        // 极光推送 AppKey
        static let JPushAppKey = "434c716684887b293e1b73a6"
    }
    
    struct SettingKey {
        
        static let loginData = "kLoginData"
        
        static let isLogout = "kIsLogout"
        
        static let isUpdate = "kIsUpdate"
        
        static let lastLogin = "kLastLogin"
        
    }
    
    static var name: String = "华涛生活"

    /// 一键登录倒计时计数
    static var authCount: Int = 0
    
    /// 手机号码倒计时计数
    static var phoneCount: Int = 0
    
    /// 当前聊天会话ID
    static var currentEaseId: String = ""
    
    /// 登录返回的用户数据字符串
    @SSDefault(SettingKey.loginData, defaultValue: "")
    static var loginDataString: String
    
    /// 登录返回的用户数据模型
    static var loginData: LoginData {
        return loginDataString.kj.model(LoginData.self) ?? LoginData()
    }

    /// 最后一个登录的手机号
    @SSDefault(SettingKey.lastLogin, defaultValue: "")
    static var lastLogin: String
    
    /// 是否退出登录返回的登录页面
    @SSDefault(SettingKey.isLogout, defaultValue: false)
    static var isLogout: Bool
    
    /// 用户的详细数据
    static var userInfo = UserInfo()
    
    /// 用户的钱包数据
    static var walletInfo = ""

    /// 请求用的token
    static var token: String {
        return loginData.tokenType + loginData.accessToken
    }
    
    static weak var delegate: AppDelegate?
    
    static weak var window: UIWindow?
        
    private static let host: String = APP.state.baseUrl
    
    static var httpClient: HttpClient {
        // 发布环境不打印接口数据
        if state == .release {
            return HttpClient(baseURL: host, plugins: [ParamsPlugin(), LoggerPlugin()])
        }
        return HttpClient(baseURL: host, plugins: [ParamsPlugin(), LoggerPlugin()])
    }
        
    static let dateFormat: String = "yyyy-MM-dd"
    static let dateFullFormat: String = "yyyy-MM-dd hh:mm:ss"
    static let dateActivity: String = "yyyy年MM月dd日hh时"

    static func isDebug() -> Bool {
        return state == .debug || state == .release
    }
    
    /// 切换到APP主页
    static func switchMainViewController() {
        if #available(iOS 13.0, *) {
            window?.rootViewController = MainTabbarController.from(sb: .main)
        } else {
            delegate?.window?.rootViewController = MainTabbarController.from(sb: .main)
        }
    }
    
    /// 切换到登录页面
    static func switchLoginViewController() {
        if #available(iOS 13.0, *) {
            window?.rootViewController = SSNavigationController(rootViewController: LoginViewController.from(sb: .login))
        } else {
            delegate?.window?.rootViewController = SSNavigationController(rootViewController: LoginViewController.from(sb: .login))
        }
    }
    
    /// 退出登录，注销用户
    static func logout() {
        APP.isLogout = true
        APP.loginDataString = ""
        // 退出IM
        RCIM.shared().logout()
        APP.switchLoginViewController()
    }
    
    @discardableResult
    static func saveImage(image: UIImage, name: String) -> String {
        let path = SS.tmpPath + "/image/" + name
        let data = image.pngData()
        try? data?.write(to: URL(fileURLWithPath: path))
        return path
    }
    
    static func imagePath(for name: String) -> String {
        return SS.tmpPath + "/image/" + name
    }
    
    static func isAlipayAppInstalled() -> Bool {
        if let url = URL(string: "alipay://") {
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }
    
    // 更新用户信息
    static func updateUserInfo(completion: NoneBlock? = nil) {
        HttpApi.Login.getUserInfo().done { data in
            userInfo = data.kj.model(UserInfo.self)
            asyncIMUserInfo()
            SSMainAsync {
                completion?()
            }
        }
    }
    
    static func imageHeight(total: Int, lineMax: Int, lineHeight: CGFloat, lineSpace: CGFloat) -> CGFloat {
        var line = total / lineMax
        let rem = total % lineMax
        if rem > 0 {
            line += 1
        }
        let imageHeight = CGFloat(line) * (lineHeight + lineSpace) - lineSpace
        return imageHeight
    }
    
    static func asyncIMUserInfo() {
        
    }
    
    static func setupAPP() {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        
        RCIM.shared().initWithAppKey(APP.SDKKey.RCIMAPPKey)
        RCIM.shared().addConnectionStatusDelegate(IMManager.shared)
        RCIM.shared().addReceiveMessageDelegate(IMManager.shared)
    }
    
}

typealias StringBlock = ((String) -> ())
typealias IntBlock = ((Int) -> ())
typealias BoolBlock = ((Bool) -> ())
typealias NoneBlock = (() -> ())
typealias PushBlock = ((UIViewController) -> ())