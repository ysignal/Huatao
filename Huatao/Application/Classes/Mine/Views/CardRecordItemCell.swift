//
//  CardRecordItemCell.swift
//  Huatao
//
//  Created on 2023/2/13.
//  
	

import UIKit

class CardRecordItemCell: UITableViewCell {
    
    @IBOutlet weak var residueLabel: UILabel!
    @IBOutlet weak var todayLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func config(item: CardReturnModel) {
        residueLabel.text = "\(item.waitMoney)"
        todayLabel.text = "\(item.todayMoney)"
        totalLabel.text = "\(item.getMoney)"
    }
    
}
