//
//  UIButton+SS.swift
//  SimpleSwift
//
//  Created by user on 2021/4/20.
//

import UIKit
//MARK: UIButton 拓展属性
public extension UIButton {
    var image: UIImage? {
        set {
            setImage(newValue, for: .normal)
        }
        get {
            return image(for: .normal)
        }
    }
    
    var selectedImage: UIImage? {
        set {
            setImage(newValue, for: .selected)
        }
        get {
            return image(for: .selected)
        }
    }
    
    var backgroundImage: UIImage? {
        set {
            setBackgroundImage(newValue, for: .normal)
        }
        get {
            return backgroundImage(for: .normal)
        }
    }
    
    var title: String? {
        set {
            setTitle(newValue, for: .normal)
        }
        get {
            return title(for: .normal)
        }
    }
    
    var titleColor: UIColor? {
        set {
            setTitleColor(newValue, for: .normal)
        }
        get {
            return titleColor(for: .normal)
        }
    }
    
    var titleFont: UIFont? {
        set {
            titleLabel?.font = newValue
        }
        get {
            return titleLabel?.font
        }
    }
}
//MARK: UIButton 构造函数
public extension UIButton {
    convenience init(title: String?, titleColor: UIColor?, titleFont: UIFont?, backgroundColor: UIColor = .clear, cornerRadius: CGFloat = 0) {
        self.init()
        self.title = title
        self.titleColor = titleColor
        self.titleFont = titleFont
        self.backgroundColor = backgroundColor
        if cornerRadius > 0 {
            self.cornerRadius = cornerRadius
        }
    }
    
    convenience init(imageName: String) {
        self.init()
        self.image = UIImage(named: imageName)
    }
    
    convenience init(normalImageName: String, selectImageName: String) {
        self.init()
        self.setImage(UIImage(named: normalImageName), for: .normal)
        self.setImage(UIImage(named: selectImageName), for: .selected)
        self.setImage(UIImage(named: selectImageName), for: .highlighted)
    }
}
