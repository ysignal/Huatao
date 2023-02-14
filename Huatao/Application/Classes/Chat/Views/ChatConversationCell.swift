//
//  ChatConversationCell.swift
//  Huatao
//
//  Created on 2023/1/16.
//

import UIKit

class ChatConversationCell: UITableViewCell {
    
    @IBOutlet weak var iconView: UIView!
    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    lazy var groupImageView: GroupImageView = {
        return GroupImageView.fromNib()
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        
        iconView.addSubview(groupImageView)
        groupImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        groupImageView.isHidden = true
        
    }
    
    func config(item: RCConversation) {
        nameLabel.text = item.conversationTitle
        messageLabel.text = item.lastestMessage?.conversationDigest()
        
        switch item.conversationType {
        case .ConversationType_PRIVATE:
            // 私聊
            userIcon.isHidden = false
            
        case .ConversationType_GROUP, .ConversationType_CHATROOM, .ConversationType_DISCUSSION:
            // 群组、聊天室、讨论组
            userIcon.isHidden = true

        default:
            break
        }
        
    }

}
