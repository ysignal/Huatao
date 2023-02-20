//
//  ConversationListViewController.swift
//  Huatao
//
//  Created on 2023/2/17.
//  
	

import UIKit

class ConversationListViewController: RCConversationListViewController {


    override func viewDidLoad() {
        super.viewDidLoad()
        
        setConversationAvatarStyle(.USER_AVATAR_CYCLE)
        setConversationPortraitSize(CGSize(width: 48, height: 48))
        
        view.backgroundColor = .clear
        conversationListTableView?.separatorStyle = .singleLine
        conversationListTableView?.separatorColor = .hex("eeeeee")
        conversationListTableView?.separatorInset = .zero
        conversationListTableView?.register(cell: ChatConversationCell.self)
        conversationListTableView?.backgroundColor = .ss_f6
    }
    
    override func onSelectedTableRow(_ conversationModelType: RCConversationModelType, conversationModel model: RCConversationModel!, at indexPath: IndexPath!) {
        conversationListTableView?.deselectRow(at: indexPath, animated: true)
        let vc = ConversationViewController()
        vc.conversationType = model.conversationType
        vc.targetId = model.targetId
        let cell = conversationListTableView?.cellForRow(at: indexPath) as? ChatConversationCell
        vc.fakeNav.title = cell?.nameLabel.text ?? model.conversationTitle
        go(vc)
    }
    
    override func willReloadTableData(_ dataSource: NSMutableArray!) -> NSMutableArray! {
        let newArray = NSMutableArray()
        for item in dataSource {
            if let model = item as? RCConversationModel {
                model.conversationModelType = .CONVERSATION_MODEL_TYPE_CUSTOMIZATION
            }
            newArray.add(item)
        }
        return newArray
    }
    
    override func rcConversationListTableView(_ tableView: UITableView!, heightForRowAt indexPath: IndexPath!) -> CGFloat {
        return 68
    }

    
    override func rcConversationListTableView(_ tableView: UITableView!, cellForRowAt indexPath: IndexPath!) -> RCConversationBaseCell! {
        let cell = tableView.dequeueReusableCell(with: ChatConversationCell.self)        
        return cell
    }

}
