//
//  MultipleIconView.swift
//  Huatao
//
//  Created on 2023/2/20.
//  
	

import UIKit

class MultipleIconView: UIView {
    
    lazy var mainView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    init(images: [String], backgroundColor: UIColor = .hex("dddddd"), cornerRadius: CGFloat = 18) {
        super.init(frame: .zero)
        self.backgroundColor = backgroundColor
        self.layer.cornerRadius = 18
        self.layer.masksToBounds = true
        self.config(images: images)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func config(images: [String]) {
        
        
    }
    
    private func loadImage(iv: UIImageView, list: [String], index: Int) {
        if list.count > index {
            iv.ss_setImage(list[index], placeholder: SSImage.userDefault)
        } else {
            iv.image = nil
        }
    }
}
