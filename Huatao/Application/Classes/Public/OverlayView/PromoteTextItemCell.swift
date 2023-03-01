//
//  PromoteTextItemCell.swift
//  Huatao
//
//  Created on 2023/2/28.
//  
	

import UIKit

class PromoteTextItemCell: UITableViewCell {
    
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        background.backgroundColor = selected ? .hex("ffecd8") : .hex("ededed")
        background.borderColor = selected ? .hex("ff8100") : .hex("ededed")
        
    }
    
    func config(item: SendTextListItem) {
        contentLabel.text = item.content
    }
    
}
