//
//  ChatConversationCell.swift
//  Huatao
//
//  Created on 2023/1/16.
//

import UIKit

protocol ChatConversationCellDelegate: NSObjectProtocol {
    func onLongPressCell(_ cell: ChatConversationCell, with model: RCConversationModel?)
}

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
    
    lazy var messageStack: UIStackView = {
        let sk = UIStackView(arrangedSubviews: [unsendLabel, messageLabel])
        sk.axis = .horizontal
        sk.spacing = 3
        return sk
    }()
    
    lazy var unsendLabel: UILabel = {
        return UILabel(text: "[草稿]", textColor: .hex("eb2020"), textFont: .ss_regular(size: 14))
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
    
    lazy var disturbIcon: UIImageView = {
        return UIImageView(image: UIImage(named: "ic_chat_disturb"))
    }()
    
    lazy var dotView: UIView = {
        let view = UIView(backgroundColor: .hex("eb2020"), cornerRadius: 5)
        return view
    }()
    
    lazy var groupImageView: GroupImageView = {
        return GroupImageView.fromNib()
    }()
    
    weak var delegate: ChatConversationCellDelegate?

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
        
        contentView.addSubview(messageStack)
        messageStack.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(6)
            make.left.equalTo(userIcon.snp.right).offset(8)
            make.height.equalTo(20)
            make.right.lessThanOrEqualTo(contentView).offset(-50)
        }

        contentView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(nameLabel)
            make.right.equalToSuperview().offset(-12)
        }
        
        contentView.addSubview(countLabel)
        countLabel.snp.makeConstraints { make in
            make.centerY.equalTo(messageStack)
            make.right.equalToSuperview().offset(-12)
            make.width.height.equalTo(19)
        }
        
        contentView.addSubview(disturbIcon)
        disturbIcon.snp.makeConstraints { make in
            make.centerY.equalTo(messageStack)
            make.right.equalToSuperview().offset(-12)
        }
        
        contentView.addSubview(dotView)
        dotView.snp.makeConstraints { make in
            make.right.equalTo(userIcon)
            make.top.equalTo(userIcon)
            make.width.height.equalTo(10)
        }
        
        addGesture(.long) { long in
            if long.state == .began {
                self.delegate?.onLongPressCell(self, with: self.model)
            }
        }

    }
    
    override func setDataModel(_ model: RCConversationModel!) {
        super.setDataModel(model)
        
        backgroundColor = model.isTop ? model.topCellBackgroundColor : model.cellBackgroundColor
        
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
        case .ConversationType_GROUP, .ConversationType_ULTRAGROUP, .ConversationType_DISCUSSION:
            // 群组、聊天室、讨论组
            userIcon.isHidden = true
            groupImageView.isHidden = false
            IMManager.shared.getGroupInfo(withGroupId: model.targetId) { [weak self] data in
                SSMainAsync {
                    if let groupInfo = data {
                        self?.nameLabel.text = groupInfo.groupName
                        if let imageStr = groupInfo.portraitUri {
                            self?.groupImageView.config(images: imageStr.components(separatedBy: ","))
                        }
                    } else {
                        self?.nameLabel.text = "Group<\(model.targetId ?? "")>"
                    }
                }
            }
            
        default:
            break
        }
        
        dotView.isHidden = true
        if model.notificationLevel == .blocked {
            countLabel.isHidden = true
            disturbIcon.isHidden = false
            if model.unreadMessageCount > 0 {
                dotView.isHidden = false
            }
            countLabel.isHidden = true
        } else {
            countLabel.isHidden = false
            disturbIcon.isHidden = true
            countLabel.isHidden = model.unreadMessageCount <= 0
        }

        if model.draft == nil || model.draft.isEmpty {
            unsendLabel.isHidden = true
            if let digest = model.lastestMessage?.conversationDigest(),
               model.notificationLevel == .blocked,
               model.unreadMessageCount > 1 {
                messageLabel.text = "[\(model.unreadMessageCount)条] " + digest
            } else {
                messageLabel.text = model.lastestMessage?.conversationDigest()
            }
        } else {
            unsendLabel.isHidden = false
            messageLabel.text = model.draft
        }
        timeLabel.text = SSDateHelper.formattedTime(from: model.sentTime)
        countLabel.text = "\(model.unreadMessageCount)"
    }
}
