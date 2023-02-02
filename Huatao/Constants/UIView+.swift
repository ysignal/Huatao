//
//  UIView+.swift
//  Charming
//
//  Created by Monster on 2022/10/9.
//

import UIKit

enum BorderType {
    case inline
    case outline
}

enum ViewOption {
    case frame(CGRect)
    case size(CGSize)
    case text(String)
    case textColor(UIColor)
    case textAlignment(NSTextAlignment)
    case textShadow(UIColor, CGSize)
    case font(UIFont)
    case numberOfLines(Int)
    case keybord(UIKeyboardType)
    case placeholder(String?)
    case title(String, UIControl.State = .normal)
    case titleColor(UIColor, UIControl.State = .normal)
    case tintColor(UIColor)
    case image(UIImage?, UIControl.State = .normal)
    case backgroundColor(UIColor)
    case cornerRadius(CGFloat)
    case cornerCut(CGFloat, UIRectCorner, CGSize? = nil)
    case border(CGFloat, UIColor, BorderType = .inline)
    case tableDelegate(UITableViewDelegate, UITableViewDataSource)
    case tableHeader(UIView)
    case tableFooter(UIView)
    case registerCell(AnyClass?, UINib?, String)
    case registerHeaderFooter(AnyClass?, UINib?, String, Bool)
    case target(Any?, Selector, UIControl.Event = .touchUpInside)
    case hidden(Bool)
}

protocol QuicklySetting {
    func loadOption(_ options: [ViewOption]) -> Self
}

extension QuicklySetting {
    @discardableResult
    func loadOption(_ options: [ViewOption]) -> Self {
        options.forEach { setting in
            switch setting {
            case .frame(let rect):
                if let view = self as? UIView {
                    view.frame = rect
                }
            case .size(let size):
                if let view = self as? UIView {
                    var rect = view.frame
                    rect.size = size
                    view.frame = rect
                }
            case .text(let text):
                switch self {
                case let lbl as UILabel:
                    lbl.text = text
                case let tf as UITextField:
                    tf.text = text
                default: break
                }
            case .textColor(let color):
                switch self {
                case let lbl as UILabel:
                    lbl.textColor = color
                case let tf as UITextField:
                    tf.textColor = color
                default: break
                }
            case .textAlignment(let alignment):
                switch self {
                case let lbl as UILabel:
                    lbl.textAlignment = alignment
                case let tf as UITextField:
                    tf.textAlignment = alignment
                default: break
                }
            case .textShadow(let color, let offset):
                if let label = self as? UILabel {
                    label.shadowColor = color
                    label.shadowOffset = offset
                }
            case .font(let font):
                switch self {
                case let lbl as UILabel:
                    lbl.font = font
                case let tf as UITextField:
                    tf.font = font
                case let btn as UIButton:
                    btn.titleLabel?.font = font
                default: break
                }
            case .numberOfLines(let lines):
                if let lbl = self as? UILabel {
                    lbl.numberOfLines = lines
                }
            case .keybord(let type):
                if let tf = self as? UITextField {
                    tf.keyboardType = type
                }
            case .placeholder(let text):
                if let tf = self as? UITextField {
                    tf.placeholder = text
                }
            case .title(let title, let state):
                if let btn = self as? UIButton {
                    btn.setTitle(title, for: state)
                }
            case .titleColor(let color, let state):
                if let btn = self as? UIButton {
                    btn.setTitleColor(color, for: state)
                }
            case .tintColor(let color):
                switch self {
                case let btn as UIButton:
                    btn.tintColor = color
                default: break
                }
            case .image(let img, let state):
                switch self {
                case let iv as UIImageView:
                    iv.image = img
                case let btn as UIButton:
                    btn.setImage(img, for: state)
                default: break
                }
            case .backgroundColor(let color):
                if let view = self as? UIView {
                    view.backgroundColor = color
                }
            case .cornerRadius(let radius):
                if let view = self as? UIView {
                    view.layer.cornerRadius = radius
                    view.layer.masksToBounds = true
                }
            case .cornerCut(let radius, let corner, let size):
                if let view = self as? UIView {
                    view.layer.cornerRadius = 0
                    view.layer.masksToBounds = true
                    var bounds = view.bounds
                    if let s = size {
                        bounds.size = s
                    }
                    let maskPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: corner, cornerRadii: CGSize(width: radius, height: radius))
                    let maskLayer = CAShapeLayer()
                    maskLayer.frame = bounds
                    maskLayer.path = maskPath.cgPath
                    view.layer.mask = maskLayer
                }
            case .border(let width, let color, let type):
                if let view = self as? UIView {
                    switch type {
                    case .inline:
                        view.layer.borderWidth = width
                        view.layer.borderColor = color.cgColor
                    case .outline:
                        let layer = CALayer()
                        layer.frame = CGRect(x: view.frame.minX - width,
                                             y: view.frame.minY - width,
                                             width: view.frame.width + width*2,
                                             height: view.frame.height + width*2)
                        layer.masksToBounds = true
                        layer.cornerRadius = view.cornerRadius
                        layer.borderColor = color.cgColor
                        layer.borderWidth = width
                        view.layer.addSublayer(layer)
                    }
                }
            case .tableDelegate(let delegate, let dataSource):
                if let table = self as? UITableView {
                    table.delegate = delegate
                    table.dataSource = dataSource
                }
            case .tableHeader(let view):
                if let table = self as? UITableView {
                    table.tableHeaderView = view
                }
            case .tableFooter(let view):
                if let table = self as? UITableView {
                    table.tableFooterView = view
                }
            case .registerCell(let cellClass, let cellNib, let identifier):
                if let table = self as? UITableView {
                    if let cc = cellClass {
                        table.register(cc, forCellReuseIdentifier: identifier)
                    } else if let nib = cellNib {
                        table.register(nib, forCellReuseIdentifier: identifier)
                    }
                } else if let collection = self as? UICollectionView {
                    if let cc = cellClass {
                        collection.register(cc, forCellWithReuseIdentifier: identifier)
                    } else if let nib = cellNib {
                        collection.register(nib, forCellWithReuseIdentifier: identifier)
                    }
                }
            case .registerHeaderFooter(let cellClass, let cellNib, let identifier, let isHeader):
                if let table = self as? UITableView {
                    if let cc = cellClass {
                        table.register(cc, forHeaderFooterViewReuseIdentifier: identifier)
                    } else if let nib = cellNib {
                        table.register(nib, forHeaderFooterViewReuseIdentifier: identifier)
                    }
                } else if let collection = self as? UICollectionView {
                    let kind = isHeader ? UICollectionView.elementKindSectionHeader : UICollectionView.elementKindSectionFooter
                    if let cc = cellClass {
                        collection.register(cc, forSupplementaryViewOfKind: kind, withReuseIdentifier: identifier)
                    } else if let nib = cellNib {
                        collection.register(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: identifier)
                    }
                }
            case .target(let target, let selector, let event):
                if let control = self as? UIControl {
                    control.addTarget(target, action: selector, for: event)
                } else if let view = self as? UIView {
                    view.isUserInteractionEnabled = true
                    view.addGestureRecognizer(UITapGestureRecognizer(target: target, action: selector))
                }
            case .hidden(let isHidden):
                if let view = self as? UIView {
                    view.isHidden = isHidden
                }
            }
        }
        return self
    }
}

extension UIView: QuicklySetting {}

/// 渐变色渲染方向，如果需要反向只需要将开始颜色和结束颜色交换输入即可
enum GradientDirection: Int {
    // 从左到右
    case l2r = 0
    // 从上到下
    case t2b
    // 从左上到右下
    case lt2rb
    // 从右上到左下
    case rt2lb
}

extension UIView {
    func drawGradient(start: UIColor, end: UIColor, size: CGSize = .zero, direction: GradientDirection = .l2r) {
        layer.sublayers?.forEach({ sublayer in
            if sublayer is CAGradientLayer {
                sublayer.removeFromSuperlayer()
            }
        })
        let colors = [start.cgColor, end.cgColor]
        let gradient = CAGradientLayer()
        switch direction {
        case .l2r:
            gradient.startPoint = CGPoint(x: 0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1, y: 0.5)
        case .t2b:
            gradient.startPoint = CGPoint(x: 0.5, y: 0)
            gradient.endPoint = CGPoint(x: 0.5, y: 1)
        case .lt2rb:
            gradient.startPoint = CGPoint(x: 0, y: 0)
            gradient.endPoint = CGPoint(x: 1, y: 1)
        case .rt2lb:
            gradient.startPoint = CGPoint(x: 1, y: 0)
            gradient.endPoint = CGPoint(x: 0, y: 1)
        }
        gradient.colors = colors
        if size == .zero {
            gradient.frame = bounds
        } else {
            gradient.frame = CGRect(origin: .zero, size: size)
        }
        layer.insertSublayer(gradient, at: 0)
    }
    
    
    func drawDashLine(lineSpacing: Int, lineLength: Int) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.bounds = bounds
        shapeLayer.position = CGPoint(x: frame.width/2, y: frame.height/2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        // 设置虚线颜色
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = frame.height
        shapeLayer.lineJoin = .round
        shapeLayer.lineDashPattern = [NSNumber(value: lineLength), NSNumber(value: lineSpacing)]
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: frame.height/2))
        path.addLine(to: CGPoint(x: frame.width + CGFloat(lineLength) + CGFloat(lineSpacing), y: frame.height/2))
        shapeLayer.path = path
        
        layer.addSublayer(shapeLayer)
        clipsToBounds = true
    }
    
    func removeAllSubviews() {
        for view in subviews {
            view.removeFromSuperview()
        }
    }
}

extension UIView {
    var ex_height: CGFloat {
        get {
            return frame.height
        }
        set {
            var rect = frame
            rect.size.height = newValue
            frame = rect
        }
    }
    
    var ex_width: CGFloat {
        get {
            return frame.width
        }
        set {
            var rect = frame
            rect.size.width = newValue
            frame = rect
        }
    }
    
    var ex_x: CGFloat {
        get {
            return frame.origin.x
        }
        set {
            var rect = frame
            rect.origin.x = newValue
            frame = rect
        }
    }
    
    var ex_y: CGFloat {
        get {
            return frame.origin.y
        }
        set {
            var rect = frame
            rect.origin.y = newValue
            frame = rect
        }
    }
}
