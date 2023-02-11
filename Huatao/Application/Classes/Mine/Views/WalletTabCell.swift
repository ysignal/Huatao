//
//  WalletTabCell.swift
//  Huatao
//
//  Created on 2023/1/26.
//

import UIKit

class WalletTabCell: UICollectionViewCell {
    
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override var isSelected: Bool {
        didSet {
            SS.log(frame)
            if isSelected {
                titleLabel.font = .ss_semibold(size: 16)
                titleLabel.textColor = .white
                background.drawGradient(start: .hex("F6A119"), end: .hex("FE8200"), size: frame.size, direction: .t2b)
            } else {
                titleLabel.font = .ss_regular(size: 16)
                titleLabel.textColor = .hex("333333")
                background.drawGradient(start: .white, end: .white, size: frame.size, direction: .t2b)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = .ss_regular(size: 16)
    }
    
    func config(item: WalletTabItem) {
        titleLabel.text = item.title
    }
    
}
