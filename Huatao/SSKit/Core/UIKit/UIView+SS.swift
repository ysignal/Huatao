//
//  UIView+SS.swift
//  SimpleSwift
//
//  Created by user on 2021/4/20.
//

import UIKit

/// 线的位置
public enum LinePosition: Int {
    case top = 0
    case bottom = 1
    case center = 2
}

/// UIView的构造和函数
public extension UIView {
    convenience init(backgroundColor: UIColor = .white, cornerRadius: CGFloat? = nil) {
        self.init()
        self.backgroundColor = backgroundColor
        
        if let radius = cornerRadius {
            self.cornerRadius = radius
        }
    }
    
    /// 从nib初始化一个View
    static func fromNib(bundle: Bundle? = nil) -> Self {
        return UINib(nibName: named, bundle: bundle).instantiate(withOwner: nil, options: nil)[0] as! Self
    }
    
    /// 添加阴影
    func shadow(ofColor color: UIColor = UIColor(red: 0.07, green: 0.47, blue: 0.57, alpha: 1.0), radius: CGFloat = 3, offset: CGSize = .zero, opacity: Float = 0.2) {
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.masksToBounds = false
    }
    
    /// 添加阴影图层
    func shadowLayer(ofColor color: UIColor = UIColor(red: 0.07, green: 0.47, blue: 0.57, alpha: 1.0), radius: CGFloat = 3, offset: CGSize = .zero, opacity: Float = 0.5,cornerRadius:CGFloat,bounds:CGRect) {
        
        let layer = CALayer()
        layer.frame = bounds
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = false
        layer.backgroundColor = UIColor.white.cgColor
        self.layer.insertSublayer(layer, at: 0)

    }

    
    /// 添加细线 ply线高
    @discardableResult
    func line(position : LinePosition, color : UIColor, ply : CGFloat, leftPadding : CGFloat, rightPadding : CGFloat) -> UIView {
        let line = UIView.init()
        line.backgroundColor = color;
        line.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(line)
        line.leftAnchor.constraint(equalTo: leftAnchor, constant: leftPadding).isActive = true
        line.rightAnchor.constraint(equalTo: leftAnchor, constant: rightPadding).isActive = true
        line.heightAnchor.constraint(equalToConstant: ply).isActive = true
        switch position {
        case .top:
            line.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        case .bottom:
            line.bottomAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        case .center:
            line.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0).isActive = true
            line.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0).isActive = true
        }
        return line
    }
    
    /// 添加点击手势
    @discardableResult
    func tapGestureRecognizer(target : Any?, action : Selector?, numberOfTapsRequired: Int = 1, numberOfTouchesRequired: Int = 1) -> UITapGestureRecognizer {
        
        let tapGesture = UITapGestureRecognizer.init(target: target, action: action)
        tapGesture.numberOfTapsRequired    = numberOfTapsRequired;
        tapGesture.numberOfTouchesRequired = numberOfTouchesRequired;
        tapGesture.cancelsTouchesInView    = true;
        tapGesture.delaysTouchesBegan      = true;
        tapGesture.delaysTouchesEnded      = true;
        
        self.addGestureRecognizer(tapGesture)
        self.isUserInteractionEnabled = true
        
        return tapGesture
    }
    /// 添加长按手势
    @discardableResult
    func addLongPressGestureRecognizer(target : Any?, action : Selector?, pressDuration: Double = 1) -> UILongPressGestureRecognizer {
        
        let longPressGesture = UILongPressGestureRecognizer.init(target: target, action: action)
        longPressGesture.minimumPressDuration    = pressDuration;
        self.addGestureRecognizer(longPressGesture)
        self.isUserInteractionEnabled = true
        return longPressGesture
    }
    
    /// 获取view的UIViewController
    func parentViewController() -> UIViewController? {
        for view in sequence(first: self.superview, next: {$0?.superview}){
            if let responder = view?.next{
                if responder.isKind(of: UIViewController.self){
                    return responder as? UIViewController
                }
            }
        }
        return nil
    }
    /// 添加顶部mask
    func topCornerRadius(rect: CGRect, radius: CGFloat){
        cornerRadius(position: [.topLeft, .topRight], cornerRadius: radius, roundedRect:rect)
    }
    
    /// 使用贝塞尔曲线设置圆角
    func cornerRadius(position: UIRectCorner, cornerRadius: CGFloat, roundedRect: CGRect) {
        let path = UIBezierPath(roundedRect:roundedRect, byRoundingCorners: position, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        let layer = CAShapeLayer()
        layer.frame = roundedRect
        layer.path = path.cgPath
        self.layer.mask = layer
    }
    
    func drawBorderDottedLine(width: CGFloat, length: CGFloat, space: CGFloat, cornerRadius: CGFloat, color: UIColor) {
        layer.cornerRadius = cornerRadius
        let borderLayer = CAShapeLayer()
        borderLayer.bounds = bounds
        borderLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        borderLayer.path = UIBezierPath(roundedRect: borderLayer.bounds, cornerRadius: cornerRadius).cgPath
        borderLayer.lineWidth = width/SS.screenScale
        
        borderLayer.lineDashPattern = [length, space] as? [NSNumber]
        borderLayer.lineDashPhase = 0.1
        
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = color.cgColor
        layer.addSublayer(borderLayer)
    }
}

public extension UIView {
    /// 设置圆角
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.masksToBounds = true
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    /// 边框宽度
    @IBInspectable var borderWidth: CGFloat {
        set { layer.borderWidth = newValue }
        get { return layer.borderWidth }
    }
    
    /// 边框颜色
    @IBInspectable var borderColor: UIColor? {
        set { layer.borderColor = newValue?.cgColor }
        get {  return layer.borderColor == nil ? nil : UIColor(cgColor: layer.borderColor!) }
    }
    
    /// 设置边框线颜色和宽度
    func border(color: UIColor, width: CGFloat = 1.0) {
        layer.masksToBounds = true
        layer.borderColor = color.cgColor
        layer.borderWidth = width
    }
    
    /// 将当前视图转为UIImage
    func screenshots() -> UIImage? {
        let `renderer` = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { (context) in
            layer.render(in: context.cgContext)
        }
    }
}

// MARK: - view + BlurView

extension UIView {
    
    private struct BlurAssociatedKeys {
        static var descriptiveName = "AssociatedKeys.DescriptiveName.blurView"
    }
    
    private (set) var blur: BlurView {
        get {
            if let blurView = objc_getAssociatedObject(
                self,
                &BlurAssociatedKeys.descriptiveName
            ) as? BlurView {
                return blurView
            }
            self.blur = BlurView(to: self)
            return self.blur
        }
        set(blurView) {
            objc_setAssociatedObject(
                self,
                &BlurAssociatedKeys.descriptiveName,
                blurView,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    func addAlignedConstrains() {
        translatesAutoresizingMaskIntoConstraints = false
        addAlignConstraintToSuperview(attribute: NSLayoutConstraint.Attribute.top)
        addAlignConstraintToSuperview(attribute: NSLayoutConstraint.Attribute.leading)
        addAlignConstraintToSuperview(attribute: NSLayoutConstraint.Attribute.trailing)
        addAlignConstraintToSuperview(attribute: NSLayoutConstraint.Attribute.bottom)
    }

    func addAlignConstraintToSuperview(attribute: NSLayoutConstraint.Attribute) {
        superview?.addConstraint(
            NSLayoutConstraint(
                item: self,
                attribute: attribute,
                relatedBy: NSLayoutConstraint.Relation.equal,
                toItem: superview,
                attribute: attribute,
                multiplier: 1,
                constant: 0
            )
        )
    }

}
/// 高斯模糊
class BlurView {
    
    private var superview: UIView
    private var blur: UIVisualEffectView?
    private var editing: Bool = false
    private (set) var blurContentView: UIView?
    private (set) var vibrancyContentView: UIView?
    
    var animationDuration: TimeInterval = 0.1
    
    /**
     * Blur style. After it is changed all subviews on
     * blurContentView & vibrancyContentView will be deleted.
     */
    var style: UIBlurEffect.Style = .light {
        didSet {
            guard oldValue != style,
                  !editing else { return }
            applyBlurEffect()
        }
    }
    /**
     * Alpha component of view. It can be changed freely.
     */
    var alpha: CGFloat = 0 {
        didSet {
            guard !editing else { return }
            if blur == nil {
                applyBlurEffect()
            }
            let alpha = self.alpha
            UIView.animate(withDuration: animationDuration) {
                self.blur?.alpha = alpha
            }
        }
    }
    
    init(to view: UIView) {
        self.superview = view
    }
    
    func setup(style: UIBlurEffect.Style, alpha: CGFloat) -> Self {
        self.editing = true
        
        self.style = style
        self.alpha = alpha
        
        self.editing = false
        
        return self
    }
    
    func enable(isHidden: Bool = false) {
        if blur == nil {
            applyBlurEffect()
        }
        
        self.blur?.isHidden = isHidden
    }
    
    private func applyBlurEffect() {
        blur?.removeFromSuperview()
        
        applyBlurEffect(
            style: style,
            blurAlpha: alpha
        )
    }
    
    private func applyBlurEffect(style: UIBlurEffect.Style,
                                 blurAlpha: CGFloat) {
        superview.backgroundColor = UIColor.clear
        
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        blurEffectView.contentView.addSubview(vibrancyView)
        
        blurEffectView.alpha = blurAlpha
        
        superview.insertSubview(blurEffectView, at: 0)
        
        blurEffectView.addAlignedConstrains()
        vibrancyView.addAlignedConstrains()
        
        self.blur = blurEffectView
        self.blurContentView = blurEffectView.contentView
        self.vibrancyContentView = vibrancyView.contentView
    }
}

