//
//  ChatGroupListViewController.swift
//  Huatao
//
//  Created by lgvae on 2023/2/11.
//

import UIKit

enum ChatGroupType {

    case normal
    
    case leader
}

class ChatGroupListViewController: BaseViewController {
    
    var chatGroupType: ChatGroupType = .normal
    
    lazy var headBackgroundView: UIView = {
        let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: SS.w, height: 51 + SS.statusBarHeight + SS.navBarHeight))
        backgroundView.backgroundColor = .ss_f6
        backgroundView.addSubview(searchBar)
        return backgroundView
    }()
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar(frame: CGRectMake(12, SS.statusBarHeight + SS.navBarHeight, SS.w - 24, 39))
        searchBar.placeholder = "搜索"
        searchBar.setBackgroundImage(UIImage(color: UIColor.white), for: .any, barMetrics: .default)
        searchBar.setSearchFieldBackgroundImage(UIImage(), for: .normal)
        searchBar.delegate = self
        return searchBar
        
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: SS.navBarHeight + SS.statusBarHeight + 51, width: SS.w, height: SS.h - SS.navBarHeight - SS.statusBarHeight - SS.safeBottomHeight),style: .grouped)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = .hex("eeeeee")
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 58, bottom: 0, right: 0)
        tableView.backgroundColor = .white
        tableView.showsVerticalScrollIndicator = false
        tableView.tableFooterView = UIView()
        tableView.register(cell: AddressBookCell.self)
        return tableView
    }()
    
    var list: [TeamListItem] = []
    
    var page: Int = 0
    
    var keyword: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.ss.showHUDLoading()
        requestData()
    }
    
    override func buildUI() {
        view.addSubview(headBackgroundView)
        view.addSubview(tableView)
        
        fakeNav.title = chatGroupType == .normal ? "群聊" : "团队长群"
        fakeNav.backgroundColor = .ss_f6
        
        tableView.addRefresh(type: .headerAndFooter, delegate: self)
    }
    
    func requestData() {
        HttpApi.Chat.getTeamList(page: page, keyword: keyword).done { [weak self] data in
            guard let weakSelf = self else { return }
            let listModel = data.kj.model(ListModel<TeamListItem>.self)
            if weakSelf.page == 1 {
                weakSelf.list = listModel.list
            } else {
                weakSelf.list.append(contentsOf: listModel.list)
            }
            SSMainAsync {
                weakSelf.tableView.mj_header?.endRefreshing()
                weakSelf.view.ss.hideHUD()
                if weakSelf.list.count >= listModel.total {
                    weakSelf.tableView.mj_footer?.endRefreshingWithNoMoreData()
                } else {
                    weakSelf.tableView.mj_footer?.resetNoMoreData()
                }
                weakSelf.tableView.reloadData()
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.tableView.endRefreshing()
                self?.toast(message: error.localizedDescription)
            }
        }
    }
}

extension ChatGroupListViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = list[indexPath.row]
        let vc = ConversationViewController()
        vc.targetId = "\(item.teamId)"
        vc.conversationType = .ConversationType_GROUP
        vc.fakeNav.title = item.title
        go(vc)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
}

extension ChatGroupListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: AddressBookCell.self)
        let item = list[indexPath.row]
        cell.config(item: item)
        return cell
    }

}

extension ChatGroupListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        print("当前内容:\((searchBar.text ?? "") + text)")
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension ChatGroupListViewController: UIScrollViewRefreshDelegate {
    
    func scrollViewHeaderRefreshData(_ scrollView: UIScrollView) {
        page = 1
        requestData()
    }
    
    func scrollViewFooterRefreshData(_ scrollView: UIScrollView) {
        page += 1
        requestData()
    }
    
}
