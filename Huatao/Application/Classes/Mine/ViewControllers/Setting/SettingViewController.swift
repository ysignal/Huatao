//
//  SettingViewController.swift
//  Huatao
//
//  Created on 2023/1/26.
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
    
    var list: [SettingMenuItem] = []
    

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
            self?.list = [SettingMenuItem(icon: "ic_setting_face", title: "实名认证", value: APP.userInfo.cardStatus == 1 ? "已实名认证" : ""),
//                          SettingMenuItem(icon: "ic_setting_wechat", title: "微信绑定"),
                          SettingMenuItem(icon: "ic_setting_phone", title: "手机绑定", value: mobileValue),
                          SettingMenuItem(icon: "ic_setting_pwd", title: "支付密码"),
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
        let item = list[indexPath.row]
        switch item.icon {
        case "ic_setting_face":
            if APP.userInfo.cardStatus == 1 {
                // 已认证的用户不能进入认证流程
                return
            }
            let vc = NameCertViewController.from(sb: .task)
            vc.completeBlock = {
                APP.updateUserInfo {
                    self.loadList()
                }
            }
            go(vc)
        case "ic_setting_wechat":
            ThirdLoginManager.shared.wxLogin(in: self) { openid in
                SS.log(openid)
            }
        case "ic_setting_phone":
            let vc = MobileConfirmViewController.from(sb: .mine)
            vc.completeBlock = {
                APP.updateUserInfo {
                    self.loadList()
                }
            }
            go(vc)
        case "ic_setting_pwd":
            if APP.userInfo.cardStatus == 1 {
                // 已认证，进入忘记密码页面
                let vc = ForgetPasswordViewController.from(sb: .mine)
                self.go(vc)
            } else {
                showConfirm(title: "提示", message: "修改支付密码需要先进行实名认证，是否去认证?", buttonTitle: "去认证") {
                    // 未认证，进入认证页面
                    let vc = NameCertViewController.from(sb: .task)
                    vc.completeBlock = {
                        APP.updateUserInfo {
                            self.loadList()
                        }
                    }
                    self.go(vc)
                }
            }
        case "ic_setting_about":
            // 关于
            let vc = AboutViewController.from(sb: .mine)
            go(vc)
        case "ic_setting_clear":
            // 清理缓存
            showConfirm(title: "提示", message: "清除缓存后图片和文件等资源需要重新加载", buttonTitle: "清理", style: .destructive) { [weak self] in
                self?.view.ss.showHUDLoading()
                KingfisherManager.shared.cache.clearDiskCache {
                    self?.loadList()
                }
            }
        case "ic_setting_logout":
            // 退出登录
            showConfirm(title: "提示", message: "是否继续退出登录?", buttonTitle: "继续", style: .destructive) {
                APP.logout()
            }
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
