//
//  SelectUserViewController.swift
//  Huatao
//
//  Created on 2023/2/17.
//  
	

import UIKit

struct HandAddTeamResult: SSConvertible {
    
    var teamId: Int = 0
    
}

enum SelectUserType {
    case new // 创建群聊
    case add // 拉人进群
    case delete // 踢人出群
    case manager // 设置管理员
}

class SelectUserViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var actionView: UIView!
    @IBOutlet weak var searchTF: UITextField!
    
    private lazy var indexView: SSIndexView = {
        let view = SSIndexView().titleColor(.hex("646566")).highlightTitleColor(.hex("FF8100")).titleFont(.systemFont(ofSize: 12)).indicatorRightMargin(5)
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    lazy var completeBtn: SSButton = {
        let btn = SSButton(type: .custom)
        btn.loadOption([.titleColor(.white), .font(.ss_regular(size: 14)), .backgroundColor(.ss_theme), .cornerRadius(4), .title("完成")])
        return btn
    }()
    
    private var sectionIndexArray: [String] = []
    
    private var contactDict: [String: [FriendListItem]] = [:]
    
    private var keyword: String = ""
    
    private var selectedItems: [FriendListItem] = []
    
    var teamId: Int = 0
    
    var teamList: [TeamUser] = []
    
    var selectType: SelectUserType = .new
    
    var completeBlock: (([FriendListItem]) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func buildUI() {
        switch selectType {
        case .new:
            fakeNav.title = "选择联系人"
        case .add:
            fakeNav.title = "选择联系人"
        case .delete:
            fakeNav.title = "删除成员"
        case .manager:
            fakeNav.title = "设置管理员"
        }
        fakeNav.backgroundColor = .ss_f6
        view.backgroundColor = .ss_f6
        
        fakeNav.addSubview(completeBtn)
        completeBtn.snp.makeConstraints { make in
            make.width.equalTo(50)
            make.height.equalTo(26)
            make.right.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-9)
        }
        completeBtn.addTarget(self, action: #selector(toCompleteSelect), for: .touchUpInside)
        
        view.addSubview(indexView)
        indexView.snp.makeConstraints { make in
            make.top.right.bottom.equalToSuperview()
            make.width.equalTo(36)
        }
        
        tableView.allowsMultipleSelection = true
        tableView.backgroundColor = .ss_f6
        tableView.tableFooterView = UIView()
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        
        searchTF.delegate = self
        actionView.addGesture(.tap) { tap in
            if tap.state == .ended {
                self.searchTF.becomeFirstResponder()
            }
        }
        
        updateListView()
    }
    
    func updateListView() {
        contactDict = [:]
        sectionIndexArray = []
        
        if selectType == .delete || selectType == .manager {
            let list = teamList.compactMap({ FriendListItem.from($0) }).filter({ $0.userId != APP.loginData.userId })
            for item in list {
                if keyword.isEmpty || (item.name.contains(keyword) || keyword.contains(item.name)) {
                    var newList: [FriendListItem] = contactDict[item.initial] ?? []
                    newList.append(item)
                    contactDict[item.initial] = newList
                }
            }
        } else {
            for var item in DataManager.contactList {
                if keyword.isEmpty || (item.name.contains(keyword) || keyword.contains(item.name)) {
                    if teamList.contains(where: { $0.userId == item.userId }) {
                        item.isJoined = teamList.contains(where: { $0.userId == item.userId })
                    }
                    var newList: [FriendListItem] = contactDict[item.initial] ?? []
                    newList.append(item)
                    contactDict[item.initial] = newList
                }
            }
        }
        
        sectionIndexArray.append(contentsOf: contactDict.keys.sorted())
        indexView.reloadData()
        
        tableView?.reloadData()
    }
    
    @IBAction func textFieldChange(_ sender: UITextField) {
        if sender.markedTextRange == nil, let text = sender.text {
            keyword = text
        }
    }
    
    @objc func toCompleteSelect() {
        let message: String = {
            switch selectType {
            case .new, .add:
                return "请至少选择一位联系人"
            case .manager, .delete:
                return "请选择群成员"
            }
        }()
        guard !selectedItems.isEmpty else {
            toast(message: message)
            return
        }
        switch selectType {
        case .new:
            toCreateGroup()
        case .add:
            toAddMember()
        case .delete:
            showAlert(title: "提示", message: "是否删除已选择的群组成员？", buttonTitles: ["取消", "确认"], highlightedButtonIndex: 1) { index in
                if index == 1 {
                    self.toDeleteMember()
                }
            }
        case .manager:
            toUpdateManager()
        }
    }
    
    func toUpdateManager() {
        let userId = selectedItems.first?.userId ?? 0
        view.ss.showHUDLoading()
        HttpApi.Chat.putTeamSet(teamId: teamId, userId: userId).done { [weak self] _ in
            guard let weakSelf = self else { return }
            SSMainAsync {
                weakSelf.view.ss.hideHUD()
                weakSelf.completeBlock?(weakSelf.selectedItems)
                weakSelf.back()
                SS.keyWindow?.toast(message: "设置成功")
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.toast(message: error.localizedDescription)
            }
        }
    }
    
    func toDeleteMember() {
        let userIds = selectedItems.compactMap({ $0.userId })
        view.ss.showHUDLoading()
        HttpApi.Chat.putTeamOut(teamId: teamId, userIds: userIds).done { [weak self] _ in
            guard let weakSelf = self else { return }
            SSMainAsync {
                weakSelf.view.ss.hideHUD()
                weakSelf.completeBlock?(weakSelf.selectedItems)
                weakSelf.back()
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.toast(message: error.localizedDescription)
            }
        }
    }
    
    func toAddMember() {
        let userIds = selectedItems.compactMap({ $0.userId })
        view.ss.showHUDLoading()
        HttpApi.Chat.putHandJoinTeam(teamId: teamId, userIds: userIds).done { [weak self] _ in
            guard let weakSelf = self else { return }
            SSMainAsync {
                weakSelf.view.ss.hideHUD()
                weakSelf.completeBlock?(weakSelf.selectedItems)
                weakSelf.back()
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.toast(message: error.localizedDescription)
            }
        }
    }
    
    func toCreateGroup() {
        if selectedItems.count == 1, let item = selectedItems.first {
            // 单聊
            let vc = ConversationViewController()
            vc.targetId = "\(item.userId)"
            vc.conversationType = .ConversationType_PRIVATE
            vc.fakeNav.title = item.name
            go(vc)
        } else {
            let userIds = selectedItems.compactMap({ $0.userId })
            let userNames = selectedItems.compactMap({ $0.name })
            let groupName = userNames.joined(separator: "、") + "的群聊"
            
            view.ss.showHUDLoading()
            HttpApi.Chat.postHandAddTeam(userIds: userIds).done { [weak self] data in
                let model = data.kj.model(HandAddTeamResult.self)
                SSMainAsync {
                    self?.view.ss.hideHUD()
                    if model.teamId > 0 {
                        let groupInfo = RCGroup(groupId: "\(model.teamId)", groupName: groupName, portraitUri: nil)
                        RCIM.shared().refreshGroupInfoCache(groupInfo, withGroupId: "\(model.teamId)")
                        
                        let vc = ConversationViewController()
                        vc.targetId = "\(model.teamId)"
                        vc.conversationType = .ConversationType_DISCUSSION
                        vc.fakeNav.title = groupName
                        self?.go(vc)
                    }
                }
            }.catch { [weak self] error in
                SSMainAsync {
                    self?.view.ss.hideHUD()
                    self?.toast(message: error.localizedDescription)
                }
            }
        }
    }
    
}

extension SelectUserViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 58
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: SS.w, height: 32))
        sectionHeaderView.backgroundColor = .hex("F6F6F6")
        let indexNum = UILabel(text: sectionIndexArray[section], textColor: .hex("999999"), textFont: UIFont.systemFont(ofSize: 14))
        indexNum.frame = CGRect(x: 16, y: 0, width: 100, height: 32)
        sectionHeaderView.addSubview(indexNum)
        return sectionHeaderView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let key = sectionIndexArray[indexPath.section]
        let list = contactDict[key] ?? []
        let item = list[indexPath.row]
        if item.isJoined {
            // 已加入用户无法选择
            return
        }
        if !selectedItems.contains(where: { $0.userId == item.userId }) {
            if selectType == .manager {
                // 单选
                selectedItems = [item]
            } else {
                selectedItems.append(item)
            }
        } else {
            if selectType == .manager {
                return
            }
            selectedItems.removeAll(where: { $0.userId == item.userId })
        }
        tableView.reloadData()
    }
}

extension SelectUserViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionIndexArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = sectionIndexArray[section]
        let list = contactDict[key] ?? []
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: SelectUserCell.self)
        let key = sectionIndexArray[indexPath.section]
        let list = contactDict[key] ?? []
        let item = list[indexPath.row]
        cell.config(item: item, selected: selectedItems.contains(where: { $0.userId == item.userId }))
        return cell
    }
}

extension SelectUserViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDragging {
            self.indexView.updateItemHighlightWhenScrollStop(with: scrollView)
        }
    }
}

extension SelectUserViewController: SSIndexViewDelegate {
    
    func indexViewDidSelect(_ index: Int) {
        tableView.scrollToRow(at: IndexPath(row: 0, section: index), at: .top, animated: false)
    }
    
}

extension SelectUserViewController: SSIndexViewDataSource {
    
    func titlesForIndexView() -> [String] {
        return sectionIndexArray
    }

}

extension SelectUserViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        updateListView()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        actionView.isHidden = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == nil || textField.text!.isEmpty {
            actionView.isHidden = false
        }
    }
    
}
