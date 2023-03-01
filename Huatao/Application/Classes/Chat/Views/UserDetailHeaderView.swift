//
//  UserDetailHeaderView.swift
//  Huatao
//
//  Created on 2023/2/23.
//  
	

import UIKit

class UserDetailHeaderView: UIView {

    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var oldName: UILabel!
    @IBOutlet weak var signLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        oldName.textColor = .ss_66
    }
    
    func config(model: FriendDetailModel) {
        userIcon.ss_setImage(model.avatar, placeholder: SSImage.userDefault)
        userName.text = model.remarkName.isEmpty ? model.name : model.remarkName
        oldName.isHidden = model.remarkName.isEmpty
        oldName.text = "昵称: \(model.name)"
        signLabel.text = model.personSign
        
        let oldHeight: CGFloat = model.remarkName.isEmpty ? 0 : 30
        let signHeight = model.personSign.height(from: .systemFont(ofSize: 14), width: SS.w - 40)
        self.ex_height = 150 + signHeight + oldHeight
    }

}
