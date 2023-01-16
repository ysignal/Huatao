//
//  MineHeaderView.swift
//  Huatao
//
//  Created by minse on 2023/1/15.
//

import UIKit

class MineHeaderView: UICollectionReusableView {
    
    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var editBtn: SSButton!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var vipBtn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
    }
    
    func config() {
        userIcon.ss_setImage(APP.userInfo.avatar, placeholder: SSImage.userDefault)
        userName.text = APP.userInfo.name
        phoneLabel.text = APP.userInfo.mobile
        
    }
    
}
