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

    override func viewDidLoad() {
        super.viewDidLoad()
        

        requestData()
    }
    
    override func buildUI() {
        fakeNav.title = "群聊设置"
        
        RCIMClient.shared().getConversationNotificationStatus(.ConversationType_GROUP, targetId: "\(teamId)") { [weak self] status in
            self?.isBlocked = status == .DO_NOT_DISTURB
            if self?.isDataLoaded == true {
                self?.updateListView()
            }
        }
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        
        updateListView()
    }
    
    func requestData() {
        view.ss.showHUDLoading()
        HttpApi.Chat.getTeamMaster(teamId: teamId).done { [weak self] data in
            self?.model = data.kj.model(TeamSettingModel.self)
            self?.isDataLoaded = true
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.updateListView()
            }
        }
    }
    
    func updateListView() {
        isMaster = model.userId == APP.loginData.userId
    
        if isMaster {
            sections = [[GroupSettingSectionItem(title: "群聊名称", type: 2, content: model.title),
                         GroupSettingSectionItem(title: "群管理", type: 1),
                         GroupSettingSectionItem(title: "设置管理员", type: 1),
                         GroupSettingSectionItem(title: "我在本群的昵称", type: 2, content: "")],
                        [GroupSettingSectionItem(title: "清空聊天记录", type: 0)],
                        [GroupSettingSectionItem(title: "消息免打扰", type: 3, value: model.isOpenDisturb == 1)]]
        } else {
            sections = [[GroupSettingSectionItem(title: "群聊名称", type: 4, content: model.title),
                         GroupSettingSectionItem(title: "我在本群的昵称", type: 2, content: "")],
                        [GroupSettingSectionItem(title: "清空聊天记录", type: 0)],
                        [GroupSettingSectionItem(title: "消息免打扰", type: 3, value: isBlocked)]]
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
        return cell
    }
    
    
    
}

extension GroupSettingViewController: TeamMemberListCellDelegate {
    
    func cellDidTapAdd() {
        
    }
    
    func cellDidTapDelete() {
        
    }
    
    func cellDidTapUser(_ item: TeamUser) {
        let vc = AddFriendViewController.from(sb: .chat)
        vc.userId = item.userId
        go(vc)
    }
    
}

extension GroupSettingViewController: TeamListItemCellDelegate {
    
    func cellDidTap(_ model: GroupSettingSectionItem) {
        
    }
    
    func cellDidChangeValue(_ model: GroupSettingSectionItem) {
        switch model.title {
        case "消息免打扰":
            if model.value {
                RCChannelClient.sharedChannelManager().setConversationTypeNotificationLevel(.ConversationType_GROUP, level: .blocked, success: nil)
            } else {
                RCChannelClient.sharedChannelManager().setConversationTypeNotificationLevel(.ConversationType_GROUP, level: .allMessage, success: nil)
            }
        default:
            break
        }
    }
    
}
