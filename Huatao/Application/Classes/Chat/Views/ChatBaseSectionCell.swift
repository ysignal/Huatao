//
//  ChatBaseSectionCell.swift
//  Huatao
//
//  Created on 2023/1/16.
//

import UIKit

class ChatBaseSectionCell: UITableViewCell {
    
    @IBOutlet weak var sectionIcon: UIImageView!
    @IBOutlet weak var sectionTitle: UILabel!
    
    lazy var badgeLabel: UILabel = {
        let lb = UILabel(text: "0", textColor: .white, textFont: .ss_regular(size: 10), textAlignment: .center)
        lb.backgroundColor = .hex("eb2020")
        lb.loadOption([.backgroundColor(.hex("eb2020")), .cornerRadius(7.5)])
        return lb
    }()
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        badgeLabel.backgroundColor = .hex("eb2020")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        badgeLabel.backgroundColor = .hex("eb2020")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        addSubview(badgeLabel)
        badgeLabel.snp.makeConstraints { make in
            make.centerX.equalTo(sectionIcon.snp.right).offset(-2)
            make.centerY.equalTo(sectionIcon.snp.top).offset(2)
            make.width.height.equalTo(15)
        }
    }
    
    func config(item: FriendListItem) {
        sectionIcon.contentMode = .scaleAspectFill
        sectionIcon.ss_setImage(item.avatar, placeholder: SSImage.userDefault)
        sectionTitle.text = item.name
        badgeLabel.isHidden = true
    }
    
    func configDefault(item: ChatSectionItem) {
        sectionIcon.contentMode = .scaleAspectFit
        sectionIcon.image = UIImage(named: item.icon)
        sectionTitle.text = item.title
        badgeLabel.text = "\(item.badge)"
        badgeLabel.isHidden = item.badge <= 0
    }
    
}
