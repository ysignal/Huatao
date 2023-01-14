//
//  SSOverlayController.swift
//  Charming
//
//  Created by minse on 2022/10/12.
//

import UIKit

public class SSOverlayController {
    static var shared = SSOverlayController()
    private var window: OverlayWindow?
    private var rootViewController: OverlayViewController?
    private var showedEntryQueue: [OverlayView] = []

    public static func show(_ entry: UIView, config: OverlayConfig, completion: (() -> Void)? = nil) {
        shared.show(entry, config: config)
    }

    public static func dismiss(_ entryName: String) {
        shared.dismiss(entryName)
    }

    public static func present(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        shared.present(viewController, animated: animated, completion: completion)
    }

    // MARK: -

    private func present(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        viewController.modalPresentationStyle = .fullScreen
        rootViewController?.present(viewController, animated: animated, completion: completion)
    }

    private func show(_ entry: UIView, config: OverlayConfig) {
        showWindowIfNeed()
        let overlayView = OverlayView(contentView: entry, config: config)
        if let viewController = config.viewController {
            rootViewController?.addChild(viewController)
        }
        rootViewController?.view.addSubview(overlayView)
        setLayoutConstraints(entry: overlayView)
        rootViewController?.view.setNeedsLayout()
        rootViewController?.view.layoutIfNeeded()
        rootViewController?.setNeedsStatusBarAppearanceUpdate()
        overlayView.setNeedsLayout()
        overlayView.layoutIfNeeded()
        switch config.overlayBackMode {
        case .none:
            overlayView.backView.isHidden = true
        case .color, .blur:
            config.overlayBackAnimation.show(targetView: overlayView.backView, context: [:], completion: nil)
        }
        config.contentAnimation.show(targetView: overlayView.contentView, context: [:]) {
            if config.isEditContainer { entry.becomeFirstResponder() }
        }
        showedEntryQueue.append(overlayView)
    }

    private func showWindowIfNeed() {
        if window != nil { return }
        rootViewController = OverlayViewController()
        window = OverlayWindow(frame: UIScreen.main.bounds)
        if #available(iOS 13.0, *) {
            window?.windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        }
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
    }

    fileprivate func dismiss(_ entryName: String) {
        guard let entry = showedEntryQueue.first(where: { $0.config.name == entryName }) else { return }
        dismiss(entry)
    }

    fileprivate func dismiss(_ entry: OverlayView, dismissInteractorDirection: OverlayDismissInteractorDirection? = nil) {
        guard let index = showedEntryQueue.firstIndex(where: { $0 === entry }) else { return }
        let overlayEntry = showedEntryQueue.remove(at: index)
        var backDismissed = false
        var contentDismissed = false
        let dismissCompletion = {
            if backDismissed && contentDismissed {
                overlayEntry.removeFromSuperview()
                overlayEntry.config.viewController?.removeFromParent()
                self.rootViewController?.setNeedsStatusBarAppearanceUpdate()
                self.dismissWindowIfNeed()
            }
        }
        let config = overlayEntry.config
        var content: [OverlayAnimationContextKey: Any] = [:]
        content[.dismissInteractorDirection] = dismissInteractorDirection
        switch config.overlayBackMode {
        case .none:
            backDismissed = true
            dismissCompletion()
        case .color, .blur:
            config.overlayBackAnimation.dismiss(targetView: entry, context: content) {
                backDismissed = true
                dismissCompletion()
            }
        }
        config.contentAnimation.dismiss(targetView: overlayEntry.contentView, context: content) {
            contentDismissed = true
            dismissCompletion()
        }
    }

    func dismissWindowIfNeed() {
        if showedEntryQueue.count != 0 { return }
        window = nil
    }

    // MARK: - Layout

    func setLayoutConstraints(entry: OverlayView) {
        let config = entry.config
        let contentView = entry.contentView
        contentView.translatesAutoresizingMaskIntoConstraints = false
        switch config.location {
        case .top:
            entry.addConstraint(NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: entry, attribute: .top, multiplier: 1, constant: config.margin.top))
            entry.addConstraint(NSLayoutConstraint(item: contentView, attribute: .left, relatedBy: .equal, toItem: entry, attribute: .left, multiplier: 1, constant: config.margin.left))
            let lcRight = NSLayoutConstraint(item: contentView, attribute: .right, relatedBy: .equal, toItem: entry, attribute: .right, multiplier: 1, constant: -config.margin.right)
            lcRight.priority = UILayoutPriority(rawValue: 999)
            entry.addConstraint(lcRight)
        case .center:
            entry.addConstraint(NSLayoutConstraint(item: contentView, attribute: .centerX, relatedBy: .equal, toItem: entry, attribute: .centerX, multiplier: 1, constant: 0))
            entry.addConstraint(NSLayoutConstraint(item: contentView, attribute: .centerY, relatedBy: .equal, toItem: entry, attribute: .centerY, multiplier: 1, constant: 0))
        case .bottom:
            entry.addConstraint(NSLayoutConstraint(item: contentView, attribute: .bottom, relatedBy: .equal, toItem: entry, attribute: .bottom, multiplier: 1, constant: -config.margin.bottom))
            entry.addConstraint(NSLayoutConstraint(item: contentView, attribute: .left, relatedBy: .equal, toItem: entry, attribute: .left, multiplier: 1, constant: config.margin.left))
            let lcRight = NSLayoutConstraint(item: contentView, attribute: .right, relatedBy: .equal, toItem: entry, attribute: .right, multiplier: 1, constant: -config.margin.right)
            lcRight.priority = UILayoutPriority(rawValue: 999)
            entry.addConstraint(lcRight)
        case .right:
            entry.addConstraint(NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: entry, attribute: .top, multiplier: 1, constant: config.margin.top))
            entry.addConstraint(NSLayoutConstraint(item: contentView, attribute: .bottom, relatedBy: .equal, toItem: entry, attribute: .bottom, multiplier: 1, constant: -config.margin.bottom))
            entry.addConstraint(NSLayoutConstraint(item: contentView, attribute: .right, relatedBy: .equal, toItem: entry, attribute: .right, multiplier: 1, constant: -config.margin.right))
        case .left:
            entry.addConstraint(NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: entry, attribute: .top, multiplier: 1, constant: config.margin.top))
            entry.addConstraint(NSLayoutConstraint(item: contentView, attribute: .bottom, relatedBy: .equal, toItem: entry, attribute: .bottom, multiplier: 1, constant: config.margin.bottom))
            entry.addConstraint(NSLayoutConstraint(item: contentView, attribute: .left, relatedBy: .equal, toItem: entry, attribute: .left, multiplier: 1, constant: config.margin.left))
        }

        if config.width != OverlayConfig.autoSize {
            contentView.addConstraint(NSLayoutConstraint(item: contentView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: config.width))
        }
        if config.height != OverlayConfig.autoSize {
            contentView.addConstraint(NSLayoutConstraint(item: contentView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: config.height))
        }
    }
}

public class OverlayViewController: UIViewController {
    
    private var loadedBounds: CGRect = .zero
    
    // MARK: - Keyboard

    @objc func keyboardWillShow(_ noti: Notification) {
        guard let entry = view.subviews.last as? OverlayView,
            entry.config.isEditContainer else { return }
        let contentView = entry.contentView
        let userInfo = noti.userInfo
        guard let keyboardRect = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let maxY = contentView.frame.maxY
        let diff = maxY - (view.bounds.height - keyboardRect.height)
        if diff > 0 {
            UIView.animate(withDuration: 0.25) {
                contentView.transform = contentView.transform.translatedBy(x: 0, y: -diff)
            }
        }
    }

    @objc func keyboardWillHide(_ noti: Notification) {
        guard let entry = view.subviews.last as? OverlayView,
            entry.config.isEditContainer else { return }
        UIView.animate(withDuration: 0.25) {
            entry.contentView.transform = CGAffineTransform.identity
        }
    }

    // MARK: - Override

    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        view.subviews.forEach { $0.frame = view.bounds }
    }
    
    // 禁止旋转防止UI出现错乱
    public override var shouldAutorotate: Bool {
        return false
    }

    public override var preferredStatusBarStyle: UIStatusBarStyle {
        guard let overlayEntry = view.subviews.last as? OverlayView else { return .default }
        return overlayEntry.config.statusBarStyle
    }

    public override var prefersStatusBarHidden: Bool {
        guard let overlayEntry = view.subviews.last as? OverlayView else { return false }
        return overlayEntry.config.isStatusBarHidden
    }

    public override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

class OverlayWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if rootViewController?.presentedViewController != nil {
            return super.hitTest(point, with: event)
        }
        guard let subViews = rootViewController?.view.subviews else { return nil }
        var responseView: UIView?
        for view in subViews.reversed() {
            if view.point(inside: point, with: event) {
                // 如果遮罩层背景是镂空的，穿透事件
                if let view = view as? OverlayView, view.config.overlayBackBehavior == .hollow {
                    let point = view.contentView.convert(point, from: view)
                    if view.contentView.point(inside: point, with: event) {
                        responseView = view.contentView.hitTest(point, with: event)
                    }
                } else {
                    responseView = view.hitTest(point, with: event)
                }
            }
            if responseView != nil { break }
        }
        return responseView
    }
}

class OverlayView: UIView {
    var contentView: UIView
    var backView: UIView
    private var gestureBackView: UIView
    var config: OverlayConfig
    private var beginMovePoint: CGPoint?
    private var dragProgress: CGFloat = 0
    private var rawTransform: CGAffineTransform?
    /// 是否垂直方向
    private var isVerticalDragging: Bool?
    /// dismiss手势方向
    private var dismissInteractorDirection: OverlayDismissInteractorDirection?

    // MARK: - Events

    @objc func onBackTapped() {
        if config.overlayBackBehavior == .dismiss {
            SSOverlayController.shared.dismiss(self)
        }
    }

    @objc func panGestureHandle(_ gesture: UISwipeGestureRecognizer) {
        if case let .drag(maxOffset, direction) = config.dismissInteractor {
            switch gesture.state {
            case .began:
                beginMovePoint = gesture.location(in: self)
                rawTransform = contentView.transform
            case .changed:
                if let beginMovePoint = beginMovePoint {
                    let point = gesture.location(in: self)
                    let offsetX = point.x - beginMovePoint.x
                    let offsetY = point.y - beginMovePoint.y
                    // 未确定方向，滑动距离过小容易判断错误方向
                    if isVerticalDragging == nil && abs(offsetX) < 10 && abs(offsetY) < 10 { return }
                    // 首次拖动确定方向，后续改变只允许移动一个方向
                    if isVerticalDragging == nil { isVerticalDragging = abs(offsetX) < abs(offsetY) }
                    let isVertical = isVerticalDragging ?? false
                    var offset = isVertical ? offsetY : offsetX
                    if isVertical {
                        if (offset < 0 && !direction.contains(.up)) || (offset > 0 && !direction.contains(.down)) {
                            if !config.isDismissBounces { return }
                            offset = offset / 10
                        }
                        contentView.transform = rawTransform!.translatedBy(x: 0, y: offset)
                    } else {
                        if (offset < 0 && !direction.contains(.left)) || (offset > 0 && !direction.contains(.right)) {
                            if !config.isDismissBounces { return }
                            offset = offset / 10
                        }
                        contentView.transform = rawTransform!.translatedBy(x: offset, y: 0)
                    }
                    dragProgress = abs(offset) / (isVertical ? contentView.bounds.height : contentView.bounds.width)
                    config.contentAnimation.interaction(targetView: contentView, context: [:], progress: dragProgress)
                    config.overlayBackAnimation.interaction(targetView: backView, context: [:], progress: dragProgress)
                    if isVertical {
                        dismissInteractorDirection = offset < 0 ? .up : .down
                    } else {
                        dismissInteractorDirection = offset < 0 ? .left : .right
                    }
                }
            default:
                var shouldDismiss = ((direction.contains(.up) || direction.contains(.down)) && dragProgress >= maxOffset.vertical) ||
                    ((direction.contains(.left) || direction.contains(.right)) && dragProgress >= maxOffset.horizontal)
                if let dismissDirection = dismissInteractorDirection, !direction.contains(dismissDirection) { shouldDismiss = false }
                if shouldDismiss {
                    SSOverlayController.shared.dismiss(self, dismissInteractorDirection: dismissInteractorDirection)
                } else {
                    UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                        self.contentView.transform = self.rawTransform ?? CGAffineTransform.identity
                        self.config.contentAnimation.interaction(targetView: self.contentView, context: [:], progress: 0)
                        self.config.overlayBackAnimation.interaction(targetView: self.backView, context: [:], progress: 0)
                    }, completion: nil)
                }
                dragProgress = 0
                isVerticalDragging = nil
                dismissInteractorDirection = nil
            }
        }
    }

    // MARK: - Override

    override func layoutSubviews() {
        super.layoutSubviews()
        gestureBackView.frame = bounds
        backView.frame = bounds.inset(by: config.backMargin)
    }

    // MARK: - Init

    init(contentView: UIView, config: OverlayConfig) {
        self.contentView = contentView
        self.config = config
        backView = UIView()
        gestureBackView = UIView()

        switch config.overlayBackMode {
        case .none:
            backView.isHidden = true
        case let .color(color):
            backView.backgroundColor = color
        case let .blur(style):
            let blurEffect = UIBlurEffect(style: style)
            let visualView = UIVisualEffectView(effect: blurEffect)
            backView = visualView
        }

        super.init(frame: .zero)
        addSubview(gestureBackView)
        addSubview(backView)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onBackTapped))
        backView.addGestureRecognizer(tapGesture)
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(onBackTapped))
        gestureBackView.addGestureRecognizer(tapGesture1)

        if case .drag = config.dismissInteractor {
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandle(_:)))
            backView.addGestureRecognizer(panGesture)

            let panGesture1 = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandle(_:)))
            contentView.addGestureRecognizer(panGesture1)

            let panGesture2 = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandle(_:)))
            gestureBackView.addGestureRecognizer(panGesture2)
        }
        addSubview(contentView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
