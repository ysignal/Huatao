//
//  CityPickerItemCell.swift
//  Huatao
//
//  Created on 2023/2/15.
//  
	

import UIKit

class CityPickerItemCell: UITableViewCell {
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var selectIV: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        selectIV.isHidden = !selected
        cityLabel.textColor = selected ? .ss_theme : .hex("333333")
    }
    
    func config(text: String) {
        cityLabel.text = text
    }
    
}
