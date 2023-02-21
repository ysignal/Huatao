//
//  TeamMemberItemCell.swift
//  Huatao
//
//  Created on 2023/2/21.
//  
	

import UIKit

class TeamMemberItemCell: UICollectionViewCell {
    
    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var userName: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func config(item: TeamUser) {
        userIcon.cornerRadius = 20
        userIcon.ss_setImage(item.avatar, placeholder: SSImage.userDefault)
        userName.text = item.name
    }
    
    func configAdd() {
        userIcon.image = UIImage(named: "btn_image_add_dotted")
        userIcon.cornerRadius = 0
        userName.text = ""
    }
    
    func configDelete() {
        userIcon.image = UIImage(named: "btn_image_delete_dotted")
        userIcon.cornerRadius = 0
        userName.text = ""
    }
    
}
