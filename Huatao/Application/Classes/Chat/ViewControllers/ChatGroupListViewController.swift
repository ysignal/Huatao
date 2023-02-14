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


class ChatGroupListViewController: BaseViewController{
    
    
    var chatGroupType: ChatGroupType?
    
    
    lazy var headBackgroundView: UIView = {
        
        let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: SS.w, height: 51 + SS.statusBarHeight + SS.navBarHeight))
        
        backgroundView.backgroundColor = .hex("F2F2F2")
        
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
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = .hex("FFFFFF")
        tableView.showsVerticalScrollIndicator = false
        
        return tableView
    }()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
    }
    
    override func buildUI() {
        
        view.addSubview(headBackgroundView)
        
        view.addSubview(tableView)
        
        fakeNav.title = chatGroupType == .normal ? "群组" : "团队长群"
        
        fakeNav.backgroundColor = .hex("F2F2F2")
        
    }
    
}

extension ChatGroupListViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}

extension ChatGroupListViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = AddressBookCell(style: .default, reuseIdentifier: "AddressBookCell")
        
        cell.selectionStyle = .none
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 68
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
}

extension ChatGroupListViewController: UISearchBarDelegate{
    
    
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


