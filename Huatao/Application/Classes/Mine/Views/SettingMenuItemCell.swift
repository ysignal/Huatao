//
//  SettingMenuItemCell.swift
//  Huatao
//
//  Created on 2023/1/26.
//

import UIKit

class SettingMenuItemCell: UITableViewCell {
    
    @IBOutlet weak var menuIcon: UIImageView!
    @IBOutlet weak var menuTitle: UILabel!
    @IBOutlet weak var menuValue: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    func config(item: SettingMenuItem) {
        menuIcon.image = UIImage(named: item.icon)
        menuTitle.text = item.title
        menuValue.text = item.value
    }

}
