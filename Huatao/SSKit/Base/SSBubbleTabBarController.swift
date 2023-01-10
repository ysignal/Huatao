//
//  SSBubbleTabBarController.swift
//  SimpleSwift
//
//  Created by user on 2021/4/20.
//

import UIKit

open class SSBubbleTabBarController: SSTabBarController {

    public var ss_tabBar: SSBubbleTabBar!
    
    open override var selectedIndex: Int {
        didSet {
            if let vcs = viewControllers, selectedIndex < vcs.count {
                resetBarBackgroundColor(vcs[selectedIndex])
            }
            
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public func setTabbar(_ tabbar: SSBubbleTabBar, isReplace: Bool = true){
        ss_tabBar = tabbar
        tabbar.onSelect = {[weak self] index in
            self?.centerBtnAction()
        }
        self.setValue(tabbar, forKeyPath: "tabBar")
    }
    
    private func centerBtnAction() {
        selectedTab(at: ss_tabBar.centerBtnTag, isDouble: false)
    }
    
    func resetBarBackgroundColor(_ viewController: UIViewController) {
        if let nav = viewController as? UINavigationController, let color = nav.topViewController?.view.backgroundColor {
            ss_tabBar?.backgroundColor = color
        } else if let color = viewController.view.backgroundColor {
            ss_tabBar?.backgroundColor = color
        }
    }
}
