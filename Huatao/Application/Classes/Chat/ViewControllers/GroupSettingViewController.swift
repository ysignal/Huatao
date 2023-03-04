//
//  GroupSettingViewController.swift
//  Huatao
//
//  Created on 2023/2/17.
//  
	

import UIKit

struct GroupSettingSectionItem {
    
    var title: String = ""
    
    /// 类型，0-只有标题，1-箭头，2-箭头加内容，3-开关，4-只有内容没有箭头
    var type: Int = 0
    
    var content: String = ""
    
    var value: Bool = false
    
    /// 事件标识
    var action: String = ""
    
}

class GroupSettingViewController: BaseViewController {

    
    @IBOutlet weak var tableView: UITableView!
    
    var teamId: Int = 0
    
    var model = TeamSettingModel()
    
    var isMaster: Bool = false
    
    /// 是否开启免打扰
    var isBlocked: Bool = false
    
    /// 是否加载完群组数据
    var isDataLoaded: Bool = false
    
    var sections: [[GroupSettingSectionItem]] = []
    
    var updateBlock: StringBlock?
    var clearBlock: NoneBlock?
    var levelBlock: ((RCPushNotificationLevel) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.ss.showHUDLoading()
        requestData()
    }
    
    override func buildUI() {
        fakeNav.title = "群聊设置"

        RCChannelClient.sharedChannelManager().getConversationNotificationLevel(.ConversationType_GROUP, targetId: "\(teamId)") { [weak self] level in
            self?.isBlocked = level == .blocked
            SSMainAsync {
                if self?.isDataLoaded == true {
                    self?.updateListView()
                }
            }
        }
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        
        updateListView()
    }
    
    func requestData() {
        HttpApi.Chat.getTeamMaster(teamId: teamId).done { [weak self] data in
            guard let weakSelf = self else { return }
            weakSelf.model = data.kj.model(TeamSettingModel.self)
            weakSelf.isDataLoaded = true
            IMManager.shared.updateGroup(weakSelf.model)
            SSMainAsync {
                weakSelf.view.ss.hideHUD()
                weakSelf.updateListView()
            }
        }
    }
    
    func updateListView() {
        isMaster = model.userId == APP.loginData.userId
        
        if let index = model.listAvatar.firstIndex(where: { $0.userId == APP.loginData.userId }) {
            model.listAvatar[index].name = model.name
        }
        
        if isMaster {
            sections = [[GroupSettingSectionItem(title: "群聊名称", type: 2, content: model.title, action: "name"),
                         GroupSettingSectionItem(title: "设置管理员", type: 1, action: "manager"),
                         GroupSettingSectionItem(title: "我在本群的昵称", type: 2, content: model.name, action: "rename")],
                        [GroupSettingSectionItem(title: "清空聊天记录", type: 0, action: "clear")],
                        [GroupSettingSectionItem(title: "消息免打扰", type: 3, value: isBlocked, action: "disturb")]]
        } else {
            sections = [[GroupSettingSectionItem(title: "群聊名称", type: 4, content: model.title, action: "name"),
                         GroupSettingSectionItem(title: "我在本群的昵称", type: 2, content: model.name, action: "rename")],
                        [GroupSettingSectionItem(title: "清空聊天记录", type: 0, action: "clear")],
                        [GroupSettingSectionItem(title: "消息免打扰", type: 3, value: isBlocked, action: "disturb")]]
        }
        
        tableView.reloadData()
    }

}

extension GroupSettingViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 200
        default:
            return 46
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return 8
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView(backgroundColor: .ss_f6)
    }
    
    
    
}

extension GroupSettingViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            let list = sections[section - 1]
            return list.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(with: TeamMemberListCell.self)
            cell.config(data: model.listAvatar, isMaster: isMaster)
            cell.delegate = self
            return cell
        }
        let cell = tableView.dequeueReusableCell(with: TeamListItemCell.self)
        let list = sections[indexPath.section - 1]
        let item = list[indexPath.row]
        cell.config(item: item)
        cell.delegate = self
        return cell
    }
        
}

extension GroupSettingViewController: TeamMemberListCellDelegate {
    
    func cellDidTapAdd() {
        let vc = SelectUserViewController.from(sb: .chat)
        vc.teamList = model.listAvatar
        vc.teamId = teamId
        vc.selectType = .add
        vc.completeBlock = { [weak self] users in
            guard let weakSelf = self else { return }
            weakSelf.model.listAvatar.append(contentsOf: users.compactMap({ TeamUser.from($0) }))
            weakSelf.updateListView()
            IMManager.shared.updateGroup(weakSelf.model)
        }
        go(vc)
    }
    
    func cellDidTapDelete() {
        let vc = SelectUserViewController.from(sb: .chat)
        vc.teamList = model.listAvatar
        vc.teamId = teamId
        vc.selectType = .delete
        vc.completeBlock = { [weak self] users in
            guard let weakSelf = self else { return }
            weakSelf.model.listAvatar.removeAll(where: { item in
                users.contains(where: { $0.userId == item.userId })
            })
            weakSelf.updateListView()
            IMManager.shared.updateGroup(weakSelf.model)
        }
        go(vc)
    }
    
    func cellDidTapUser(_ item: TeamUser) {
        let vc = AddFriendViewController.from(sb: .chat)
        vc.userId = item.userId
        go(vc)
    }
    
}

extension GroupSettingViewController: TeamListItemCellDelegate {
    
    func cellDidTap(_ item: GroupSettingSectionItem) {
        if item.type == 4 {
            return
        }
        switch item.action {
        case "name":
            let vc = GroupRenameViewController.from(sb: .chat)
            vc.name = model.title
            vc.targetId = teamId
            vc.completeBlock = { [weak self] str in
                guard let weakSelf = self else { return }
                weakSelf.model.title = str
                weakSelf.updateListView()
                weakSelf.updateBlock?(str)
                IMManager.shared.updateGroup(weakSelf.model)
            }
            go(vc)
        case "manager":
            let vc = SelectUserViewController.from(sb: .chat)
            vc.teamList = model.listAvatar
            vc.teamId = teamId
            vc.selectType = .manager
            go(vc)
        case "rename":
            let vc = GroupRenameViewController.from(sb: .chat)
            vc.type = .user
            vc.targetId = teamId
            vc.name = model.name
            vc.completeBlock = { [weak self] str in
                self?.model.name = str
                self?.updateListView()
            }
            go(vc)
        case "clear":
            showAlert(title: "提示", message: "确定清空\(model.title)的聊天记录？", buttonTitles: ["取消", "清空"], highlightedButtonIndex: 1) { index in
                if index == 1 {
                    RCIMClient.shared().clearHistoryMessages(.ConversationType_GROUP, targetId: "\(self.teamId)", recordTime: 0, clearRemote: false) { [weak self] in
                        SSMainAsync {
                            self?.toast(message: "已清空聊天记录")
                            self?.clearBlock?()
                        }
                    }
                }
            }
        default:
            break
        }
    }
    
    func cellDidChangeValue(_ item: GroupSettingSectionItem) {
        switch item.action {
        case "disturb":
            if item.value {
                RCChannelClient.sharedChannelManager().setConversationNotificationLevel(.ConversationType_GROUP, targetId: "\(teamId)", level: .blocked) { [weak self] in
                    guard let weakSelf = self else { return }
                    SSMainAsync {
                        weakSelf.levelBlock?(.blocked)
                    }
                    _ = HttpApi.Chat.putTeamDisturb(teamId: weakSelf.teamId, isOpenDisturb: 1)
                }
            } else {
                RCChannelClient.sharedChannelManager().setConversationNotificationLevel(.ConversationType_GROUP, targetId: "\(teamId)", level: .allMessage) { [weak self] in
                    guard let weakSelf = self else { return }
                    SSMainAsync {
                        weakSelf.levelBlock?(.allMessage)
                    }
                    _ = HttpApi.Chat.putTeamDisturb(teamId: weakSelf.teamId, isOpenDisturb: 0)
                }
            }
        default:
            break
        }
    }
    
}
