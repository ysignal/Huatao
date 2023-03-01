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
    
    static let state: APPState = .debug
    
    struct SDKKey {
        static let WXAppID = "wx66831e7dc3edf060"
        static let WXSecret = "007b2188fb8752dfa323069bf141ce79"
        static let WXUniversalLink = "https://1pnh9f.xinstall.com.cn/tolink/"
        static let QQUniversalLink = "https://1pnh9f.xinstall.com.cn/qq_conn/102024811"
        
        static let AlipayScheme = "alipay2021003174648764"
        // 融云IM AppKey
        static let RCIMAPPKey = "25wehl3u2v5tw"
        
        static var AliFaceCertifyId: String = ""
    }
    
    struct SettingKey {
        
        static let loginData = "kLoginData"
        
        static let isAgree = "kIsAgree"
        
        static let isLogout = "kIsLogout"
        
        static let isUpdate = "kIsUpdate"
        
        static let lastLogin = "kLastLogin"
        
        static var isUpdateAddressBook: String {
            return "\(APP.loginData.userId)_isUpdateAddressBook"
        }
        
        static var lastApplyContent: String {
            return "\(APP.loginData.userId)_lastApplyContent"
        }
        
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
        let dataStr = loginDataString
        if dataStr.isEmpty {
            return LoginData()
        }
        return dataStr.kj.model(LoginData.self) ?? LoginData()
    }

    /// 最后一个登录的手机号
    @SSDefault(SettingKey.lastLogin, defaultValue: "")
    static var lastLogin: String
    
    /// 是否退出登录返回的登录页面
    @SSDefault(SettingKey.isLogout, defaultValue: false)
    static var isLogout: Bool
    
    /// 是否退出登录返回的登录页面
    @SSDefault(SettingKey.isAgree, defaultValue: false)
    static var isAgree: Bool
    
    /// 是否刷新通讯录
    @SSDefault(SettingKey.isUpdateAddressBook, defaultValue: false)
    static var isUpdateAddressBook: Bool
    
    /// 最后一次好友申请内容
    @SSDefault(SettingKey.lastApplyContent, defaultValue: "")
    static var lastApplyContent: String
    
    /// 用户的详细数据
    static var userInfo = MineUserInfo()
    
    /// 用户的钱包数据
    static var walletInfo = ""
    
    /// QQ、微信授权登录使用的openid
    static var openId: String = ""
    
    /// 微信获取的用户信息
    static var wxModel = WXModel()

    /// 请求用的token
    static var token: String {
        return loginData.tokenType + loginData.accessToken
    }
    
    static var shareUrl: String {
        return "http://huataoh5.gou39.cn?pid=\(loginData.userId)"
    }
    
    static weak var delegate: AppDelegate?
    
    static weak var window: UIWindow?
        
    private static let host: String = APP.state.baseUrl
    
    static var httpClient: HttpClient {
        // 发布环境不打印接口数据
        if state == .release {
            return HttpClient(baseURL: host, plugins: [ParamsPlugin()])
        }
        return HttpClient(baseURL: host, plugins: [ParamsPlugin(), LoggerPlugin()])
    }
    
    static var normalClient = HttpClient(baseURL: "", plugins: [NormalPlugin()])
        
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
        APP.loginDataString = "{}"
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
        HttpApi.Mine.getMyUserInfo().done { data in
            userInfo = data.kj.model(MineUserInfo.self)
            asyncIMUserInfo()
            SSMainAsync {
                completion?()
            }
        }
    }
    
    static func dynamicHeight(for item: DynamicListItem) -> CGFloat {
        let baseHeight: CGFloat = 136
        let contentHeight = item.content.height(from: .ss_regular(size: 14), width: SS.w - 24, lineHeight: 20)
        let mediaHeight: CGFloat = {
            if item.type == 0 {
                return APP.imageHeight(total: item.images.count, lineMax: 3, lineHeight: 86, lineSpace: 2)
            } else if item.type == 1 && !item.video.isEmpty {
                return 150
            }
            return 0
        }()

        return baseHeight + contentHeight + mediaHeight
    }
    
    static func likeHeight(for item: DynamicListItem) -> CGFloat {
        let likeWidthList = item.likeArray.compactMap({ $0.userName.width(from: .ss_regular(size: 12), height: 21) + 20 })
        var line: Int = 0
        let maxWidth = SS.w - 24
        var lineWidth: CGFloat = 0
        likeWidthList.forEach { width in
            if lineWidth + width > maxWidth {
                line += 1
                lineWidth = width
            } else {
                if line == 0 {
                    line += 1
                }
                lineWidth += width
            }
        }
        return CGFloat(line) * 21
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
        RCIM.shared().currentUserInfo = RCUserInfo(userId: "\(APP.loginData.userId)", name: APP.userInfo.name, portrait: APP.userInfo.avatar)
    }
    
    static func setupAPP() {
        UITextView.appearance().tintColor = .ss_theme
        UITextField.appearance().tintColor = .ss_theme
        
        _ = AliyunFaceAuthFacade.init()
                
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        
        RCIM.shared().initWithAppKey(APP.SDKKey.RCIMAPPKey)
        RCIM.shared().addConnectionStatusDelegate(IMManager.shared)
        RCIM.shared().addReceiveMessageDelegate(IMManager.shared)
        RCIM.shared().userInfoDataSource = IMManager.shared
        RCIM.shared().groupInfoDataSource = IMManager.shared
        RCIM.shared().enablePersistentUserInfoCache = true
        // 异步加载本地数据
        DispatchQueue.global().async {
            if let url = Bundle.main.url(forResource: "china_address", withExtension: "json"),
               let data = try? Data(contentsOf: url),
               let list = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [[String: Any]] {
                DataManager.provinceList = list.compactMap({ $0.kj.model(ProvinceModel.self) })
            }
        }
    }
    
}

typealias StringBlock = ((String) -> ())
typealias IntBlock = ((Int) -> ())
typealias BoolBlock = ((Bool) -> ())
typealias NoneBlock = (() -> ())
typealias PushBlock = ((UIViewController) -> ())
