//
//  MineHeaderView.swift
//  Huatao
//
//  Created on 2023/1/15.
//

import UIKit

protocol MineHeaderViewDelegate: NSObjectProtocol {
    
    func headerViewDidClickedEdit()
    func headerViewDidClickedVip()
    
}

class MineHeaderView: UICollectionReusableView {
    
    weak var delegate: MineHeaderViewDelegate?
    
    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var editBtn: SSButton!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var vipBtn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
    }
    
    func config(model: MineUserInfo) {
        userIcon.ss_setImage(model.avatar, placeholder: SSImage.userDefault)
        userName.text = model.name
        phoneLabel.text = model.mobile
        let level = DataManager.vipList.firstIndex(of: model.levelName) ?? 0
        vipBtn.image = UIImage(named: "ic_mine_vip_\(level + 1)")
    }
    
    @IBAction func toEdit(_ sender: Any) {
        delegate?.headerViewDidClickedEdit()
    }
    
    @IBAction func toVipRule(_ sender: Any) {
        delegate?.headerViewDidClickedVip()
    }
    
}
