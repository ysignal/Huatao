//
//  PayManager.swift
//  Charming
//
//  Created by minse on 2023/1/7.
//

import Foundation

struct PayManager {
    
    static func register(with window: UIWindow?) {
        AlipaySDK.defaultService().targetWindow = window
    }
    
    static func checkIsCanPay(_ payWay: String) -> Bool {
        switch payWay {
        case "alipay":
            if !APP.isAlipayAppInstalled() {
                SS.keyWindow?.globalToast(message: "没有安装支付宝客户端，请选择其他方式支付!")
                return false
            }
        case "wechat":
            if !WXApi.isWXAppInstalled() {
                SS.keyWindow?.globalToast(message: "没有安装微信客户端，请选择其他方式支付!")
                return false
            }
        default:
            break
        }
        return true
    }
    
    static func alipayPay(_ order: String, completion: NoneBlock? = nil) {
        AlipaySDK.defaultService().payOrder(order, fromScheme: APP.SDKKey.AlipayScheme) { resultDic in
            if let dict = resultDic {
                SS.log(dict)
            }
            if let resultStatus = resultDic?["resultStatus"] as? String {
                switch resultStatus {
                case "9000":
                    SSMainAsync {
                        completion?()
                    }
                case "8000":
                    SS.log("正在处理中")
                case "4000":
                    SS.keyWindow?.globalToast(message: "订单支付失败,请重试")
                case "6001":
                    SS.log("用户中途取消")
                case "6002":
                    SS.keyWindow?.globalToast(message: "网络连接出错")
                default: break
                }
            }
        }
    }
    
}
