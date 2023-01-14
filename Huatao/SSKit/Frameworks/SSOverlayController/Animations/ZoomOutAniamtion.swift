//
//  ZoomOutAniamtion.swift
//  Charming
//
//  Created by minse on 2022/10/12.
//

import UIKit

public class ZoomOutAniamtion: OverlayAnimation {
    public init() {}
    
    public func show(targetView: UIView, context: [OverlayAnimationContextKey: Any], completion: (() -> Void)?) {
        targetView.alpha = 0
        targetView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            targetView.alpha = 1
            targetView.transform = CGAffineTransform.identity
        }) { _ in
            completion?()
        }
    }

    public func dismiss(targetView: UIView, context: [OverlayAnimationContextKey: Any], completion: (() -> Void)?) {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            targetView.alpha = 0
            targetView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            completion?()
        }
    }
}
