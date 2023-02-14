//
//  ChatBaseSectionCell.swift
//  Huatao
//
//  Created on 2023/1/16.
//

import UIKit

class ChatBaseSectionCell: UITableViewCell {
    
    @IBOutlet weak var sectionIcon: UIImageView!
    @IBOutlet weak var sectionTitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func config(item: ChatSectionItem) {
        sectionIcon.image = UIImage(named: item.icon)
        sectionTitle.text = item.title
    }
    
}
