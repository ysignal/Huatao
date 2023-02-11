//
//  LikeListItemCell.swift
//  Huatao
//
//  Created on 2023/1/29.
//

import UIKit

class LikeListItemCell: UICollectionViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.font = .ss_regular(size: 12)
    }

}
