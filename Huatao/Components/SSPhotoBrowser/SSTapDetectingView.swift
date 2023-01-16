//
//  SSTapDetectingView.swift
//  Huatao
//
//  Created by minse on 2023/1/16.
//

import UIKit

protocol SSTapDetectingViewDelegate: NSObjectProtocol {
    func view(_ view: UIView, singleTapDetected touch: UITouch)
    func view(_ view: UIView, doubleTapDetected touch: UITouch)
    func view(_ view: UIView, tripleTapDetected touch: UITouch)
}

class SSTapDetectingView: UIView {
    
    weak var tapDelegate: SSTapDetectingViewDelegate?
    
    init() {
        super.init(frame: .zero)
        isUserInteractionEnabled = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            switch touch.tapCount {
            case 1:
                tapDelegate?.view(self, singleTapDetected: touch)
            case 2:
                tapDelegate?.view(self, doubleTapDetected: touch)
            case 3:
                tapDelegate?.view(self, tripleTapDetected: touch)
            default:
                break
            }
        }
        self.next?.touchesEnded(touches, with: event)
    }
}
