//
//  SSCircularProgressView.swift
//  Huatao
//
//  Created by minse on 2023/1/16.
//

import UIKit

class SSCircularProgressLayer: CALayer {
    
    var trackTintColor: UIColor = .white.withAlphaComponent(0.3) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var progressTintColor: UIColor = .white {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var roundedCorners: Bool = true {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var thicknessRatio: CGFloat = 0.3 {
        didSet {
            setNeedsDisplay()
        }
    }
    var progress: CGFloat = 0
    
    override func draw(in ctx: CGContext) {
        let rect = bounds
        let centerPoint = CGPoint(x: bounds.width/2, y: bounds.height/2)
        let radius = min(rect.size.width, rect.size.height)/2
        let progressValue = min(progress, 1 - CGFloat.ulpOfOne)
        let radians = progressValue*2*CGFloat.pi - CGFloat.pi/2
        
        ctx.setFillColor(trackTintColor.cgColor)
        let path = UIBezierPath()
        path.move(to: centerPoint)
        path.addArc(withCenter: centerPoint, radius: radius, startAngle: 3*CGFloat.pi/2, endAngle: -CGFloat.pi/2, clockwise: false)
        path.close()
        ctx.addPath(path.cgPath)
        ctx.fillPath()
        
        if progress > 0 {
            ctx.setFillColor(progressTintColor.cgColor)
            let progressPath = UIBezierPath()
            progressPath.move(to: centerPoint)
            progressPath.addArc(withCenter: centerPoint, radius: radius, startAngle: 3*CGFloat.pi/2, endAngle: radians, clockwise: false)
            progressPath.close()
            ctx.addPath(progressPath.cgPath)
            ctx.fillPath()
        }
        if progress > 0 && roundedCorners {
            let pathWidth = radius * thicknessRatio
            let xOffset = radius * (1 + ((1 - thicknessRatio/2) * cos(radians)))
            let yOffset = radius * (1 + ((1 - thicknessRatio/2) * sin(radians)))
            let endPoint = CGPoint(x: xOffset, y: yOffset)
            ctx.addEllipse(in: CGRect(x: centerPoint.x - pathWidth/2, y: 0, width: pathWidth, height: pathWidth))
            ctx.fillPath()
            ctx.addEllipse(in: CGRect(x: endPoint.x - pathWidth/2, y: endPoint.y - pathWidth/2, width: pathWidth, height: pathWidth))
            ctx.fillPath()
        }
        ctx.setBlendMode(.clear)
        let innerRadius = radius * (1 - thicknessRatio)
        let newCenterPoint = CGPoint(x: centerPoint.x - innerRadius, y: centerPoint.y - innerRadius)
        ctx.addEllipse(in: CGRect(x: newCenterPoint.x, y: newCenterPoint.y, width: innerRadius*2, height: innerRadius*2))
        ctx.fillPath()
    }

}

class SSCircularProgressView: UIView {

    var trackTintColor: UIColor {
        get {
            return progressLayer.trackTintColor
        }
        set {
            progressLayer.trackTintColor = newValue
        }
    }
    
    var progressTintColor: UIColor {
        get {
            return progressLayer.progressTintColor
        }
        set {
            progressLayer.progressTintColor = newValue
        }
    }
    
    var roundedCorners: Bool {
        get {
            return progressLayer.roundedCorners
        }
        set {
            progressLayer.roundedCorners = newValue
        }
    }
    
    var thicknessRatio: CGFloat {
        get {
            return progressLayer.thicknessRatio
        }
        set {
            progressLayer.thicknessRatio = newValue
        }
    }
    
    var progress: CGFloat {
        get {
            return progressLayer.progress
        }
        set {
            progressLayer.progress = newValue
        }
    }
    
    lazy var progressLayer: SSCircularProgressLayer = {
        return SSCircularProgressLayer()
    }()

    var indeterminateDuration: CGFloat = 2
    var indeterminate: Int = 0

    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        backgroundColor = .clear
        progressLayer.frame = bounds
        layer.addSublayer(progressLayer)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        progressLayer.frame = bounds
        layer.addSublayer(progressLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class var layerClass: AnyClass {
        return SSCircularProgressLayer.self
    }
    
    override func didMoveToWindow() {
        progressLayer.contentsScale = SS.screenScale
    }

    func setProgress(_ progress: CGFloat, animated: Bool = false) {
        progressLayer.removeAnimation(forKey: "indeterminateAnimation")
        progressLayer.removeAnimation(forKey: "progress")
        let pinnedProgress = min(max(progress, 0), 1)
        if animated {
            let animation = CABasicAnimation(keyPath: "progress")
            animation.duration = abs(progress - pinnedProgress)
            animation.timingFunction = .init(name: .easeInEaseOut)
            animation.fromValue = NSNumber(floatLiteral: progress)
            animation.toValue = NSNumber(floatLiteral: pinnedProgress)
            progressLayer.add(animation, forKey: "progress")
        } else {
            progressLayer.setNeedsDisplay()
        }
        progressLayer.progress = pinnedProgress
    }

    func hasIndeterminate() -> Bool {
        return progressLayer.animation(forKey: "indeterminateAnimation") != nil
    }

    func updateIndeterminate(_ indeterminate: Bool) {
        if indeterminate && self.indeterminate == 0 {
            let spinAnimation = CABasicAnimation(keyPath: "transform.rotation")
            spinAnimation.byValue = indeterminate ? 2*CGFloat.pi : -2*CGFloat.pi
            spinAnimation.duration = indeterminateDuration
            spinAnimation.repeatCount = .infinity
            progressLayer.add(spinAnimation, forKey: "indeterminateAnimation")
        } else {
            progressLayer.removeAnimation(forKey: "indeterminateAnimation")
        }
    }

}
