//
//  SelectUserCell.swift
//  Huatao
//
//  Created on 2023/2/21.
//  
	

import UIKit

class SelectUserCell: UITableViewCell {
    
    @IBOutlet weak var radioIcon: UIImageView!
    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var userName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func config(item: FriendListItem, selected: Bool) {
        radioIcon.image = selected ? SSImage.radioOn : SSImage.radioOff
        userIcon.ss_setImage(item.avatar, placeholder: SSImage.userDefault)
        userName.text = item.name
    }

}
