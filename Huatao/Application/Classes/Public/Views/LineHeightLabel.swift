//
//  LineHeightLabel.swift
//  Huatao
//
//  Created on 2023/1/16.
//

import UIKit

class LineHeightLabel: UILabel {

    private var ss_lineHeight: CGFloat = 0
    private var ss_headIndent: CGFloat = 0
    
    /// 设置行高
    @IBInspectable var lineHeight: CGFloat {
        set {
            ss_lineHeight = newValue
        }
        get {
            if ss_lineHeight > 0 {
                return ss_lineHeight
            }
            return font.lineHeight
        }
    }
    
    /// 设置首行缩进
    @IBInspectable var headIndent: CGFloat {
        set {
            ss_headIndent = newValue
        }
        get {
            if ss_headIndent > 0 {
                return ss_headIndent
            }
            return 0
        }
    }
    
    override var text: String? {
        didSet {
            if let str = text, str.count > 1 {
                let style = NSMutableParagraphStyle()
                style.lineSpacing = lineHeight - font.lineHeight
                style.firstLineHeadIndent = headIndent
                style.alignment = textAlignment
                let attrStr = NSAttributedString(string: str, attributes: [.paragraphStyle: style])
                attributedText = attrStr
            }
        }
    }
    
    func textHeight(with size: CGSize) -> CGFloat {
        return attributedText?.boundingRect(with: size, options: .usesLineFragmentOrigin, context: nil).height ?? 0
    }

}
