//
//  BankCardItemCell.swift
//  Huatao
//
//  Created on 2023/3/1.
//  
	

import UIKit

class BankCardItemCell: UITableViewCell {
    
    @IBOutlet weak var labenStack: UIStackView!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func config(item: BankCardItem) {
        
    }

}
