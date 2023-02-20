//
//  CircleNoticeItemCell.swift
//  Huatao
//
//  Created on 2023/2/16.
//  
	

import UIKit

class CircleNoticeItemCell: UITableViewCell {
    
    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func config(item: InteractMessageListItem) {
        userIcon.ss_setImage(item.sendUserAvatar, placeholder: SSImage.userDefault)
        let expand: String = {
            switch item.type {
            case 1:
                return "评论了你"
            case 2:
                return "点赞了你"
            default:
                return ""
            }
        }()
        titleLabel.text = item.sendUserName + expand
        timeLabel.text = item.createdAt
    }

}
