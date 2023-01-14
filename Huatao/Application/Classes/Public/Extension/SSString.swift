//
//  SSString.swift
//  Huatao
//
//  Created by minse on 2023/1/13.
//

import Foundation

struct SSString {
    
    
    //MARK: 页面标题
    
    let authCenter = "认证中心"
    let realAuth = "真人认证"
    let nameAuth = "实名认证"

    
    //MARK: 弹窗标题
    let select_city = "选择城市"
    let select_height = "身高"
    let select_weight = "体重"
    let select_age = "年龄"
    
    let reset = "重置"
    let confirm = "确认"
    let save = "保存"
    
    
    
    let phoneInputTip = "请输入完整的手机号"
    let codeInputTip = "请输入验证码"
}


extension String {
    
    static var ss: SSString {
        return SSString()
    }
    
    var intValue: Int {
        return Int(self) ?? 0
    }
    
    var floatValue: CGFloat {
        return Double(self) ?? 0.0
    }
    
    func fixedZero() -> String {
        if self.contains(".") {
            var strlist = self.components(separatedBy: ".")
            if strlist.count > 1, var last = strlist.last {
                while last.last == "0" {
                    last = String(last.prefix(last.count - 1))
                }
                if last.count > 0 {
                    strlist[strlist.count - 1] = last
                    return strlist.joined(separator: ".")
                } else if let first = strlist.first {
                    return first
                }
            }
        }
        return self
    }
    
    func width(from font: UIFont, height: CGFloat) -> CGFloat {
        return (self as NSString).boundingRect(with: CGSize(width: .greatestFiniteMagnitude, height: height), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : font], context: nil).size.width
    }
    
    func height(from font: UIFont, width: CGFloat) -> CGFloat {
        return (self as NSString).boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : font], context: nil).size.height
    }
    
    func size(from font: UIFont, size: CGSize) -> CGSize {
        return (self as NSString).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : font], context: nil).size

    }
    
    func upper(than old: String?) -> Bool {
        guard let old = old else {
            return false
        }

        let newList = self.split(separator: ".")
        let oldList = old.split(separator: ".")
        for (i, num) in newList.enumerated() {
            if i >= oldList.count {
                return true
            } else {
                if String(num).intValue > String(oldList[i]).intValue {
                    return true
                } else if String(num).intValue < String(oldList[i]).intValue {
                    return false
                }
            }
        }
        return false
    }
    
    func lower(than old: String?, contains: Bool = false) -> Bool {
        guard let old = old else {
            return false
        }
        if self.replacingOccurrences(of: " ", with: "") == old.replacingOccurrences(of: " ", with: ""), contains {
            return true
        }
        let newList = self.split(separator: ".")
        let oldList = old.split(separator: ".")
        for (i, num) in newList.enumerated() {
            if i >= oldList.count {
                return false
            } else if String(num).intValue < String(oldList[i]).intValue {
                return true
            }
        }
        return false
    }
    
    //获取拼音首字母（大写字母）
    func firstLetter() -> String {
        //转变成可变字符串
        let mutableString = NSMutableString.init(string: self)
        //将中文转换成带声调的拼音
        CFStringTransform(mutableString as CFMutableString, nil, kCFStringTransformToLatin, false)
        //去掉声调
        let pinyinString = mutableString.folding(options:          String.CompareOptions.diacriticInsensitive, locale:   NSLocale.current)
        //将拼音首字母换成大写
        let strPinYin = pinyinString.uppercased()
        //截取大写首字母
        guard let firstString = strPinYin.first else { return "#" }
        //判断首字母是否为大写
        let regexA = "^[A-Z]$"
        let predA = NSPredicate.init(format: "SELF MATCHES %@", regexA)
        let newFirstStr = String(firstString)
        return predA.evaluate(with: newFirstStr) ? newFirstStr : "#"
    }
    
    /// 日期文本字符串转换为距离当前时间的发布时间文字
    func toPublishText() -> String {
        if let date = Date(self) {
            let current = Date()
            let timeOffset = current.timeIntervalSince(date)
            if timeOffset < 60 {
                return "刚刚"
            } else if timeOffset < 3600 {
                return "\(Int(timeOffset)/60)分钟前"
            } else if Int(timeOffset) < 86400 {
                return "\(Int(timeOffset)/3600)小时前"
            } else {
                return "\(Int(timeOffset)/86400)天前"
            }
        } else {
            return self
        }
    }
    
    func toDateText() -> String {
        if let date = Date(self) {
            return date.toString(.custom("yyyy-MM-dd"))
        } else {
            return self
        }
    }

    
    // 手机号码匹配
    func isPhoneStr() -> Bool {
        let pattern = "^1[0-9]{10}$"
        if NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: self) {
            return true
        }
        return false
    }
    
    // 邮箱匹配
    func isEmailStr() -> Bool {
        let pattern = "\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*"
        if NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: self) {
            return true
        }
        return false
    }
    
    var isNotEmpty: Bool {
        return !isEmpty
    }
    
}
