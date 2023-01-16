//
//  SSTapDetectingImageView.swift
//  Huatao
//
//  Created by minse on 2023/1/16.
//

import UIKit

protocol SSTapDetectingImageViewDelegate: NSObjectProtocol {
    func imageView(_ imageView: UIImageView, singleTapDetected touch: UITouch)
    func imageView(_ imageView: UIImageView, doubleTapDetected touch: UITouch)
    func imageView(_ imageView: UIImageView, tripleTapDetected touch: UITouch)
}

class SSTapDetectingImageView: UIImageView {
    
    weak var tapDelegate: SSTapDetectingImageViewDelegate?
    
    init() {
        super.init(frame: .zero)
        isUserInteractionEnabled = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
    }
    
    override init(image: UIImage?) {
        super.init(image: image)
        isUserInteractionEnabled = true
    }
    
    override init(image: UIImage?, highlightedImage: UIImage?) {
        super.init(image: image, highlightedImage: highlightedImage)
        isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            switch touch.tapCount {
            case 1:
                tapDelegate?.imageView(self, singleTapDetected: touch)
            case 2:
                tapDelegate?.imageView(self, doubleTapDetected: touch)
            case 3:
                tapDelegate?.imageView(self, tripleTapDetected: touch)
            default:
                break
            }
        }
        self.next?.touchesEnded(touches, with: event)
    }
}
