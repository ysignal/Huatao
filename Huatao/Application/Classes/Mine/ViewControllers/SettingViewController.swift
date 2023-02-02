//
//  SettingViewController.swift
//  Huatao
//
//  Created by minse on 2023/1/26.
//

import UIKit
import Kingfisher

struct SettingMenuItem {
    
    var icon: String = ""
    
    var title: String = ""
    
    var value: String = ""
    
}

class SettingViewController: BaseViewController {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var menuTV: UITableView!
    
    var list: [SettingMenuItem] = [SettingMenuItem(icon: "ic_setting_face", title: "实名认证"),
                                   SettingMenuItem(icon: "ic_setting_wechat", title: "微信绑定"),
                                   SettingMenuItem(icon: "ic_setting_mobile", title: "手机绑定"),
                                   SettingMenuItem(icon: "ic_setting_about", title: "关于华涛生活"),
                                   SettingMenuItem(icon: "ic_setting_clear", title: "清理缓存"),
                                   SettingMenuItem(icon: "ic_setting_logout", title: "退出登录")]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.ss.showHUDLoading()
        loadList()
    }
    
    override func buildUI() {
        view.backgroundColor = .hex("f6f6f6")
        fakeNav.title = "设置"
        
        menuTV.tableFooterView = UIView()
    }
    
    func loadList() {
        let mobileValue = APP.userInfo.mobile.isEmpty ? "" : (APP.userInfo.mobile.prefix(3) + "****" + APP.userInfo.mobile.suffix(4))
        let cache = KingfisherManager.shared.cache
        cache.calculateDiskStorageSize { [weak self] result in
            self?.view.ss.hideHUD()
            var cacheValue = ""
            switch result {
            case .success(let data):
                let list = ["B", "K", "M", "G", "T"]
                var len = Double(data)
                var index = 0
                while len > 1024 {
                    len = len / 1024
                    index += 1
                }
                cacheValue = index < list.count ?  "\(String(format: "%.2f", len).fixedZero())\(list[index])" : "\(data)B"
            case .failure(_):
                break
            }
            self?.list = [SettingMenuItem(icon: "ic_setting_face", title: "实名认证"),
                          SettingMenuItem(icon: "ic_setting_wechat", title: "微信绑定"),
                          SettingMenuItem(icon: "ic_setting_phone", title: "手机绑定", value: mobileValue),
                          SettingMenuItem(icon: "ic_setting_about", title: "关于华涛生活"),
                          SettingMenuItem(icon: "ic_setting_clear", title: "清理缓存", value: cacheValue),
                          SettingMenuItem(icon: "ic_setting_logout", title: "退出登录")]
            
            self?.menuTV.reloadData()
        }
    }

}

extension SettingViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            break
        case 3:
            // 关于
            let vc = AboutViewController.from(sb: .mine)
            go(vc)
        case 4:
            // 清理缓存
            view.ss.showHUDLoading()
            KingfisherManager.shared.cache.clearDiskCache { [weak self] in
                self?.loadList()
            }
        case 5:
            // 退出登录
            APP.logout()
        default:
            break
        }
    }

}

extension SettingViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: SettingMenuItemCell.self)
        let item = list[indexPath.row]
        cell.config(item: item)
        return cell
    }
    
}
