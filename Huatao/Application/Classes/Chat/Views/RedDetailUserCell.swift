//
//  RedDetailUserCell.swift
//  Huatao
//
//  Created on 2023/3/3.
//  
	

import UIKit

class RedDetailUserCell: UITableViewCell {
    
    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var moneyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    func config(item: RedUserItem, unit: String) {
        userIcon.ss_setImage(item.avatar, placeholder: SSImage.userDefault)
        userName.text = item.name
        timeLabel.text = item.createdAt
        moneyLabel.text = item.money.fixedZero() + unit
    }
    
}
