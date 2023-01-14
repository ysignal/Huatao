//
//  ExpandedAnimation.swift
//  Charming
//
//  Created by minse on 2022/10/12.
//

import UIKit

public class ExpandedAnimation: OverlayAnimation {
    let duration: TimeInterval

    public init(duration: TimeInterval = 0.25) {
        self.duration = duration
    }

    public func show(targetView: UIView, context: [OverlayAnimationContextKey: Any], completion: (() -> Void)?) {
        let frame = targetView.frame
        targetView.layer.anchorPoint = CGPoint(x: 0.5, y: 0)
        targetView.frame = frame
        targetView.transform = CGAffineTransform(scaleX: 1, y: 0)
        UIView.animate(withDuration: duration, animations: {
            targetView.transform = CGAffineTransform.identity
        }) { _ in
            completion?()
        }
    }

    public func dismiss(targetView: UIView, context: [OverlayAnimationContextKey: Any], completion: (() -> Void)?) {
        UIView.animate(withDuration: duration, animations: {
            targetView.transform = CGAffineTransform(scaleX: 1, y: 0.000001)
        }) { _ in
            completion?()
        }
    }
}
