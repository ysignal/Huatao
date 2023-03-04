//
//  MoneyHistoryCell.swift
//  Huatao
//
//  Created on 2023/2/21.
//  
	

import UIKit

class MoneyHistoryCell: UITableViewCell {
    
    @IBOutlet weak var reasonLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var moneyLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func config(item: WalletRecordItem) {
        reasonLabel.text = item.desc
        timeLabel.text = item.createdAt
        
        let mulStr = NSMutableAttributedString()
        let typeText = item.type == 1 ? "+" : "-"
        moneyLabel.textColor = item.type == 1 ? .hex("1bd86d") : .hex("f11f1f")
        mulStr.append(NSAttributedString(string: "\(typeText)\(item.money.fixedZero())", attributes: [.font: UIFont.ss_dinbold(size: 16)]))
        mulStr.append(NSAttributedString(string: "元", attributes: [.font: UIFont.ss_dinbold(size: 10)]))
        moneyLabel.attributedText = mulStr
    }

}
