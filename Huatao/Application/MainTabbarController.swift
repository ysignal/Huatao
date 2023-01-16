//
//  MainTabbarController.swift
//  Huatao
//
//  Created by minse on 2023/1/10.
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 去除系统tabBar的顶部细线
        tabBar.backgroundColor = .white
        tabBar.barStyle = .black
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()
        tabBar.tintColor = .black
        
        addChilds()
        
        selectedIndex = 4
        
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
    }
    
    func addChilds() {
        addChildViewController(home, title: "商城", imageName: "ic_tab_shop", selectedImageName: "ic_tab_shop_sel", index: 0, normal: .ss_99, selected: .ss_theme)
        addChildViewController(task, title: "任务大厅", imageName: "ic_tab_task", selectedImageName: "ic_tab_task_sel", index: 1, normal: .ss_99, selected: .ss_theme)
        addChildViewController(find, title: "发现", imageName: "ic_tab_find", selectedImageName: "ic_tab_find_sel", index: 2, normal: .ss_99, selected: .ss_theme)
        addChildViewController(chat, title: "聊天", imageName: "ic_tab_chat", selectedImageName: "ic_tab_chat_sel", index: 3, normal: .ss_99, selected: .ss_theme)
        addChildViewController(mine, title: "个人中心", imageName: "ic_tab_mine", selectedImageName: "ic_tab_mine_sel", index: 4, normal: .ss_99, selected: .ss_theme)
    }

}
