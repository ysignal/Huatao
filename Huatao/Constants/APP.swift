//
//  APP.swift
//  SimpleSwift
//
//  Created by user on 2021/4/21.
//

import UIKit

enum APPState {
    case debug
    case debugOnline
    case release
    
    var baseUrl: String {
        switch self {
        case .debug:
            return "http://192.168.1.17:8765"
        case .debugOnline:
            return ""
        case .release:
            return ""
        }
    }
    
    var uploadUrl: String {
        return baseUrl + "/api/upload/uploadImage"
    }
}

public struct APP {
    
    static let state: APPState = .debug
    
    struct SDKKey {
        static let WXAppID = "wx66831e7dc3edf060"
        static let WXSecret = "007b2188fb8752dfa323069bf141ce79"
        static let WXUniversalLink = "https://1pnh9f.xinstall.com.cn/tolink/"
        static let QQUniversalLink = "https://1pnh9f.xinstall.com.cn/qq_conn/102024811"
        // 百度定位 AppKey
        static let BMKKey = "QA3aN2b86WKGNp2GbynA5bewEWjY0zud"
        
        static let AlipayScheme = "alipay2021003143628782"
        // 环信IM AppKey
        static let EMAPPKey = "1125220812103311#rujiaolove"
        // 极光推送 AppKey
        static let JPushAppKey = "434c716684887b293e1b73a6"
        // 友盟统计 AppKey
        static let UMAppKey = ""
        // Zego音视频 AppID
        static let ZegoAppID: UInt32 = 1390936217
        // Zego音视频 AppSign
        static let ZegoAppSign: String = "fa54d4647ca6a997338dd916e21d6a11f7071bd143fa10a71fd6aac71a87beb9"
    }
    
    struct SettingKey {
        
        static let loginData = "kLoginData"
        
        static let isLogout = "kIsLogout"
        
        static let isUpdate = "kIsUpdate"
        
        static let lastLogin = "kLastLogin"
        
    }
    
    static var name: String = "华涛生活"
    
    /// 服务器列表数据每页数量
    static var pageLimit: Int = 15
    
    /// 通用的倒计时计数
    static var generateCount: Int = 60
    
    /// 当前聊天会话ID
    static var currentEaseId: String = ""
    
    /// 登录返回的用户数据
    static var loginData = ""
    
    /// 用户的详细数据
    static var userInfo = ""
    
    /// 用户的钱包数据
    static var walletInfo = ""

    /// 请求用的token
    static var token: String {
        return ""
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
        return state == .debug || state == .debug
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
        UserDefaults.standard.setValue(true, forKey: APP.SettingKey.isLogout)
        UserDefaults.standard.set("", forKey: APP.SettingKey.loginData)
        UserDefaults.standard.synchronize()
        // 退出环信
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

}

typealias StringBlock = ((String) -> ())
typealias IntBlock = ((Int) -> ())
typealias BoolBlock = ((Bool) -> ())
typealias NoneBlock = (() -> ())
typealias PushBlock = ((UIViewController) -> ())
