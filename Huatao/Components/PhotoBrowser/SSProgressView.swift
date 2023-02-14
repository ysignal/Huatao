//
//  SSProgressView.swift
//  Huatao
//
//  Created on 2023/1/16.
//
import UIKit

class SSProgressView: UIView {

    private lazy var progressLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.white.cgColor
        layer.lineCap = .round
        layer.lineWidth = 4
        return layer
    }()
    
    var progress: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        layer.addSublayer(progressLayer)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let radius = rect.width / 2
        let end = -(.pi / 2) + (.pi * 2 * progress)
        progressLayer.frame = bounds
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: -(.pi / 2), endAngle: end, clockwise: true)
        progressLayer.path = path.cgPath
    }

}
