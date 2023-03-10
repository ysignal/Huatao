//
//  UIViewController+SS.swift
//  SimpleSwift
//
//  Created by user on 2021/4/20.
//

import UIKit

public enum UINavigationBarButtonType {
    case left
    case right
}

public var closePopGestureRecognizerKey = "closePopGestureRecognizer"

extension UIViewController {
    
    public var closePopGestureRecognizer: Bool {
        set {
            objc_setAssociatedObject(self, &closePopGestureRecognizerKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            if let rs = objc_getAssociatedObject(self, &closePopGestureRecognizerKey) as? Bool {
                return rs
            }
            return false
        }
    }
    
    public var navBar: UINavigationBar? {
        var bar : UINavigationBar?
        if self.isKind(of: UINavigationController.self) {
            let navController = self as! UINavigationController
            bar = navController.navigationBar
        } else {
            bar = self.navigationController?.navigationBar
        }
        return bar
    }
    
    public var navTitleColor : UIColor? {
        set {
            var attributes = self.navBar?.titleTextAttributes
            if attributes == nil {
                attributes = [NSAttributedString.Key.foregroundColor : newValue!]
            } else {
                attributes![NSAttributedString.Key.foregroundColor] = newValue!
            }
            
            self.navBar?.titleTextAttributes = attributes
        }
        get {
            return nil
        }
    }
    
    public var navTitleFont : UIFont? {
        set {
            var attributes = self.navBar?.titleTextAttributes
            if attributes == nil {
                attributes = [NSAttributedString.Key.font : newValue!]
            } else {
                attributes![NSAttributedString.Key.font] = newValue
            }
            
            self.navBar?.titleTextAttributes = attributes
        }
        
        get {
            return nil
        }
    }
    
    enum StoryboardName: String {
        case login = "Login"
        case main = "Main"
        case shop = "Shop"
        case task = "Task"
        case find = "Find"
        case chat = "Chat"
        case mine = "Mine"
    }
    
    class func from(sb name: StoryboardName) -> Self {
        return storyboardHelper(name.rawValue)
    }
    
    fileprivate class func storyboardHelper<T>(_ name: String) -> T {
        let storyboard = UIStoryboard(name: name, bundle: nil)
        let identifier = String(describing: self)
        let controller = storyboard.instantiateViewController(withIdentifier: identifier) as! T
        return controller
    }
}

// MARK: -  ??????????????????
extension UIViewController {
    
    /// ??????UIStoryboard??????UIViewController
    public class func storyboard<T: UIViewController>(storyboardName: String, classType: T.Type, identifier: String = T.named) -> T? {
        if identifier.count == 0 {
            return nil
        }
        let vc = UIStoryboard(name: storyboardName, bundle: Bundle.main).instantiateViewController(withIdentifier: identifier) as? T
        return vc
    }
    
    /// ?????????????????????
    public func go(_ viewController: UIViewController, animated: Bool = true) {
        if let nav = self.navigationController {
            nav.pushViewController(viewController, animated: animated)
        } else {
            present(viewController, animated: animated, completion: nil)
        }
    }
    
    /// ?????????????????????
    public func back(isPopToRoot: Bool? = false, animated: Bool = true) {
        if let nav = self.navigationController {
            if nav.viewControllers.count == 1 && nav.viewControllers.first == self, nav.presentingViewController != nil {
                nav.dismiss(animated: true, completion: nil)
            } else {
                if isPopToRoot == true {
                    nav.popToRootViewController(animated: animated)
                }else {
                    nav.popViewController(animated: animated)
                }
            }
        } else {
            self.dismiss(animated: animated, completion: nil)
        }
    }
    
    /// ???????????????????????? special
    @discardableResult
    public func back(svc: UIViewController.Type) -> Bool {
        var isSuccess = false
        if let nav = self.navigationController {
            for vc in nav.viewControllers {
                if vc.isKind(of: svc) {
                    nav.popToViewController(vc, animated: true)
                    isSuccess = true
                    break
                }
            }
        }
        return isSuccess
    }
    
    // MARK: - ??????????????????VC
    public func jump(_ jvc: UIViewController.Type) {
        
        // ??????????????????
        if self.isKind(of: jvc) {
            return
        }
        
        // ??????1?????????navigationController
        var jumpVC: UIViewController?
        var jumpNav: UINavigationController?
        if let nav = self.navigationController {
            for tempVC in nav.viewControllers {
                if tempVC.isKind(of: jvc) {
                    jumpVC = tempVC
                    jumpNav = nav
                    break
                }
            }
        }
        
        if let finnalVC = jumpVC, let finalNav = jumpNav {
            finalNav.popToViewController(finnalVC, animated: true)
            return
        }
        
        // ??????2?????????tabBarController
        if let tabBarC = self.tabBarController, let nav = tabBarC.navigationController {
            for tempVC in nav.viewControllers {
                if tempVC.isKind(of: jvc) {
                    jumpVC = tempVC
                    jumpNav = nav
                    break
                }
            }
        }
        
        if let finnalVC = jumpVC, let finalNav = jumpNav {
            finalNav.popToViewController(finnalVC, animated: true)
            return
        }
        
        // ??????3??????????????????????????????????????????????????????
        var presentingVC = self
        while presentingVC.presentingViewController != nil {
            presentingVC = presentingVC.presentingViewController!
        }
        presentingVC.dismiss(animated: true, completion: nil)
    }
    
    /// ????????????????????????????????????VC
    public func navRemove(_ vc: UIViewController.Type) {
        if let nav = self.navigationController {
            let originVCs = nav.viewControllers
            var newVCs:[UIViewController] = []
            for tempVC in originVCs {
                if !tempVC.isKind(of: vc) {
                    newVCs.append(tempVC)
                }
            }
            nav.viewControllers = newVCs
        }
    }
    /// ????????????????????????????????????[VC]
    public func navRemove(_ vcs: [UIViewController.Type]) {
        if let nav = self.navigationController {
            let originVCs = nav.viewControllers
            var newVCs:[UIViewController] = []
            for tempVC in originVCs {
                var isContain = false
                for classType in vcs {
                    if tempVC.isKind(of: classType) {
                        isContain = true
                        break
                    }
                }
                if isContain == false {
                    newVCs.append(tempVC)
                }
            }
            nav.viewControllers = newVCs
        }
    }
    
}

extension UIViewController{
    /// ??????Sheet
    @discardableResult
    public func showActionSheet(title: String?, message: String?, buttonTitles: [String]? = nil, highlightedButtonIndex: Int? = nil, completion: ((Int) -> Void)? = nil) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let allButtons = buttonTitles ?? [String]()
        
        for index in 0..<allButtons.count {
            let buttonTitle = allButtons[index]
            let action = UIAlertAction(title: buttonTitle, style: .default, handler: { (_) in
                completion?(index)
            })
            alertController.addAction(action)
            // Check which button to highlight
            if let highlightedButtonIndex = highlightedButtonIndex, index == highlightedButtonIndex {
                if #available(iOS 9.0, *) {
                    alertController.preferredAction = action
                }
            }
        }
        let action = UIAlertAction(title: "??????", style: .cancel, handler: { (_) in
        })
        alertController.addAction(action)

        present(alertController, animated: true, completion: nil)
        return alertController
    }
    
    @discardableResult
    func showAlert(
        title: String?,
        message: String?,
        buttonTitles: [String]? = nil,
        highlightedButtonIndex: Int? = nil,
        completion: ((Int) -> Void)? = nil) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        var allButtons = buttonTitles ?? [String]()
        if allButtons.count == 0 {
            allButtons.append("??????")
        }
        
        for index in 0..<allButtons.count {
            let buttonTitle = allButtons[index]
            let action = UIAlertAction(title: buttonTitle, style: .default, handler: { _ in
                completion?(index)
            })
            alertController.addAction(action)
            // Check which button to highlight
            if let highlightedButtonIndex = highlightedButtonIndex, index == highlightedButtonIndex {
                alertController.preferredAction = action
            }
        }
        present(alertController, animated: true, completion: nil)
        return alertController
    }
    
    @discardableResult
    func showConfirm(title: String?,
                     message: String?,
                     buttonTitle: String = "??????",
                     style: UIAlertAction.Style = .default,
                     completion: (() -> Void)? = nil) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "??????", style: .cancel, handler: nil)
        let action = UIAlertAction(title: buttonTitle, style: style, handler: { _ in
            completion?()
        })
        alertController.addAction(cancel)
        alertController.addAction(action)
        alertController.preferredAction = action
        present(alertController, animated: true, completion: nil)
        return alertController
    }
}
