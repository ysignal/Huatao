    //
//  SS.swift
//  SimpleSwift
//
//  Created by user on 2021/4/20.
//

import UIKit
    
/*
 到 2021 年的现在这个时间点，iPhone 的逻辑分辨率宽度进化到了
 320pt（非全面屏）、
 375pt（非全面屏）、
 414pt（非全面屏、全面屏）、
 390pt（全面屏）、
 428pt（全面屏）
 */
typealias SS = SimpleSwift
@objcMembers
public class SimpleSwift: NSObject {
    
    public static let lock = DispatchSemaphore(value: 1)
    public static let w = UIScreen.main.bounds.width
    public static let h = UIScreen.main.bounds.height
    public static let screenScale = UIScreen.main.scale
    public static let bounds = UIScreen.main.bounds
    
    /// app 显示名称
    public static var displayName: String {
        return Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? "SimpleSwift"
    }
    
    /// app 的 bundleid
    public static var bundleID: String {
        return Bundle.main.bundleIdentifier ?? "top.minse.ss"
    }
    
    /// build号
    public static var build: String {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String ?? "1"
    }
    
    /// app版本号
    public static var versionS: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
    
    /// 设备名称
    public static var deviceName: String {
        return UIDevice.current.localizedModel
    }
    
    /// 设备方向
    public static var deviceOrientation: UIDeviceOrientation {
        return UIDevice.current.orientation
    }
    
    /// 主窗口
    public static var keyWindow: UIWindow? {
        if #available(iOS 13.0, *) {
            if let scenes = UIApplication.shared.connectedScenes as? Set<UIWindowScene> {
                for scene in scenes {
                    if scene.activationState == .foregroundActive {
                        return scene.windows.last
                    }
                }
            }
        } else {
            return UIApplication.shared.keyWindow
        }
        return nil
    }
    
    public static var firstWindow: UIWindow? {
        if #available(iOS 13.0, *) {
            if let scenes = UIApplication.shared.connectedScenes as? Set<UIWindowScene> {
                for scene in scenes {
                    if scene.activationState == .foregroundActive {
                        return scene.windows.first
                    }
                }
            }
        } else {
            return UIApplication.shared.windows.first
        }
        return nil
    }
    
    /// 当前系统版本
    public static var systemVersion: String {
        return UIDevice.current.systemVersion
    }
    
    /// 判断设备是不是iPhoneX
    public static var isX: Bool {
        if UIDevice.current.userInterfaceIdiom == .pad { return false }

        let size = UIScreen.main.bounds.size
        let notchValue: Int = Int(size.width / size.height * 100)
        if 216 == notchValue || 46 == notchValue { return true }
        return false
    }

    //刘海高度
    public static var bangScreenHeight: CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return 0
        }
        let size = UIScreen.main.bounds.size
        let notchValue: Int = Int(size.width / size.height * 100)
        if (216 == notchValue || 46 == notchValue) {
            return 34
        }
        return 0
    }
    
    /// TableBar距底部区域高度
    public static var safeBottomHeight: CGFloat {
        return isX ? 34 : 0
    }
    
    /// tabBar高度
    public static var tabBarHeight: CGFloat {
        return isX ? 83 : 49
    }
    
    /// 状态栏的高度
    public static var statusBarHeight: CGFloat {
        if #available(iOS 13.0, *) {
            if let scenes = UIApplication.shared.connectedScenes as? Set<UIWindowScene> {
                for scene in scenes {
                    if scene.activationState == .foregroundActive, let manager = scene.statusBarManager {
                        return manager.statusBarFrame.height
                    }
                }
            }
        }
        return isX ? 44 : 20
    }
    
    /// 导航栏的高度
    public static var navBarHeight: CGFloat {
        return 44.0
    }
    
    /// 状态栏和导航栏的高度
    public static var statusWithNavBarHeight: CGFloat {
        return statusBarHeight + navBarHeight
    }
    
    /// 1像素大小
    static var onePixel: CGFloat {
        return 1 / UIScreen.main.scale
    }
    
    /// 页面尺寸宽度适配，默认以iPhone X为标准
    public static func scaleW(_ width: CGFloat, fit: CGFloat = 375.0) -> CGFloat {
        return w / fit * width
    }
    
    /// 页面尺寸高度适配，默认以iPhone X为标准
    public static func scaleH(_ height: CGFloat, fit: CGFloat = 812.0) -> CGFloat {
        return h / fit * height
    }
    
    /// 页面尺寸适配，默认以iPhone X为标准
    public static func scale(_ value: CGFloat) -> CGFloat {
        return scaleW(value)
    }

    /// 根据控制器获取顶层控制器
    public static func topVC(_ viewController: UIViewController?) -> UIViewController? {
        guard let currentVC = viewController else {
            return nil
        }
        if let nav = currentVC as? UINavigationController {
            // nav控制器
            return topVC(nav.visibleViewController)
        } else if let tabC = currentVC as? UITabBarController {
            // tabBar的根控制器
            return topVC(tabC.selectedViewController)
        } else if let presentVC = currentVC.presentedViewController {
            // modal出来的控制器
            return topVC(presentVC)
        } else {
            // 返回控制器
            return currentVC
        }
    }
    
    /// 顶层控制器的navigationController
    public static var topNavVC: UINavigationController? {
        if let topVC = self.topVC() {
            if let nav = topVC.navigationController {
                return nav
            } else {
                return SSNavigationController(rootViewController: topVC)
            }
        }
        return nil
    }
    
    /// 根据window获取顶层控制器
    public static func topVC() -> UIViewController? {
        var window = keyWindow
        //是否为当前显示的window
        if window?.windowLevel != UIWindow.Level.normal {
            let windows = UIApplication.shared.windows
            for  windowTemp in windows{
                if windowTemp.windowLevel == UIWindow.Level.normal{
                    window = windowTemp
                    break
                }
            }
        }
        let vc = window?.rootViewController
        return topVC(vc)
    }
    
    static func isSimulator() -> Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
    
}

enum SSNotificationKey {
    
}

public func SSMainAsync(after: TimeInterval = 0, handler: @escaping (() -> Void)) {
    DispatchQueue.main.asyncAfter(deadline: .now() + after) {
        handler()
    }
}
