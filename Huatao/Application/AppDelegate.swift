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
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = SSNavigationController(rootViewController: LoginViewController.from(sb: .login))
        window?.makeKeyAndVisible()
        APP.window = window
        PayManager.register(with: window)
        APP.setupAPP()
        return true
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

