//
//  MineMenuItemCell.swift
//  Huatao
//
//  Created on 2023/1/15.
//

import UIKit

class MineMenuItemCell: UICollectionViewCell {
    
    @IBOutlet weak var menuIcon: UIImageView!
    @IBOutlet weak var menuTitle: UILabel!
    
    func config(item: MineMenuItem) {
        menuIcon.image = UIImage(named: item.icon)
        menuTitle.text = item.title
    }
    
}
