//
//  ChatConversationCell.swift
//  Huatao
//
//  Created on 2023/1/16.
//

import UIKit

class ChatConversationCell: RCConversationBaseCell {
    
    lazy var iconView: UIView = {
        let view = UIView()
        view.loadOption([.cornerRadius(18)])
        return view
    }()
    
    lazy var userIcon: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    lazy var nameLabel: UILabel = {
        return UILabel(text: nil, textColor: .ss_33, textFont: .ss_regular(size: 16))
    }()
    
    lazy var messageLabel: UILabel = {
        return UILabel(text: nil, textColor: .ss_99, textFont: .ss_regular(size: 14))
    }()
    
    lazy var timeLabel: UILabel = {
        return UILabel(text: nil, textColor: .ss_99, textFont: .ss_regular(size: 12))
    }()
    
    lazy var countLabel: UILabel = {
        let lb = UILabel(text: "0", textColor: .white, textFont: .ss_regular(size: 12), textAlignment: .center)
        lb.backgroundColor = .hex("eb2020")
        lb.loadOption([.cornerRadius(19/2)])
        return lb
    }()
    
    lazy var groupImageView: GroupImageView = {
        return GroupImageView.fromNib()
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        buildUI()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildUI()
    }
        
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        buildUI()
    }
    
    
    func buildUI() {
        contentView.addSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(12)
            make.width.height.equalTo(48)
        }
        
        iconView.addSubview(userIcon)
        userIcon.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        iconView.addSubview(groupImageView)
        groupImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        groupImageView.isHidden = true
        
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(userIcon)
            make.left.equalTo(userIcon.snp.right).offset(8)
            make.height.equalTo(22)
        }
        
        contentView.addSubview(messageLabel)
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(6)
            make.left.equalTo(userIcon.snp.right).offset(8)
            make.height.equalTo(17)
            make.right.equalToSuperview().offset(50)
        }
        
        contentView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(nameLabel)
            make.right.equalToSuperview().offset(-12)
        }
        
        contentView.addSubview(countLabel)
        countLabel.snp.makeConstraints { make in
            make.centerY.equalTo(messageLabel)
            make.right.equalToSuperview().offset(-12)
            make.width.height.equalTo(19)
        }
    }
    
    override func setDataModel(_ model: RCConversationModel!) {
        nameLabel.text = model.conversationTitle
        switch model.conversationType {
        case .ConversationType_PRIVATE:
            // 私聊
            userIcon.isHidden = false
            groupImageView.isHidden = true
            IMManager.shared.getUserInfo(withUserId: model.targetId) { [weak self] data in
                SSMainAsync {
                    if let userInfo = data {
                        self?.userIcon.ss_setImage(userInfo.portraitUri ?? "", placeholder: SSImage.userDefault)
                        self?.nameLabel.text = userInfo.name
                    } else {
                        self?.nameLabel.text = "User<\(model.targetId ?? "")>"
                    }
                }
            }
        case .ConversationType_GROUP, .ConversationType_CHATROOM, .ConversationType_DISCUSSION:
            // 群组、聊天室、讨论组
            userIcon.isHidden = true
            groupImageView.isHidden = false

        default:
            break
        }
        
        messageLabel.text = model.lastestMessage.conversationDigest()
        timeLabel.text = SSDateHelper.formattedTime(from: model.sentTime)
        countLabel.text = "\(model.unreadMessageCount)"
        countLabel.isHidden = model.unreadMessageCount <= 0
    }
}
