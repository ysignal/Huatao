//
//  UserDetailViewController.swift
//  Huatao
//
//  Created on 2023/2/17.
//  
	

import UIKit

class UserDetailViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!

    lazy var headerView: UserDetailHeaderView = {
        return UserDetailHeaderView.fromNib()
    }()
    
    var list: [UserFriendItem] = []
    
    var userId: Int = 0
    
    var model = FriendDetailModel()
    
    var clearBlock: NoneBlock?
    var updateBlock: StringBlock?
    var levelBlock: ((RCPushNotificationLevel) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        requestData()
    }
    
    override func buildUI() {
        view.backgroundColor = .hex("f6f6f6")
        
        tableView.backgroundColor = .hex("f6f6f6")
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = UIView()
        tableView.register(nibCell: UserCircleCell.self)
        tableView.register(nibCell: UserFriendItemCell.self)
        
        tableView.reloadData()
    }
    
    func requestData() {
        view.ss.showHUDLoading()
        HttpApi.Chat.getFriendDetail(userId: userId).done { [weak self] data in
            guard let weakSelf = self else { return }
            weakSelf.model = data.kj.model(FriendDetailModel.self)
            SSMainAsync {
                weakSelf.view.ss.hideHUD()
                weakSelf.updateViews()
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.toast(message: error.localizedDescription)
            }
        }
    }
    
    func updateViews() {
        headerView.config(model: model)
        
        IMManager.shared.updateUser(model)

        list = [UserFriendItem(type: 1, title: "查找聊天内容", action: "history"),
                UserFriendItem(type: 2, title: "消息免打扰", isOn: model.isOpenDisturb == 1, action: "disturb"),
                UserFriendItem(type: 1, title: "设置备注", action: "remark"),
                UserFriendItem(type: 2, title: "设为星标", isOn: model.isStar == 1 , action: "star"),
                UserFriendItem(type: 1, title: "下级关系", action: "level"),
                UserFriendItem(type: 1, title: "设置当前聊天背景", action: "background"),
                UserFriendItem(type: 1, title: "清空聊天记录", action: "clear")]
        
        tableView.reloadData()
    }

}

extension UserDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 74
        case 1:
            return 54
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
        
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView(backgroundColor: .hex("f6f6f6"))
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if userId == APP.loginData.userId {
                let vc = MyCircleViewController.from(sb: .mine)
                go(vc)
            } else {
                let vc = FriendCircleViewController.from(sb: .find)
                vc.userId = userId
                go(vc)
            }
        }
    }
    
}

extension UserDetailViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return list.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(with: UserCircleCell.self)
            cell.config(images: model.images)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(with: UserFriendItemCell.self)
            let item = list[indexPath.row]
            cell.config(item: item)
            cell.delegate = self
            return cell
        default:
            break
        }
        return UITableViewCell()
    }
    
}

extension UserDetailViewController: UserFriendItemCellDelegate {
    
    func cellDidTap(_ item: UserFriendItem) {
        switch item.action {
        case "history":
            let vc = MessageHistoryViewController.from(sb: .chat)
            vc.targetId = "\(userId)"
            
            go(vc)
        case "clear":
            RCIMClient.shared().clearHistoryMessages(.ConversationType_PRIVATE, targetId: "\(userId)", recordTime: 0, clearRemote: false) { [weak self] in
                SSMainAsync {
                    self?.toast(message: "已清空聊天记录")
                    self?.clearBlock?()
                }
            }
        case "background":
            let vc = SelectBackgroundViewController.from(sb: .chat)
            vc.userId = userId
            go(vc)
        case "level":
            let vc = NextListViewController.from(sb: .chat)
            vc.userId = userId
            go(vc)
        case "remark":
            let vc = GroupRenameViewController.from(sb: .chat)
            vc.type = .friend
            vc.targetId = userId
            vc.oldName = model.name
            vc.name = model.remarkName
            vc.completeBlock = { [weak self] str in
                self?.model.remarkName = str
                self?.updateViews()
                self?.updateBlock?(str)
            }
            go(vc)
        default:
            break
        }
    }
    
    func cellDidSwitchChange(_ item: UserFriendItem, isOn: Bool) {
        switch item.action {
        case "star":
            _ = HttpApi.Chat.putFriendDetail(userId: userId, isStar: isOn ? 1 : 0)
        case "disturb":
            let level: RCPushNotificationLevel = isOn ? .blocked : .allMessage
            RCChannelClient.sharedChannelManager().setConversationNotificationLevel(.ConversationType_PRIVATE, targetId: "\(userId)", level: level) { [weak self] in
                guard let weakSelf = self else { return }
                SSMainAsync {
                    weakSelf.levelBlock?(level)
                }
                _ = HttpApi.Chat.putFriendDetail(userId: weakSelf.userId, isOpenDisturb: isOn ? 1 : 0)
            }
        default:
            break
        }
    }
    
}
