//
//  BaseActionItemCell.swift
//  Huatao
//
//  Created on 2023/3/2.
//  
	

import UIKit

class BaseActionItemCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
    }
    
}
