//
//  NextChildrenItemCell.swift
//  Huatao
//
//  Created on 2023/2/23.
//  
	

import UIKit

class NextChildrenItemCell: UITableViewCell {
    
    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var userName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = .clear
    }
    
    func config(item: ChildrenChildItem) {
        userIcon.ss_setImage(item.avatar, placeholder: SSImage.userDefault)
        userName.text = item.name
    }

}
