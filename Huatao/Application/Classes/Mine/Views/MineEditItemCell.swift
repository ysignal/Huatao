//
//  MineEditItemCell.swift
//  Huatao
//
//  Created on 2023/2/16.
//  
	

import UIKit

class MineEditItemCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var contentLabelTrailing: NSLayoutConstraint!
    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var rightArrow: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func config(item: MineEditModel) {
        titleLabel.text = item.title
        contentLabel.text = item.content
        
        contentLabelTrailing.constant = 36
        rightArrow.isHidden = false
        switch item.type {
        case 1:
            userIcon.isHidden = false
            contentLabel.isHidden = true
            if let result = item.result {
                userIcon.image = result.image
            } else {
                userIcon.ss_setImage(APP.userInfo.avatar, placeholder: SSImage.userDefault)
            }
        case 2:
            userIcon.isHidden = true
            contentLabel.isHidden = false
        case 3:
            userIcon.isHidden = true
            contentLabel.isHidden = false
            contentLabelTrailing.constant = 12
            rightArrow.isHidden = true
        default:
            userIcon.isHidden = true
            contentLabel.isHidden = false
        }
    }

}
