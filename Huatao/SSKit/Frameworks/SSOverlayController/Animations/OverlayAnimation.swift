//
//  OverlayAnimation.swift
//  Charming
//
//  Created on 2022/10/12.
//

import UIKit

public struct OverlayAnimationContextKey: Hashable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// dimiss手势交互方向
    public static let dismissInteractorDirection = OverlayAnimationContextKey(rawValue: "dismissInteractorDirection")
}

public protocol OverlayAnimation {
    func show(targetView: UIView, context: [OverlayAnimationContextKey: Any], completion: (() -> Void)?)
    func dismiss(targetView: UIView, context: [OverlayAnimationContextKey: Any], completion: (() -> Void)?)
    func interaction(targetView: UIView, context: [OverlayAnimationContextKey: Any], progress: CGFloat)
}

public extension OverlayAnimation {
    func interaction(targetView: UIView, context: [OverlayAnimationContextKey: Any], progress: CGFloat) {}
}
