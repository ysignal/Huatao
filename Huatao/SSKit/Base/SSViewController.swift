//
//  SSViewController.swift
//  SimpleSwift
//
//  Created by user on 2021/4/20.
//

import UIKit

struct ListConfig {
    
}

open class SSViewController: UIViewController {
    
    open var fakeNav: SSNavigationBar = SSNavigationBar()
    
    private lazy var sceenshotTF: UITextField = {
        let tf = UITextField()
        tf.isSecureTextEntry = true
        tf.isEnabled = false
        return tf
    }()
    
    private lazy var sceenshotLabel: UILabel = {
        return UILabel(text: "禁止截图", textColor: .black, textFont: .ss_semibold(size: 15))
    }()
    
    deinit {
        // 移除通知监听者
        removeNotifacationObserver()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.navigationBar.tintColor = UIColor.white
        edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        if #available(iOS 11.0, *) {
            extendedLayoutIncludesOpaqueBars = true
        }else{
            automaticallyAdjustsScrollViewInsets = false
        }
        buildUI()
        view.bringSubviewToFront(fakeNav)
    }
    
    func buildUI() {
        
    }
    
    // MARK: - 导航条上左右按钮的点击事件
    open func handleNavigationBarButton(buttonType : UINavigationBarButtonType) {
        if buttonType == .left {
            back()
        }
    }
    
    open func removeNotifacationObserver(){
        NotificationCenter.default.removeObserver(self)
    }
    
    open func hideNavBar(){
        navigationController?.isNavigationBarHidden = true
    }
    
    open func showNavBar(){
        hideFakeNavBar()
        navigationController?.isNavigationBarHidden = false
    }
    
    open func showFakeNavBar(){
        hideNavBar()
        fakeNav.isHidden = false
        view.addSubview(fakeNav)
        fakeNav.snp.makeConstraints({
            $0.left.right.top.equalToSuperview()
            $0.height.equalTo(SS.statusWithNavBarHeight)
        })
    }
    
    open func hideFakeNavBar(){
        fakeNav.isHidden = true
    }
    
    private var customStatusBarStyle: UIStatusBarStyle = .default
    
    /// 状态栏类型
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return customStatusBarStyle
    }
    
    private var customIsStatusBarHidden: Bool = false

    /// 状态栏
    open override var prefersStatusBarHidden: Bool {
        return customIsStatusBarHidden
    }
    
    open func blackStateBar() {
        customStatusBarStyle = .default
    }
    
    open func whiteStateBar() {
        customStatusBarStyle = .lightContent
    }
    
    open func hiddenStateBar() {
        customIsStatusBarHidden = true
    }
    
    open func showStateBar() {
        customIsStatusBarHidden = false
    }
    
    open func sceenshot(bind view: UIView) {
        if #available(iOS 13.2, *), let theView = sceenshotTF.subviews.first {
            self.view.addSubview(sceenshotLabel)
            sceenshotLabel.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
            
            view.removeFromSuperview()
            self.view.addSubview(theView)
            let constant = fakeNav.isHidden ? 0 : SS.statusWithNavBarHeight
            theView.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(constant)
                make.left.bottom.right.equalToSuperview()
            }

            theView.isUserInteractionEnabled = true
            theView.addSubview(view)
            view.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
}

// 通知相关
extension SSViewController {
    
    /// 添加公共通知，默认没调用
    @objc open func addPublicNotification() {
        // app进入前台
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        // app进入后台
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didEnterBackGround),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
    }
    
    //MARK: - 以下通知方法只在调用 ‘addPublicNotification()’方法后生效
    /// 进入前台
    @objc open func didBecomeActive() {
        // should overwrite
        
    }
    
    /// 进入后台
    @objc open func didEnterBackGround() {
        // should overwrite
        
    }
}
