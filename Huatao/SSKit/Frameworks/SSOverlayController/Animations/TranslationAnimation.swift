//
//  TranslationAnimation.swift
//  Charming
//
//  Created on 2022/10/12.
//

import UIKit

public enum TranslationAnimationDirection {
    case left
    case right
    case top
    case bottom
}

public class TranslationAnimation: OverlayAnimation {
    let duration: TimeInterval
    let direction: TranslationAnimationDirection

    public init(direction: TranslationAnimationDirection, duration: TimeInterval = 0.25) {
        self.duration = duration
        self.direction = direction
    }

    public func show(targetView: UIView, context: [OverlayAnimationContextKey: Any], completion: (() -> Void)?) {
        switch direction {
        case .left:
            targetView.transform = CGAffineTransform(translationX: -targetView.bounds.width, y: 0)
        case .right:
            targetView.transform = CGAffineTransform(translationX: targetView.bounds.width, y: 0)
        case .top:
            targetView.transform = CGAffineTransform(translationX: 0, y: -targetView.bounds.height)
        case .bottom:
            targetView.transform = CGAffineTransform(translationX: 0, y: targetView.bounds.height)
        }
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
            targetView.alpha = 1
            targetView.transform = CGAffineTransform.identity
        }) { _ in
            completion?()
        }
    }

    public func dismiss(targetView: UIView, context: [OverlayAnimationContextKey: Any], completion: (() -> Void)?) {
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
            targetView.alpha = 0
            if let direction = context[.dismissInteractorDirection] as? OverlayDismissInteractorDirection {
                switch direction {
                case .left:
                    targetView.transform = targetView.transform.translatedBy(x: -targetView.bounds.width, y: 0)
                case .right:
                    targetView.transform = targetView.transform.translatedBy(x: targetView.bounds.width, y: 0)
                case .up:
                    targetView.transform = targetView.transform.translatedBy(x: 0, y: -targetView.bounds.height)
                case .down:
                    targetView.transform = targetView.transform.translatedBy(x: 0, y: targetView.bounds.height)
                default: break
                }
            } else {
                switch self.direction {
                case .left:
                    targetView.transform = CGAffineTransform(translationX: -targetView.bounds.width, y: 0)
                case .right:
                    targetView.transform = CGAffineTransform(translationX: targetView.bounds.width, y: 0)
                case .top:
                    targetView.transform = CGAffineTransform(translationX: 0, y: -targetView.bounds.height)
                case .bottom:
                    targetView.transform = CGAffineTransform(translationX: 0, y: targetView.bounds.height)
                }
            }
        }) { _ in
            completion?()
        }
    }
}
