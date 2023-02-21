//
//  GroupImageView.swift
//  Huatao
//
//  Created on 2023/1/16.
//

import UIKit

class GroupImageView: UIView {

    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var image3: UIImageView!
    @IBOutlet weak var image4: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.masksToBounds = true
        backgroundColor = .hex("dddddd")
    }
    
    func config(images: [String], cornerRadius: CGFloat = 0) {
        layer.cornerRadius = cornerRadius

        loadImage(iv: image1, list: images, index: 0)
        loadImage(iv: image2, list: images, index: 1)
        loadImage(iv: image3, list: images, index: 2)
        loadImage(iv: image4, list: images, index: 3)
    }
    
    private func loadImage(iv: UIImageView, list: [String], index: Int) {
        if list.count > index {
            iv.ss_setImage(list[index], placeholder: SSImage.userDefault)
        } else {
            iv.image = nil
        }
    }

}
