//
//  SSDate.swift
//  Huatao
//
//  Created on 2023/2/11.
//  
	

import Foundation

extension Date {
    
    /// 紧凑型日期文字，缓存文件和图片命名时用
    var compactString: String {
        return self.toString(.custom("yyyyMMddhhmmssSSS"))
    }
    
    var activityString: String {
        return "\(month)月\(day)日\(hour)时"
    }
    
    /// 聊天列表中的发送时间
    var timeString: String {
        let current = Date()
        let timeOffset = current.timeIntervalSince(self)
        if timeOffset < 60 {
            return "刚刚"
        } else if timeOffset < 60*60 {
            return "\(Int(timeOffset)/60)分钟前"
        } else if Int(timeOffset) < 60*60*24 {
            return "\(Int(timeOffset)/3600)小时前"
        } else {
            if current.year > year {
                return "\(current.year-year)年前"
            } else if current.month > month {
                return "\(current.month-month)个月前"
            } else {
                let dayOffset = current.day - day
                switch dayOffset {
                case 0:
                    return "今天"
                case 1:
                    return "昨天"
                case 2:
                    return "前天"
                default:
                    return "\(dayOffset)天前"
                }
            }
        }
    }
}
