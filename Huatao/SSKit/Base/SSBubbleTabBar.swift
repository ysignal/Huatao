//
//  SSBubbleTabBar.swift
//  SimpleSwift
//
//  Created by user on 2021/4/20.
//

import UIKit

/// 默认两个tab，一个凸起
open class SSBubbleTabBar: UITabBar {
    
    open var onSelect: ((Int) -> ())?
    open var bgImageName: String!
    open var centerBtnImageName: String!
    open var centerBtnTag = 0
    
    private var centerBtn: UIButton?
    private var bgImageView = UIImageView()

    var barBackgroundColor: UIColor = .white
    var borderRadio: CGFloat = 16
    private var centerBtnSize: CGFloat = 59.0
    private var centerBtnSpace: CGFloat = 3.0
    private var centerBtnOffsetY: CGFloat = 20
    private let imageSize: CGSize = CGSize(width: SS.w, height: SS.safeBottomHeight + (SS.isX ? 60 : 49))
    
    public init(frame: CGRect,
                bgImageName: String = "",
                centerBtnImageName: String,
                centerBtnSize: CGFloat,
                centerBtnOffsetY: CGFloat) {
        super.init(frame: frame)
        self.bgImageName = bgImageName
        self.centerBtnImageName = centerBtnImageName
        self.centerBtnSize = centerBtnSize
        self.centerBtnOffsetY = centerBtnOffsetY
        buildUI()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    private func buildUI() {
        // 去除系统tabBar的顶部细线
        barStyle = .black
        backgroundImage = UIImage()
        shadowImage = UIImage()
        tintColor = .black
        // 设置背景
        bgImageView = UIImageView(frame: CGRect(origin: .zero, size: imageSize))
        bgImageView.image = UIImage(color: .white)
        bgImageView.backgroundColor = .clear
        addSubview(bgImageView)
        
        // 中间按钮
        let button = UIButton(frame: .zero)
        button.cornerRadius = centerBtnSize/2
        centerBtn = button
        let buttonImage = UIImage(named: centerBtnImageName)
        let selectedImage = UIImage(named: centerBtnImageName + "_sel")
        button.image = buttonImage
        button.selectedImage = selectedImage
        
        if let size = buttonImage?.size, button.frame.width < size.width {
            let imageX: CGFloat = (SS.w - size.width)/2
            let offset = (size.width - centerBtnSize)/2
            button.frame = CGRect(x: imageX, y: -centerBtnOffsetY - offset, width: size.width, height: size.height)
        } else {
            let button_x: CGFloat = (SS.w - centerBtnSize)/2
            button.frame = CGRect(x: button_x, y: -centerBtnOffsetY, width: centerBtnSize, height: centerBtnSize)
        }

        button.tag = 1
        button.addTarget(self, action: #selector(tabBarButtonClicked(sender:)), for: .touchUpInside)
        addSubview(button)
        
        drawBackgroundImage()
        backgroundColor = .clear
    }
    
    func drawBackgroundImage() {
        UIGraphicsBeginImageContextWithOptions(imageSize, false, UIScreen.main.scale)
        if let context = UIGraphicsGetCurrentContext() {
            UIColor.clear.setFill()
            let centerX = imageSize.width / 2
            let centerRadio = centerBtnSize / 2
            
            context.move(to: CGPoint(x: 0, y: imageSize.height))
            context.addLine(to: CGPoint(x: 0, y: borderRadio))
            
            context.addArc(tangent1End: CGPoint(x: 0, y: 0), tangent2End: CGPoint(x: borderRadio, y: 0), radius: borderRadio)

            context.addLine(to: CGPoint(x: centerX - centerRadio - centerBtnSpace - borderRadio, y: 0))
            
            context.addArc(tangent1End: CGPoint(x: centerX - centerRadio - centerBtnSpace, y: 0), tangent2End: CGPoint(x: centerX - centerRadio - centerBtnSpace, y: borderRadio), radius: borderRadio)
            
            context.addArc(center: CGPoint(x: centerX, y: borderRadio), radius: centerRadio + centerBtnSpace, startAngle: CGFloat.pi, endAngle: 0, clockwise: true)
            
            context.addArc(tangent1End: CGPoint(x: centerX + centerBtnSize/2 + centerBtnSpace, y: 0), tangent2End: CGPoint(x: centerX + centerBtnSize/2 + centerBtnSpace + borderRadio, y: 0), radius: borderRadio)
            
            context.addLine(to: CGPoint(x: imageSize.width - borderRadio, y: 0))
            
            context.addArc(tangent1End: CGPoint(x: imageSize.width, y: 0), tangent2End: CGPoint(x: imageSize.width, y: borderRadio), radius: borderRadio)
            
            context.addLine(to: CGPoint(x: imageSize.width, y: imageSize.height))
            
            context.closePath()
            context.setFillColor(barBackgroundColor.cgColor)
            context.fillPath()
        }
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            bgImageView.image = image
        }
        UIGraphicsEndImageContext()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        resizeBarItems()
    }
    
    private func resizeBarItems() {
        let width = (SS.w - centerBtnSize - (centerBtnSpace * 2))/4
        var btnIndex: CGFloat = 0
        for subview in subviews {
            if subview.named == "UITabBarButton" {
                subview.ex_width = width
                if btnIndex < 2 {
                    subview.ex_x = btnIndex * width + (btnIndex * itemSpacing)
                } else if btnIndex == 2 {
                    subview.isUserInteractionEnabled = false
                    subview.alpha = 0
                } else {
                    subview.ex_x = centerBtnSize + (centerBtnSpace * 2) + (btnIndex - 1) * width + ((btnIndex - 1) * itemSpacing)
                }
                btnIndex += 1
            }
        }
    }
    
    @objc private func tabBarButtonClicked(sender: UIButton) {
        sender.isSelected = true
        if let handler = self.onSelect {
            handler(sender.tag)
        }
        if let list = items, centerBtnTag < list.count {
            delegate?.tabBar?(self, didSelect: list[centerBtnTag])
        }
    }
    
    func resetCenter() {
        centerBtn?.isSelected = false
    }
    
    //处理超出区域点击无效的问题
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if !isHidden {
            // 转换坐标
            if let tempPoint = centerBtn?.convert(point, from: self){
                // 判断点击的点是否在按钮区域内
                if centerBtn?.bounds.contains(tempPoint) ?? false {
                    // 返回按钮
                    return centerBtn
                }
            }
        }
        return super.hitTest(point, with: event)
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: SS.w, height: SS.safeBottomHeight + (SS.isX ? 60 : 49))
    }
}
