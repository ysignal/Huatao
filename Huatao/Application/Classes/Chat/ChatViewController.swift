//
//  ChatViewController.swift
//  Huatao
//
//  Created by minse on 2023/1/10.
//

import UIKit

class ChatViewController: SSViewController {
    
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var chatTV: UITableView!
    
    lazy var background: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: SS.w, height: 262))
        view.drawGradient(start: .hex("fff1e2"), end: .hex("f6f6f6"), size: view.frame.size, direction: .t2b)
        return view
    }()
    
    var sections: [ChatSectionItem] {
        return ChatModel.baseSections
    }
    
    var conversations: [RCConversation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestData()
    }
    
    override func buildUI() {
        view.backgroundColor = .hex("f6f6f6")
        view.insertSubview(background, belowSubview: searchView)
        
        showFakeNavBar()
        fakeNav.backgroundColor = .clear
        fakeNav.titleLabel.font = .ss_semibold(size: 18)
        fakeNav.title = "聊天"
        fakeNav.titleColor = .hex("333333")
        
        searchTF.leftView = UIImageView(image: UIImage(named: "ic_chat_search"))
        
        chatTV.tableFooterView = UIView()
    }
    
    func requestData() {
        DispatchQueue.global().async { [weak self] in
            let client = RCIMClient.shared()
            self?.conversations = client.getConversationList([NSNumber(value: RCConversationType.ConversationType_PRIVATE.rawValue),
                                                              NSNumber(value: RCConversationType.ConversationType_DISCUSSION.rawValue),
                                                              NSNumber(value: RCConversationType.ConversationType_GROUP.rawValue),
                                                              NSNumber(value: RCConversationType.ConversationType_CHATROOM.rawValue),
                                                              NSNumber(value: RCConversationType.ConversationType_CUSTOMERSERVICE.rawValue),
                                                              NSNumber(value: RCConversationType.ConversationType_SYSTEM.rawValue)]) ?? []
            DispatchQueue.main.async {
                self?.chatTV.reloadData()
            }
        }

    }

}

extension ChatViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
}

extension ChatViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections.count + conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < sections.count {
            let item = sections[indexPath.row]
            let cell = tableView.dequeueReusableCell(with: ChatBaseSectionCell.self)
            cell.config(item: item)
            return cell
        }
        let cell = tableView.dequeueReusableCell(with: ChatConversationCell.self)
        let item = conversations[indexPath.row - sections.count]
        return cell
    }
    
}
