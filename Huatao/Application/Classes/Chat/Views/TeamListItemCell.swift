//
//  TeamListItemCell.swift
//  Huatao
//
//  Created on 2023/2/21.
//  
	

import UIKit

protocol TeamListItemCellDelegate: NSObjectProtocol {
    
    func cellDidTap(_ model: GroupSettingSectionItem)
    func cellDidChangeValue(_ model: GroupSettingSectionItem)
    
}

class TeamListItemCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rightArrow: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var valueSwitch: UISwitch!
    
    private var model = GroupSettingSectionItem()
    
    weak var delegate: TeamListItemCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        
        addGesture(.tap) { tap in
            if tap.state == .ended {
                self.delegate?.cellDidTap(self.model)
            }
        }
        valueSwitch.addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
    }
    
    deinit {
        delegate = nil
    }
    
    @objc func valueChanged(_ sender: UISwitch) {
        model.value = sender.isOn
        delegate?.cellDidChangeValue(model)
    }

    func config(item: GroupSettingSectionItem) {
        model = item
        
        titleLabel.text = item.title
        contentLabel.text = item.content
        valueSwitch.isOn = item.value
        
        rightArrow.isHidden = true
        contentLabel.isHidden = true
        valueSwitch.isHidden = true

        switch item.type {
        case 1:
            rightArrow.isHidden = false
        case 2:
            rightArrow.isHidden = false
            contentLabel.isHidden = false
        case 3:
            valueSwitch.isHidden = false
        case 4:
            contentLabel.isHidden = false
        default:
            break
        }
        
    }

}
