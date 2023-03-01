//
//  MessageHistoryViewController.swift
//  Huatao
//
//  Created on 2023/2/23.
//  
	

import UIKit
import IQKeyboardManagerSwift

class MessageHistoryViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var cancelBtn: SSButton!
    
    var targetId: String = ""
    
    var keyword: String = ""
    
    var lastTime: Int64 = 0
    
    var list: [RCMessage] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        requestData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
    }
    
    override func buildUI() {
        view.backgroundColor = .ss_f6
        hideFakeNavBar()
        
        tableView.addRefresh(type: .footer, delegate: self)
    }
    
    func requestData() {
        let targetId = targetId
        let keyword = keyword
        let lastTime = lastTime
        if keyword.isEmpty {
            list = []
            tableView.reloadData()
            return
        }
        SSGlobelAsync { [weak self] in
            if let messages = RCIMClient.shared().searchMessages(.ConversationType_PRIVATE, targetId: targetId, keyword: keyword, count: 10, startTime: lastTime) {
                self?.list.append(contentsOf: messages)
                SSMainAsync {
                    self?.tableView.reloadData()
                }
            } else {
                SS.log("没有搜索到结果")
            }
        }
    }
    
    func toSearch() {
        lastTime = 0
        list = []
        requestData()
    }
    
    @IBAction func textFieldChange(_ sender: Any) {
        if searchTF.markedTextRange == nil, let text = searchTF.text {
            keyword = text
            toSearch()
        }
    }
    
    @IBAction func toCancel(_ sender: Any) {
        searchTF.resignFirstResponder()
        back()
    }
    
}

extension MessageHistoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
}

extension MessageHistoryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: MessageHistoryItemCell.self)
        let item = list[indexPath.row]
        cell.config(item: item, keyword: keyword)
        return cell
    }
    
}

extension MessageHistoryViewController: UIScrollViewRefreshDelegate {
    
    func scrollViewFooterRefreshData(_ scrollView: UIScrollView) {
        if let last = list.last {
            if lastTime == last.receivedTime {
                return
            }
            lastTime = last.receivedTime
            requestData()
        }
    }
    
}
