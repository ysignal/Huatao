//
//  SSDateHelper.swift
//  Huatao
//
//  Created on 2023/2/20.
//  
	

import Foundation

struct SSDateHelper {
    
    private static var D_MINUTE: Double = 60
    private static var D_HOUR: Double   = 3600
    private static var D_DAY: Double    = 86400
    private static var D_WEEK: Double   = 604800
    private static var D_YEAR: Double   = 31556926
    
    private static func dateFormat(with format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter
    }
    
    static var dfYMD: DateFormatter = {
        return dateFormat(with: "yyyy/MM/dd")
    }()
    
    static var dfHM: DateFormatter = {
        return dateFormat(with: "HH:mm")
    }()
    
    static var dfYMDHM: DateFormatter = {
        return dateFormat(with: "yyyy/MM/dd HH:mm")
    }()
    
    static var dfYesterdayHM: DateFormatter = {
        return dateFormat(with: "yyyy/MM/dd")
    }()
    
    static var dfBeforeDawnHM: DateFormatter = {
        return dateFormat(with: "凌晨hh:mm")
    }()
    
    static var dfAAHM: DateFormatter = {
        return dateFormat(with: "上午hh:mm")
    }()
    
    static var dfPPHM: DateFormatter = {
        return dateFormat(with: "下午hh:mm")
    }()
    
    static var dfNightHM: DateFormatter = {
        return dateFormat(with: "晚上hh:mm")
    }()

    //MARK: - Public Methods
    static func dateWithTimeIntervalInMilliSecondSince1970(_ milliSecond: Double) -> Date {
        var timeInterval = milliSecond
        if milliSecond > 140000000000 {
            timeInterval = milliSecond/1000
        }
        return Date(timeIntervalSince1970: timeInterval)
    }

    static func formattedTime(from timeInterval: Int64) -> String {
        let date = dateWithTimeIntervalInMilliSecondSince1970(Double(timeInterval))
        return formattedTime(date: date, formatter: dfYMD)
    }

    static func formattedTime(date: Date, formatter: DateFormatter) -> String {
        let dateNow = Date()
        var components = DateComponents()
        components.day = dateNow.day
        components.month = dateNow.month
        components.year = dateNow.year
        let gregorian = NSCalendar(calendarIdentifier: .gregorian)
        let toDate = gregorian?.date(from: components) ?? dateNow
        let hour = hours(from: date, to: toDate)
        let formatStringForHours = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: .current) ?? ""
        if formatStringForHours.contains("a") {
            //If hasAMPM==TURE, use 12-hour clock, otherwise use 24-hour clock
            if (hour >= 0 && hour <= 6) {
                return dfBeforeDawnHM.string(from: date)
            } else if (hour > 6 && hour <= 11 ) {
                return dfAAHM.string(from: date)
            } else if (hour > 11 && hour <= 17) {
                return dfPPHM.string(from: date)
            } else if (hour > 17 && hour <= 24) {
                return dfNightHM.string(from: date)
            } else if (hour < 0 && hour >= -24) {
                return dfYesterdayHM.string(from: date)
            } else {
                return dfYMDHM.string(from: date)
            }
        } else {
            // 24-hour clock
            if (hour <= 24 && hour >= 0) {
                return dfHM.string(from: date)
            } else if (hour < 0 && hour >= -24) {
                return dfYesterdayHM.string(from: date)
            } else {
                return dfYMDHM.string(from: date)
            }
        }
    }


    //MARK: - Retrieving Intervals
    static func hours(from date: Date, to toDate: Date) -> Double {
        let ti = date.timeIntervalSince(toDate)
        var fi = ti / D_HOUR
        if ti < 0 {
            fi -= 1
        }
        return fi
    }
    
}
