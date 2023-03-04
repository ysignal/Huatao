//
//  MainTabbarController.swift
//  Huatao
//
//  Created on 2023/1/10.
//

import UIKit

class MainTabbarController: SSTabBarController {
    
    lazy var home: ShopViewController = {
        return ShopViewController.from(sb: .shop)
    }()
    
    lazy var task: TaskViewController = {
        return TaskViewController.from(sb: .task)
    }()
    
    lazy var find: FindViewController = {
        return FindViewController.from(sb: .find)
    }()
    
    lazy var chat: ChatViewController = {
        return ChatViewController.from(sb: .chat)
    }()
    
    lazy var mine: MineViewController = {
        return MineViewController.from(sb: .mine)
    }()
    
    lazy var findView: UIView = {
        let view = UIView(backgroundColor: .white)
        view.addSubview(sendBtn)
        sendBtn.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(37)
            make.height.equalTo(30)
        }
        return view
    }()
    
    lazy var sendBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.image = UIImage(named: "btn_find_send")
        btn.adjustsImageWhenHighlighted = false
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 去除系统tabBar的顶部细线
        tabBar.backgroundColor = .white
        tabBar.barStyle = .black
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()
        tabBar.tintColor = .black
        
        if #available(iOS 13.0, *) {
            let appearance = UITabBarAppearance()
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.ss_99]
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.ss_theme]
            appearance.backgroundImage = UIImage()
            tabBar.standardAppearance = appearance
        } else {
            UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.ss_99], for: .normal)
            UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.ss_theme], for: .selected)
        }
        
        addChilds()
        
        findView.isHidden = true
        tabBar.addSubview(findView)
        findView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalTo(SS.tabBarHeight)
            make.centerX.equalToSuperview()
            make.width.equalTo(50)
        }
        
        selectedIndex = 2
        
        APP.updateUserInfo()
        
        // 连接IM
        RCIM.shared().connect(withToken: APP.loginData.imToken, timeLimit: 5) { code in
            // 消息数据库打开，可以进入到主页面
            SS.log("融云消息数据库打开成功")
        } success: { userId in
            // 连接成功
            SS.log("融云用户\(userId ?? "")连接成功")
        } error: { status in
            switch status {
            case .RC_CONN_TOKEN_INCORRECT:
                // token非法，刷新token进行重连
                SS.log("融云token非法，刷新token进行重连")
            case .RC_CONNECT_TIMEOUT:
                SS.log("融云连接超时")
            default:
                SS.log("融云连接失败：错误码-\(status.rawValue)")
            }
        }
        // 初始化本地数据库
        _ = SSCacheManager.shared
        
        sendBtn.addTarget(find, action: #selector(find.toSend), for: .touchUpInside)
        updateFindView(with: selectedIndex)
    }
    
    func updateFindView(with index: Int) {
        findView.isHidden = index != 2
        tabBar.bringSubviewToFront(findView)
    }
    
    func addChilds() {
        addChildViewController(home, title: "商城", imageName: "ic_tab_shop", selectedImageName: "ic_tab_shop_sel", index: 0, normal: .ss_66, selected: .ss_theme)
        addChildViewController(task, title: "任务大厅", imageName: "ic_tab_task", selectedImageName: "ic_tab_task_sel", index: 1, normal: .ss_66, selected: .ss_theme)
        addChildViewController(find, title: "发现", imageName: "ic_tab_find", selectedImageName: "ic_tab_find_sel", index: 2, normal: .ss_66, selected: .ss_theme)
        addChildViewController(chat, title: "聊天", imageName: "ic_tab_chat", selectedImageName: "ic_tab_chat_sel", index: 3, normal: .ss_66, selected: .ss_theme)
        addChildViewController(mine, title: "个人中心", imageName: "ic_tab_mine", selectedImageName: "ic_tab_mine_sel", index: 4, normal: .ss_66, selected: .ss_theme)
    }
    
    override func selectedTab(at index: Int, isDouble: Bool) {
        updateFindView(with: index)
    }

}
