//
//  AgentUserItemCell.swift
//  Huatao
//
//  Created on 2023/2/13.
//  
	

import UIKit

class AgentUserItemCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mobileLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func config(item: AgentChildrenItem) {
        nameLabel.text = item.name
        mobileLabel.text = item.mobile
        cityLabel.text = item.city
    }

}
