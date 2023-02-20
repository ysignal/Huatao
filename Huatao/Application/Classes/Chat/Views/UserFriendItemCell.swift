//
//  UserFriendItemCell.swift
//  Huatao
//
//  Created on 2023/2/17.
//  
	

import UIKit

struct UserFriendItem {
    
    /// 类型 1-箭头类型，2-开关类型
    var type: Int = 0
    
    /// 标题
    var title: String = ""

    /// 开关
    var isOn: Bool = false
    
}

class UserFriendItemCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rightArrow: UIImageView!
    @IBOutlet weak var valueSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func config(item: UserFriendItem) {
        titleLabel.text = item.title
        valueSwitch.isOn = item.isOn
        if item.type == 1 {
            rightArrow.isHidden = false
            valueSwitch.isHidden = true
        } else {
            rightArrow.isHidden = true
            valueSwitch.isHidden = false
        }
    }
    
}
