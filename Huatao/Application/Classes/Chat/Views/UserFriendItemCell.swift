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
    
    /// 事件标签
    var action: String = ""
    
}

protocol UserFriendItemCellDelegate: NSObjectProtocol {
    
    func cellDidSwitchChange(_ item: UserFriendItem, isOn: Bool)
    func cellDidTap(_ item: UserFriendItem)
    
}

extension UserFriendItemCellDelegate {
    func cellDidTap(_ item: UserFriendItem) {}
    func cellDidSwitchChange(_ item: UserFriendItem, isOn: Bool) {}
}

class UserFriendItemCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rightArrow: UIImageView!
    @IBOutlet weak var valueSwitch: UISwitch!
    
    private var model = UserFriendItem()
    
    weak var delegate: UserFriendItemCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        
        valueSwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        
        contentView.addGesture(.tap) { tap in
            if tap.state == .ended {
                self.delegate?.cellDidTap(self.model)
            }
        }
    }
    
    deinit {
        delegate = nil
    }
    
    @objc func switchChanged() {
        delegate?.cellDidSwitchChange(model, isOn: valueSwitch.isOn)
    }
    
    func config(item: UserFriendItem) {
        model = item
        
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
