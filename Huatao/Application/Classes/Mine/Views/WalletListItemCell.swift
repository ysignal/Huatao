//
//  WalletListItemCell.swift
//  Huatao
//
//  Created on 2023/1/26.
//

import UIKit

class WalletListItemCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    func config(item: WalletRecordItem) {
        titleLabel.text = item.desc + (item.type == 1 ? "+" : "-") + item.money.fixedZero()
        timeLabel.text = item.createdAt
    }

}
