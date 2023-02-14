//
//  TeamMemberCell.swift
//  Huatao
//
//  Created on 2023/1/19.
//

import UIKit

class TeamMemberCell: UITableViewCell {
    
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var certView: UIView!
    @IBOutlet weak var completeView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var registerLabel: UILabel!
    @IBOutlet weak var certLabel: UILabel!
    @IBOutlet weak var payLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        background.drawGradient(start: .hex("#FFECD8"), end: .hex("#FFFFFF"), size: CGSize(width: SS.w - 24, height: 172), direction: .t2b)
    }

    func config(item: MineTeamListItem) {
        userIcon.ss_setImage(item.avatar, placeholder: SSImage.userDefault)
        userName.text = item.name
        phoneLabel.text = ""
        certView.isHidden = item.cardStatus != 1
        completeView.isHidden = item.isTodayTask != 1
        timeLabel.text = "注册时间：\(item.createdAt)"
        registerLabel.text = "\(item.registerTotal)人"
        certLabel.text = "\(item.authTotal)人"
        payLabel.text = "\(item.consumMoney.fixedZero())元"
    }
    
}
