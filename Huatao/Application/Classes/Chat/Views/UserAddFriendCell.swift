//
//  UserAddFriendCell.swift
//  Huatao
//
//  Created on 2023/2/17.
//  
	

import UIKit

class UserAddFriendCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func config(isFriend: Int) {
        if isFriend == 1 {
            titleLabel.text = "发送消息"
        } else {
            titleLabel.text = "添加好友"
        }
    }

}
