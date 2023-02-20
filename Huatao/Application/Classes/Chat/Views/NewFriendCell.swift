//
//  NewFriendCell.swift
//  Huatao
//
//  Created on 2023/2/18.
//  
	

import UIKit

protocol NewFriendCellDelegate: NSObjectProtocol {
    
    func cellDidExpand(_ item: NoticeFriendListItem)
    func cellDidRefuse(_ item: NoticeFriendListItem)
    func cellDidAgree(_ item: NoticeFriendListItem)
    
}

class NewFriendCell: UITableViewCell {
    
    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var descLabelWidth: NSLayoutConstraint!
    @IBOutlet weak var expandBtn: SSButton!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var buttonStack: UIStackView!
    
    var delegate: NewFriendCellDelegate?
    
    var model = NoticeFriendListItem()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        descLabel.font = .ss_regular(size: 12)
    }
    
    func config(item: NoticeFriendListItem) {
        model = item
        
        let from = item.type == 0 ? "我:" : ""
        let descText = "\(from)\(item.desc)"
        let descWidth = descText.width(from: .ss_regular(size: 12), height: 20)
        expandBtn.isHidden = descWidth < 120 || item.isOpen
        descLabelWidth.constant = item.isOpen ? (SS.w - 190) : 132
        descLabel.numberOfLines = item.isOpen ? 0 : 1

        descLabel.text = descText
        
        
        userName.text = item.name
        userIcon.ss_setImage(item.avatar, placeholder: SSImage.userDefault)
        
        switch item.status {
        case 0:
            if item.type == 0 {
                buttonStack.isHidden = true
                statusLabel.isHidden = false
                statusLabel.text = "等待验证"
            } else {
                buttonStack.isHidden = false
                statusLabel.isHidden = true
            }
        case 1:
            buttonStack.isHidden = true
            statusLabel.isHidden = false
            statusLabel.text = "已添加"
        case 2:
            buttonStack.isHidden = true
            statusLabel.isHidden = false
            statusLabel.text = "已拒绝"
        default: break
        }
    }
    
    @IBAction func toExpand(_ sender: Any) {
        delegate?.cellDidExpand(model)
    }
    
    @IBAction func toRefuse(_ sender: Any) {
        delegate?.cellDidRefuse(model)
    }
    
    @IBAction func toAgree(_ sender: Any) {
        delegate?.cellDidAgree(model)
    }
}
