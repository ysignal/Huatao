//
//  UILabel+SS.swift
//  SimpleSwift
//
//  Created by user on 2021/4/20.
//

import UIKit

// MARK: Initialization
public extension UILabel {
    
    convenience init(text : String?,
                     textColor : UIColor?,
                     textFont : UIFont?,
                     textAlignment: NSTextAlignment = .left,
                     numberLines: Int = 1) {
        self.init()
        self.text = text
        self.textColor = textColor ?? .black
        self.font = textFont ?? .systemFont(ofSize: 17.0)
        self.textAlignment = textAlignment
        self.numberOfLines = numberLines
        self.clipsToBounds = false
    }
}

// MARK: Methods
public extension UILabel {

    /// Calculates the height based on the maximum width and the number of lines of text.
    /// - Parameters:
    ///   - maxWidth: The max width used for calculation.
    ///   - maxLine: The max line used for calculation.
    /// - Returns: The computed height.
    func pre_h(maxWidth: CGFloat, maxLine: Int = 0) -> CGFloat {
        let label = UILabel(frame: CGRect(
            x: 0,
            y: 0,
            width: maxWidth,
            height: .greatestFiniteMagnitude)
        )
        label.backgroundColor = backgroundColor
        label.lineBreakMode = lineBreakMode
        label.font = font
        label.text = text
        label.textAlignment = textAlignment
        label.numberOfLines = maxLine
        label.attributedText = attributedText
        label.sizeToFit()
        return label.frame.height
    }

    /// Calculates the width based on the maximum height and the number of lines of text.
    /// - Parameters:
    ///   - maxHeight: The max height used for calculation.
    ///   - maxLine: The max line used for calculation.
    /// - Returns: The computed width.
    func pre_w(maxHeight: CGFloat, maxLine: Int = 0) -> CGFloat {
        let label = UILabel(frame: CGRect(
            x: 0,
            y: 0,
            width: .greatestFiniteMagnitude,
            height: maxHeight)
        )
        label.backgroundColor = backgroundColor
        label.lineBreakMode = lineBreakMode
        label.font = font
        label.text = text
        label.textAlignment = textAlignment
        label.numberOfLines = maxLine
        label.attributedText = attributedText
        label.sizeToFit()
        return label.frame.width
    }
    
}
