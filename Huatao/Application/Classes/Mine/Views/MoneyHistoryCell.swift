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
        // Initialization code
    }
    
    func config(item: MoneyHistoryItem) {
        
    }

}
