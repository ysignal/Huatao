//
//  ConvertHistoryItemCell.swift
//  Huatao
//
//  Created by minse on 2023/1/29.
//

import UIKit

class ConvertHistoryItemCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    func config(item: WalletRecordItem) {
        titleLabel.text = "兑换\(item.money.fixedZero())个金豆"
        timeLabel.text = item.createdAt
    }

}
