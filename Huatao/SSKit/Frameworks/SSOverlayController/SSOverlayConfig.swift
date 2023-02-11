//
//  SSOverlayConfig.swift
//  Charming
//
//  Created on 2022/10/12.
//

import UIKit

/// Overlay背景样式
public enum OverlayBackMode {
    case none
    case color(color: UIColor)
    case blur(style: UIBlurEffect.Style)
}

/// Overlayer背景行为
public enum OverlayBackBehavior {
    case none
    /// dismiss
    case dismiss
    /// 不会阻断事件
    case hollow
}

/// Overlay内容视图位置
public enum OverlayContentLocation {
    case top
    case center
    case bottom
    case right
    case left
}

/// Overlay dismiss手势滑动方向
public struct OverlayDismissInteractorDirection: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let up = OverlayDismissInteractorDirection(rawValue: 1 << 0)
    public static let down = OverlayDismissInteractorDirection(rawValue: 1 << 1)
    public static let left = OverlayDismissInteractorDirection(rawValue: 1 << 2)
    public static let right = OverlayDismissInteractorDirection(rawValue: 1 << 3)
}

/// Overlay dismiss手势
public enum OverlayDismissInteractor {
    case none
    /// 拖动超过极值dismiss，maxOffset(0 - 1)
    case drag(maxOffset: UIOffset, direction: OverlayDismissInteractorDirection)
}

public class OverlayConfig {
    /// 自适应宽高
    public static let autoSize: CGFloat = 0.123456
    
    /// 遮罩视图标识，注意不要重名，会导致错误dismiss
    public var name: String = ""

    // MARK: - Layout

    /// 内容视图宽度
    public var width: CGFloat = OverlayConfig.autoSize
    /// 内容视图高度
    public var height: CGFloat = OverlayConfig.autoSize
    /// 内容视图定位位置
    public var location: OverlayContentLocation = .center
    /// 内容视图外边距
    public var margin: UIEdgeInsets = .zero
    /// 背景视图外边距
    public var backMargin: UIEdgeInsets = .zero

    // MARK: - Other

    /// 内容视图是否可输入文本，如果为true，将监听键盘弹出适应内容视图位置
    public var isEditContainer: Bool = false
    /// dismiss手势
    public var dismissInteractor: OverlayDismissInteractor = .none
    /// 有dismiss手势时，是否在不支持的方向启用弹性动画
    public var isDismissBounces: Bool = true
    /// 如果entryView来源于viewController，需要设置此属性
    public var viewController: UIViewController?

    // MARK: - Back

    /// 背景样式
    public var overlayBackMode: OverlayBackMode = .none
    /// 背景点击行为
    public var overlayBackBehavior: OverlayBackBehavior = .dismiss

    // MARK: - Status Bar

    /// 导航栏样式
    public var statusBarStyle: UIStatusBarStyle = .default
    /// 是否隐藏导航栏
    public var isStatusBarHidden: Bool = false

    // MARK: - Animation

    /// 背景动画
    public var overlayBackAnimation: OverlayAnimation = FadeInAnimation()
    /// 内容动画
    public var contentAnimation: OverlayAnimation = FadeInAnimation()
    
    public init() { }
}
