//
//  ConvertListItemCell.swift
//  Huatao
//
//  Created on 2023/1/29.
//

import UIKit

class ConvertListItemCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override var isSelected: Bool {
        didSet {
            titleLabel.backgroundColor = isSelected ? .ss_theme : .white
            titleLabel.textColor = isSelected ? .white : .ss_theme
            titleLabel.font = isSelected ? .ss_semibold(size: 14) : .ss_regular(size: 14)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = .ss_regular(size: 14)
    }
    
}
