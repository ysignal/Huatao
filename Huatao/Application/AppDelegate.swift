//
//  AppDelegate.swift
//  Huatao
//
//  Created on 2023/1/10.
//

import UIKit
import SwiftDate
import Kingfisher

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        APP.delegate = self
        if #unavailable(iOS 13.0) {
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.rootViewController = SSNavigationController(rootViewController: LoginViewController.from(sb: .login))
            window?.makeKeyAndVisible()
            APP.window = window
            PayManager.register(with: window)
            APP.setupAPP()
        }
        return true
    }
    
    // MARK: App Lifecycle
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let host: String? = {
            if #available(iOS 16.0, *) {
                return url.host()
            } else {
                return url.host
            }
        }()
        if host == "safepay" {
            // 支付跳转支付宝钱包进行支付，处理支付结果, 回调传空，才能在调起支付的地方收到回调
            AlipaySDK.defaultService().processOrder(withPaymentResult: url, standbyCallback: nil)
        }

        return WXApi.handleOpen(url, delegate: self)
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return WXApi.handleOpenUniversalLink(userActivity, delegate: ThirdLoginManager.shared)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // 进入APP清除小红点
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {

    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // 应用销毁
        RCIM.shared().logout()
        
        sleep(2)
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

extension AppDelegate: WXApiDelegate {
    
    
    
}
