//
//  SSToast.swift
//  SimpleSwift
//
//  Created by user on 2021/4/20.
//

import UIKit

public struct SSToastConfigure {
    static let shared = SSToastConfigure()
    
    public var backgroundColor: UIColor = .black
    public var textColor: UIColor = .white
    
    public var style: ToastStyle {
        var style = ToastStyle()
        style.backgroundColor = SSToastConfigure.shared.backgroundColor
        style.titleColor = SSToastConfigure.shared.textColor
        style.messageColor = SSToastConfigure.shared.textColor
        style.titleFont = .ss_semibold(size: 18)
        style.messageFont = .ss_semibold(size: 16)
        style.titleAlignment = .center
        style.messageAlignment = .center
        return style
    }
}

public extension UIView {
    func toast(message: String, duration: TimeInterval = 1) {
        makeToast(message,
                  duration: duration,
                  point: center,
                  title: nil,
                  image: nil,
                  style: SSToastConfigure.shared.style,
                  completion: nil)
    }
    
    func globalToast(message: String) {
        if let view = SS.keyWindow {
            view.toast(message: message)
        }
    }
}

public extension UIViewController {
    func toast(message: String, duration: TimeInterval = 1) {
        view.toast(message: message, duration: duration)
    }
    
    func globalToast(message: String) {
        if let view = SS.keyWindow {
            view.toast(message: message)
        }
    }
}
