//
//  NewFriendViewController.swift
//  Huatao
//
//  Created on 2023/2/18.
//  
	

import UIKit

class NewFriendViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var list: [NoticeFriendListItem] = []
    
    var nearList: [NoticeFriendListItem] = []
    
    var oldList: [NoticeFriendListItem] = []
    
    var page: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.ss.showHUDLoading()
        requestData()
    }
    
    override func buildUI() {
        fakeNav.title = "新的朋友"
        
        fakeNav.rightButton.title = "添加朋友"
        fakeNav.rightButton.titleFont = .ss_regular(size: 14)
        fakeNav.rightButton.titleColor = .ss_66
        fakeNav.rightButton.isHidden = false
        fakeNav.rightButton.snp.updateConstraints { make in
            make.width.equalTo(70)
        }
        fakeNav.rightButtonHandler = {
            self.toAddFriend()
        }
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
        tableView.backgroundColor = .ss_f6
        tableView.tableFooterView = UIView()
    }
    
    func requestData() {
        HttpApi.Chat.getNoticeFriend(page: page).done { [weak self] data in
            guard let weakSelf = self else { return }
            let listModel = data.kj.model(ListModel<NoticeFriendListItem>.self)
            if weakSelf.page == 1 {
                weakSelf.list = listModel.list
            } else {
                weakSelf.list.append(contentsOf: listModel.list)
            }
            if weakSelf.list.count < listModel.total {
                weakSelf.page += 1
                weakSelf.requestData()
            }
            SSMainAsync {
                weakSelf.view.ss.hideHUD()
                weakSelf.updateListView()
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.toast(message: error.localizedDescription)
            }
        }
    }
    
    func reloadData() {
        page = 1
        requestData()
    }
    
    func updateListView() {
        let now = Date()
        nearList = list.compactMap({
            if let date = Date($0.createdAt, format: APP.dateFullFormat),
               now.timeIntervalSince1970 - date.timeIntervalSince1970 < 86400 * 3 {
                return $0
            }
            return nil
        })
        
        oldList = list.compactMap({
            if let date = Date($0.createdAt, format: APP.dateFullFormat),
               now.timeIntervalSince1970 - date.timeIntervalSince1970 >= 86400 * 3 {
                return $0
            }
            return nil
        })

        tableView.reloadData()
    }

    func toAddFriend() {
        let vc = SearchFriendViewController.from(sb: .chat)
        go(vc)
    }
    
}

extension NewFriendViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            let item = nearList[indexPath.row]
            let from = item.type == 0 ? "我:" : ""
            let descText = from + item.desc
            if item.isOpen {
                let height = descText.height(from: .ss_regular(size: 12), width: SS.w - 190)
                return 40 + height
            }
        case 1:
            let item = oldList[indexPath.row]
            let from = item.type == 0 ? "我:" : ""
            let descText = from + item.desc
            if item.isOpen {
                let height = descText.height(from: .ss_regular(size: 12), width: SS.w - 190)
                return 40 + height
            }
        default:
            break
        }
        return 58
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            if !nearList.isEmpty {
                return 32
            }
        case 1:
            if !oldList.isEmpty {
                return 32
            }
        default:
            break
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(backgroundColor: .ss_f6)
        let title = section == 0 ? "近三天" : "三天前"
        let lb = UILabel(text: title, textColor: .ss_99, textFont: .ss_regular(size: 12))
        
        view.addSubview(lb)
        lb.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        return view
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if indexPath.row == nearList.count - 1 {
                cell.separatorInset = UIEdgeInsets(top: 0, left: SS.w, bottom: 0, right: 0)
            } else {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 58, bottom: 0, right: 0)
            }
        case 1:
            if indexPath.row == oldList.count - 1 {
                cell.separatorInset = UIEdgeInsets(top: 0, left: SS.w, bottom: 0, right: 0)
            } else {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 58, bottom: 0, right: 0)
            }
        default:
            break
        }
    }
    
}

extension NewFriendViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return nearList.count
        case 1:
            return oldList.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: NewFriendCell.self)
        cell.delegate = self
        switch indexPath.section {
        case 0:
            cell.config(item: nearList[indexPath.row])
        case 1:
            cell.config(item: oldList[indexPath.row])
        default:
            break
        }
        return cell
    }
    
}

extension NewFriendViewController: NewFriendCellDelegate {
    
    func cellDidExpand(_ item: NoticeFriendListItem) {
        item.isOpen = true
        tableView.reloadData()
    }
    
    func cellDidRefuse(_ item: NoticeFriendListItem) {
        view.ss.showHUDLoading()
        HttpApi.Chat.putCheckFriend(noticeId: item.noticeId, status: 2).done { [weak self] _ in
            SSMainAsync {
                self?.view.ss.hideHUD()
                item.status = 2
                self?.tableView.reloadData()
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.toast(message: error.localizedDescription)
            }
        }
    }
    
    func cellDidAgree(_ item: NoticeFriendListItem) {
        view.ss.showHUDLoading()
        HttpApi.Chat.putCheckFriend(noticeId: item.noticeId, status: 1).done { [weak self] _ in
            SSMainAsync {
                self?.view.ss.hideHUD()
                item.status = 1
                self?.tableView.reloadData()
                // 刷新通讯录
                DataManager.realoadAddressBook()
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.toast(message: error.localizedDescription)
            }
        }
    }
    
}
