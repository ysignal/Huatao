//
//  SSTextView.swift
//  SimpleSwift
//
//  Created on 2023/1/29.
//

import UIKit

class SSTextView: UITextView {

    // MARK: - 开放属性
    
    /// 检测文本内容决定是否显示占位符
    open var isEmpty: Bool { return text.isEmpty }
    
    /// 此占位符是当textView文本内容为空时显示的字符, 默认是nil
    @IBInspectable open var placeholder: String? { didSet { setNeedsDisplay() } }
    
    /// 占位符的文字颜色. 这个属性适用于整个占位符字符串, 默认占位符颜色是UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
    @IBInspectable open var placeholderColor: UIColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0) { didSet { setNeedsDisplay() } }
    
    /// textView可输入的最大字数
    @IBInspectable open var maxCharacters: Int = Int.max
    // MARK: - 父类属性
    
    override open var attributedText: NSAttributedString! { didSet { setNeedsDisplay() } }
    
    override open var bounds: CGRect { didSet { setNeedsDisplay() } }
    
    override open var contentInset: UIEdgeInsets { didSet { setNeedsDisplay() } }
    
    override open var font: UIFont? { didSet { setNeedsDisplay() } }
    
    override open var textAlignment: NSTextAlignment { didSet { setNeedsDisplay() } }
    
    override open var textContainerInset: UIEdgeInsets { didSet { setNeedsDisplay() } }
    
    override open var typingAttributes: [NSAttributedString.Key : Any] {
        didSet {
            guard isEmpty else {
                return
            }
            setNeedsDisplay()
        }
    }
    
    // MARK: - 生命周期
    deinit {
        NotificationCenter.default.removeObserver(self, name: UITextView.textDidChangeNotification, object: self)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInitializer()
    }
    
    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInitializer()
    }
    
    // MARK: - Drawing
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard isEmpty else {
            return
        }
        guard let placeholder = self.placeholder else {
            return
        }
        
        var placeholderAttributes = typingAttributes
        if placeholderAttributes.has(key: .font) {
            placeholderAttributes[.font] = typingAttributes[.font] ?? font ?? UIFont.systemFont(ofSize: UIFont.systemFontSize)
        }
        if placeholderAttributes.has(key: .paragraphStyle) {
            let typingParagraphStyle = typingAttributes[.paragraphStyle]
            if typingParagraphStyle == nil {
                let paragraphStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
                paragraphStyle.alignment = textAlignment
                paragraphStyle.lineBreakMode = textContainer.lineBreakMode
                placeholderAttributes[.paragraphStyle] = paragraphStyle
            } else {
                placeholderAttributes[.paragraphStyle] = typingParagraphStyle
            }
        }
        placeholderAttributes[.foregroundColor] = placeholderColor
        
        let placeholderInsets = UIEdgeInsets(top: contentInset.top + textContainerInset.top,
                                             left: contentInset.left + textContainerInset.left + textContainer.lineFragmentPadding,
                                             bottom: contentInset.bottom + textContainerInset.bottom,
                                             right: contentInset.right + textContainerInset.right + textContainer.lineFragmentPadding)
        
        let placeholderRect = rect.inset(by: placeholderInsets)
        placeholder.draw(in: placeholderRect, withAttributes: placeholderAttributes)
    }
    
    // MARK: - Helper Methods
    fileprivate func commonInitializer() {
        contentMode = .topLeft
        NotificationCenter.default.addObserver(self, selector: #selector(SSTextView.handleTextViewTextDidChangeNotification(_:)), name: UITextView.textDidChangeNotification, object: self)
    }
    
    @objc internal func handleTextViewTextDidChangeNotification(_ notification: Notification) {
        guard let object = notification.object as? SSTextView, object === self else {
            return
        }
        if markedTextRange == nil {
            if text.count > maxCharacters {
                text = String(text.prefix(maxCharacters))
            }
        }
        setNeedsDisplay()
    }

}
