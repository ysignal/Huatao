//
//  FadeInAnimation.swift
//  Charming
//
//  Created on 2022/10/12.
//

import UIKit

public class FadeInAnimation: OverlayAnimation {
    let duration: TimeInterval

    public init(duration: TimeInterval = 0.25) {
        self.duration = duration
    }

    public func show(targetView: UIView, context: [OverlayAnimationContextKey: Any], completion: (() -> Void)?) {
        targetView.alpha = 0
        UIView.animate(withDuration: duration, animations: {
            targetView.alpha = 1
        }) { _ in
            completion?()
        }
    }

    public func dismiss(targetView: UIView, context: [OverlayAnimationContextKey: Any], completion: (() -> Void)?) {
        UIView.animate(withDuration: duration, animations: {
            targetView.alpha = 0
        }) { _ in
            completion?()
        }
    }

    public func interaction(targetView: UIView, context: [OverlayAnimationContextKey: Any], progress: CGFloat) {
        targetView.alpha = 1 - progress
    }
}
