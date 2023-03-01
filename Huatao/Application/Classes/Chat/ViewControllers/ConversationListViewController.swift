//
//  ConversationListViewController.swift
//  Huatao
//
//  Created on 2023/2/17.
//  
	

import UIKit
import Popover

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
    
    func showPopover(with model: RCConversationModel, in view: UIView) {
        let topTitle = model.isTop ? "取消置顶" : "置顶该聊天"
        let popover = Popover(options: [.color(.white),
                                        .blackOverlayColor(.black.withAlphaComponent(0.3)),
                                        .cornerRadius(4),
                                        .arrowSize(.zero),
                                        .sideEdge(12)])
        popover.popoverType = .down
        let menuView = PopoverMenuView(dataSource: ["标为已读", topTitle, "删除该聊天"], width: 150, color: .ss_33) { index in
            popover.dismiss()
            switch index {
            case 0:
                RCIMClient.shared().clearMessagesUnreadStatus(model.conversationType, targetId: model.targetId)
            case 1:
                RCIMClient.shared().setConversationToTop(model.conversationType, targetId: model.targetId, isTop: !model.isTop)
            case 2:
                RCIMClient.shared().remove(model.conversationType, targetId: model.targetId)
            default: break
            }
            SSMainAsync {
                // 刷新会话列表
                self.refreshConversationTableViewIfNeeded()
            }
        }
        popover.show(menuView, fromView: view)
    }

    override func onSelectedTableRow(_ conversationModelType: RCConversationModelType, conversationModel model: RCConversationModel!, at indexPath: IndexPath!) {
        conversationListTableView?.deselectRow(at: indexPath, animated: true)
        let vc = ConversationViewController()
        vc.conversationType = model.conversationType
        vc.targetId = model.targetId
        let cell = conversationListTableView?.cellForRow(at: indexPath) as? ChatConversationCell
        vc.fakeNav.title = cell?.nameLabel.text ?? model.conversationTitle
        vc.notificationLevel = model.notificationLevel
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
        cell.delegate = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }

}

extension ConversationListViewController: ChatConversationCellDelegate {
    
    func onLongPressCell(_ cell: ChatConversationCell, with model: RCConversationModel?) {
        if let m = model {
            showPopover(with: m, in: cell)
        }
    }
    
}
