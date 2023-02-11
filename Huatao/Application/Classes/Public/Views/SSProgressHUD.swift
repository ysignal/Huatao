//
//  SSProgressHUD.swift
//  Huatao
//
//  Created on 2023/1/13.
//

import MBProgressHUD
import UIKit

private var hudTimer: Timer!

extension UIView {
    public static var dw_configHUDBlock: ((_ hud: MBProgressHUD) -> Void)?
    
    private struct AssociatedKeys {
        static var loadingHUD = "loadingHUD"
        static var loadingHUDCounter = "loadingHUDCounter"
    }

    fileprivate var loadingHUD: MBProgressHUD? {
        set { objc_setAssociatedObject(self, &AssociatedKeys.loadingHUD, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
        get { return objc_getAssociatedObject(self, &AssociatedKeys.loadingHUD) as? MBProgressHUD }
    }

    fileprivate var loadingHUDCounter: Int {
        set { objc_setAssociatedObject(self, &AssociatedKeys.loadingHUDCounter, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
        get { return (objc_getAssociatedObject(self, &AssociatedKeys.loadingHUDCounter) as? Int) ?? 0 }
    }
}

public extension SSFramework where Base: UIView {
    /// 显示loadingHUD
    /// - Parameter text: 提示文本
    func showHUDLoading(text: String? = nil) {
        var hud = base.loadingHUD
        if hud == nil {
            hud = MBProgressHUD.showAdded(to: base, animated: true)
            base.loadingHUD = hud
            base.loadingHUDCounter += 1
        } else if hud!.mode == .indeterminate {
            base.loadingHUDCounter += 1
        }
        hud?.mode = .indeterminate
        hud?.detailsLabel.text = text
        UIView.dw_configHUDBlock?(hud!)
    }

    /// 显示进度HUD
    /// - Parameters:
    ///   - progress: 进度
    ///   - text: 提示文本
    func showHUDProgress(_ progress: Float, title: String? = nil, text: String? = nil) {
        var hud = base.loadingHUD
        if hud == nil {
            hud = MBProgressHUD.showAdded(to: base, animated: true)
            base.loadingHUD = hud
            base.loadingHUDCounter += 1
        }
        hud?.mode = .annularDeterminate
        hud?.detailsLabel.text = text
        hud?.label.text = title
        hud?.progress = progress
        UIView.dw_configHUDBlock?(hud!)
    }
    
    var isShowHUDBar: Bool {
        return base.loadingHUD != nil && base.loadingHUD?.superview != nil
    }
    
    /// 显示进度BarHUD
    func showHUDBarProgress(text: String? = nil) {
        var hud: MBProgressHUD
        if let baseHud = base.loadingHUD {
            hud = baseHud
        } else {
            hud = MBProgressHUD.showAdded(to: base, animated: true)
            base.loadingHUD = hud
            base.loadingHUDCounter += 1
            hud.button.setTitle("cancel".localized(), for: UIControl.State.normal)
            hud.button.addTarget(self.base, action: #selector(self.base.HUDCancelAction), for: UIControl.Event.touchUpInside)
        }
        hud.mode = .determinateHorizontalBar
        UIView.dw_configHUDBlock?(hud)
    }
    
    func updateAnnularDeterminateProgress(progress: Float, title: String?, text: String? = nil, complete: (()->Void)? = nil) {
        guard let hud = base.loadingHUD else { return }
        hud.mode = .annularDeterminate
        // 修改标题
        timerProgress(time: 0.5, progress: progress, title: title, complete: complete)
        UIView.dw_configHUDBlock?(hud)
    }
    
    private func clearTimer() {
        hudTimer?.fireDate = Date.distantPast
        hudTimer?.invalidate()
        hudTimer = nil
    }
    
    private func timerProgress(time: Float, progress: Float, title: String?, text: String? = nil, timeInterval: TimeInterval = 0.01, complete: (()->Void)? = nil) {
        guard let hud = base.loadingHUD else { return }
        if title != nil && title?.isEmpty == false {
            hud.label.text = title
        }
        if title != nil && title?.isEmpty == false {
            hud.label.text = title
        }
        clearTimer()
        if hud.progress < progress {
            let progressStep: Float = (progress - hud.progress)/time * Float(timeInterval)
            hudTimer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true, block: { (t) in
                if hud.progress >= progress {
                    t.fireDate = Date.distantPast
                    t.invalidate()
                    complete?()
                } else {
                    DispatchQueue.main.async {
                        hud.progress += progressStep
                    }
                }
            })
        } else {
            complete?()
        }
    }

    /// 显示纯文本HUD
    /// - Parameters:
    ///   - text: 提示文本
    ///   - second: 显示时长，默认2s隐藏
    func showHUDText(_ text: String, second: Int = 2) {
        let hud = MBProgressHUD.showAdded(to: base, animated: true)
        hud.isUserInteractionEnabled = false
        hud.mode = .text
        hud.detailsLabel.text = text
        hud.hide(animated: true, afterDelay: TimeInterval(second))
        UIView.dw_configHUDBlock?(hud)
    }
    
    /// 显示进度 带取消
    func showHUDLoadingWithCancel() {
        var hud = base.loadingHUD
        if hud == nil {
            hud = MBProgressHUD.showAdded(to: base, animated: true)
            base.loadingHUD = hud
            base.loadingHUDCounter += 1
            hud?.button.setTitle("cancel".localized(), for: UIControl.State.normal)
            hud?.button.addTarget(self.base, action: #selector(self.base.HUDLoadingCancelAction), for: UIControl.Event.touchUpInside)
        }
        hud?.mode = .indeterminate
        hud?.detailsLabel.text = "    "
        UIView.dw_configHUDBlock?(hud!)
    }

    /// 隐藏HUD
    func hideHUD() {
        base.loadingHUDCounter -= 1
        if base.loadingHUDCounter <= 0 {
            base.loadingHUDCounter = 0
            base.loadingHUD?.hide(animated: true)
            base.loadingHUD = nil
        }
    }
    
    func hideAllHUD() {
        base.loadingHUDCounter = 0
        base.loadingHUD?.hide(animated: true)
        base.loadingHUD = nil
    }
    
}

extension UIView {
     @objc func HUDCancelAction() {

     }
    
    @objc func HUDLoadingCancelAction() {

    }
}


