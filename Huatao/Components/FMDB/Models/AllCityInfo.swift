//
//  AllCityInfo.swift
//  Huatao
//
//  Created by minse on 2023/1/16.
//

import Foundation

struct AllCityInfo {
    
    /// 行政编码
    var ID: String = ""
    
    /// 区域ID
    var ParentId: String = ""
    
    /// 城市/区域名称
    var Name: String = ""
    
    /// 全名称
    var MergerName: String = ""
    
    /// 简称
    var ShortName: String = ""
    
    /// 全名称简称
    var MergerShortName: String = ""
    
    /// 层级   0为国家  1为省  2为市   3为区县
    var LevelType: Int32 = 0
    
    /// 区号
    var CityCode: String = ""
    
    /// 邮政编码
    var ZipCode: String = ""
    
    /// 拼音
    var Pinyin: String = ""
    
    /// 拼音简拼
    var Jianpin: String = ""
    
    /// 拼音首字母
    var FirstChar: String = ""
    
    /// 经度
    var Lng: Double = 0
    
    /// 纬度
    var Lat: Double = 0
    
    /// 备注
    var Remark: String = ""
}
