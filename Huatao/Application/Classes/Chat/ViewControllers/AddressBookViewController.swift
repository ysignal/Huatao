//
//  AddressBookViewController.swift
//  Huatao
//
//  Created by lgvae on 2023/2/11.
//

import UIKit
import ZHXIndexView

class AddressBookViewController: UIViewController {
    

    @IBOutlet weak var tableView: UITableView!
    
    private lazy var indexView: SSIndexView = {
        let view = SSIndexView().titleColor(.hex("646566")).highlightTitleColor(.hex("FF8100")).titleFont(.systemFont(ofSize: 12)).indicatorRightMargin(5)
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    private var baseSections = [ChatSectionItem(icon: "ic_chat_group", title: "群聊", badge: 0),
                                ChatSectionItem(icon: "ic_chat_friend", title: "新的朋友", badge: 1),
                                ChatSectionItem(icon: "ic_chat_team", title: "团队长群", badge: 0)]
    
    private var sectionIndexArray = ["#"]
    private var contactDict: [String: [FriendListItem]] = [:]
    
    private var page: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        view.addSubview(indexView)
        indexView.snp.makeConstraints { make in
            make.top.right.bottom.equalToSuperview()
            make.width.equalTo(36)
        }
        
        tableView.backgroundColor = .clear
        tableView.sectionFooterHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.register(nibCell: ChatBaseSectionCell.self)
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if APP.isUpdateAddressBook {
            APP.isUpdateAddressBook = false
            updateListView()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        indexView.center.y = (SS.h - SS.statusWithNavBarHeight - SS.tabBarHeight)/2
    }
    
    func updateListView() {
        contactDict = [:]
        sectionIndexArray = ["#"]

        for item in DataManager.contactList {
            var newList: [FriendListItem] = contactDict[item.initial] ?? []
            newList.append(item)
            contactDict[item.initial] = newList
        }
        
        sectionIndexArray.append(contentsOf: contactDict.keys.sorted())
        indexView.reloadData()
        
        tableView?.reloadData()
    }
    
}

extension AddressBookViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let vc = ChatGroupListViewController()
                vc.chatGroupType = .normal
                go(vc)
            case 1:
                let vc = NewFriendViewController.from(sb: .chat)
                go(vc)
            case 2:
                let vc = ChatGroupListViewController()
                vc.chatGroupType = .leader
                go(vc)
            default:
                break
            }
        default:
            let key = sectionIndexArray[indexPath.section]
            let list = contactDict[key] ?? []
            let item = list[indexPath.row]
            let vc = AddFriendViewController.from(sb: .chat)
            vc.userId = item.userId
            go(vc)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 62
        default:
            return 58
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        }
        let sectionHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: SS.w, height: 32))
        sectionHeaderView.backgroundColor = .hex("F6F6F6")
        let indexNum = UILabel(text: sectionIndexArray[section], textColor: .hex("999999"), textFont: UIFont.systemFont(ofSize: 14))
        indexNum.frame = CGRect(x: 16, y: 0, width: 100, height: 32)
        sectionHeaderView.addSubview(indexNum)
        return sectionHeaderView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return .leastNormalMagnitude
        default:
            return 32
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }

}

extension AddressBookViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionIndexArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return baseSections.count
        default:
            let key = sectionIndexArray[section]
            let list = contactDict[key] ?? []
            return list.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: ChatBaseSectionCell.self)
        switch indexPath.section {
        case 0:
            let item = baseSections[indexPath.row]
            cell.configDefault(item: item)
        default:
            let key = sectionIndexArray[indexPath.section]
            let list = contactDict[key] ?? []
            let item = list[indexPath.row]
            cell.config(item: item)
        }
        return cell
    }
}

extension AddressBookViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDragging {
            self.indexView.updateItemHighlightWhenScrollStop(with: scrollView)
        }
    }
}

extension AddressBookViewController: SSIndexViewDelegate {
    
    func indexViewDidSelect(_ index: Int) {
        tableView.scrollToRow(at: IndexPath(row: 0, section: index), at: .top, animated: false)
    }
    
}

extension AddressBookViewController: SSIndexViewDataSource {
    
    func titlesForIndexView() -> [String] {
        return sectionIndexArray
    }
    
    func itemNoHighlightIndexArrayForIndexView() -> [Int] {
        return []
    }
    
}
