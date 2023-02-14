//
//  BaseImageItemCell.swift
//  Huatao
//
//  Created on 2023/1/13.
//

import UIKit

class BaseImageItemCell: UICollectionViewCell {
    
    @IBOutlet weak var baseImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        baseImage.contentMode = .scaleAspectFill
        baseImage.layer.masksToBounds = true
    }
    
    func config(url: String, placeholder: UIImage?, cornerRadius: CGFloat = 0) {
        baseImage.layer.cornerRadius = cornerRadius
        baseImage.ss_setImage(url, placeholder: placeholder)
    }

}
