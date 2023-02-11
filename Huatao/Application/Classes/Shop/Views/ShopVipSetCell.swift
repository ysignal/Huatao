//
//  ShopVipSetCell.swift
//  Huatao
//
//  Created on 2023/1/12.
//

import UIKit

class ShopVipSetCell: UITableViewCell {
    
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var tipLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = .clear
    }

    func config(item: ShopGiftItem) {
        titleLabel.text = item.name
        priceLabel.text = "\(item.money.fixedZero())元"
        var vipColor: UIColor = .black
        switch item.levelName {
        case "铜牌会员":
            bgImage.image = UIImage(named: "img_vip_1")
            vipColor = .hex("69472b")
        case "银牌会员":
            bgImage.image = UIImage(named: "img_vip_2")
            vipColor = .hex("5a616d")
        case "金牌会员":
            bgImage.image = UIImage(named: "img_vip_3")
            vipColor = .hex("573c15")
        default:
            bgImage.image = nil
        }
        titleLabel.textColor = vipColor
        priceLabel.textColor = vipColor
        tipLabel.textColor = vipColor
    }
}
