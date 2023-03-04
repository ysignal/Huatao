//
//  TimerManager.swift
//  Huatao
//
//  Created on 2023/3/3.
//  
	

import Foundation

struct TimerManager {
    /// 手机号码倒计时计数
    static var phoneCount: Int = 0
    
    private static var codeTimer: Timer?
    private static var codeHandler: ((Int, Bool) -> Void)?
    
    static func countDown(handler: ((Int, Bool) -> Void)?) {
        codeHandler = handler
        if isCountDown() {
            return
        }
        // 注销事件
        codeTimer?.invalidate()
        // 释放Timer
        codeTimer = nil
        // 开启事件
        codeTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
            SSMainAsync {
                if phoneCount <= 1 {
                    t.invalidate()
                    codeTimer = nil
                    codeHandler?(0, true)
                    return
                }
                phoneCount -= 1
                codeHandler?(phoneCount, false)
            }
        }
        RunLoop.current.add(codeTimer!, forMode: .common)
    }
    
    /// 判断验证码是否正在计时
    /// - Returns: Bool
    static func isCountDown() -> Bool {
        return phoneCount > 0 && codeTimer != nil
    }
    
    static var newCount: Int = 0
    
    private static var newTimer: Timer?
    private static var newHandler: ((Int, Bool) -> Void)?
    
    static func newCountDown(handler: ((Int, Bool) -> Void)?) {
        newHandler = handler
        if isNewCountDown() {
            return
        }
        // 注销事件
        newTimer?.invalidate()
        // 释放Timer
        newTimer = nil
        // 开启事件
        newTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
            SSMainAsync {
                if newCount <= 1 {
                    t.invalidate()
                    newTimer = nil
                    newHandler?(0, true)
                    return
                }
                newCount -= 1
                newHandler?(newCount, false)
            }
        }
        RunLoop.current.add(newTimer!, forMode: .common)
    }
    
    /// 判断验证码是否正在计时
    /// - Returns: Bool
    static func isNewCountDown() -> Bool {
        return newCount > 0 && newTimer != nil
    }
}
