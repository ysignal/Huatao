//
//  CityDataBaseManager.swift
//  Huatao
//
//  Created by minse on 2023/1/16.
//

import Foundation
import FMDB

struct CityDataBaseManager {

    static let shared = CityDataBaseManager()
    
    var db = FMDatabase()

    init() {
        let dbPath = Bundle.main.path(forResource:"cities", ofType: "db")
        db = FMDatabase(path: dbPath)
        if db.open() {
//            SS.log("[Cache] 数据库打开成功")
        }
    }

    /// 获取全国各省份
    ///
    /// - Returns: []
    func getProvinceList() -> [AllCityInfo] {
        return getDataList("SELECT * FROM bh_areas where LevelType = ?", arguments: [1])
    }
    
    /// 获取全国全部城市列表
    ///
    /// - Returns: 全国城市列表
    func getAllCityDic() -> [String: [AllCityInfo]] {
        let cityList = getDataList("SELECT * FROM bh_areas where LevelType = ?", arguments: [2])
        var cityDic: [String: [AllCityInfo]] = [:]
        for city in cityList {
            var list = cityDic[city.FirstChar] ?? []
            list.append(city)
            cityDic.updateValue(list, forKey: city.FirstChar)
        }
        for value in cityDic.values {
            var cityList = value
            cityList.sort(by: { (city1, city2) -> Bool in
                return city1.Pinyin>city2.Pinyin
            })
        }
        return cityDic
    }
    
    func getAllCityList() -> [String] {
        let cityList = getDataList("SELECT * FROM bh_areas where LevelType = ?", arguments: [2])
        return cityList.compactMap({ $0.Name })
    }
    
    /// 获取省份下的城市列表
    ///
    /// - Parameter code: 行政编码
    /// - Returns: 城市列表
    func getCityList(by parentId: String) -> [AllCityInfo] {
        return getDataList("SELECT * FROM bh_areas where ParentId = ?", arguments: [parentId])
    }
    
    /// 根据传入的sql语句和参数从db文件中读取数据
    ///
    /// - Parameters:
    ///   - selectSql: sql语句
    ///   - arguments: 参数
    /// - Returns: 返回的数据
    func getDataList (_ selectSql: String, arguments: [Any]) -> [AllCityInfo] {
        var cityList: [AllCityInfo] = []
        
        if let rs = db.executeQuery(selectSql, withArgumentsIn: arguments) {
            while rs.next() {
                var model = AllCityInfo()
                //结果为空值时 返回?? 后面的默认值
                model.ID = rs.string(forColumn: "ID") ?? ""
                model.ParentId = rs.string(forColumn: "ParentId") ?? ""
                model.Name = rs.string(forColumn: "Name") ?? ""
                model.MergerName = rs.string(forColumn: "MergerName") ?? ""
                model.ShortName = rs.string(forColumn: "ShortName") ?? ""
                model.MergerShortName = rs.string(forColumn: "MergerShortName") ?? ""
                model.LevelType = rs.int(forColumn: "LevelType")
                model.CityCode = rs.string(forColumn: "CityCode") ?? ""
                model.ZipCode = rs.string(forColumn: "ZipCode") ?? ""
                model.Pinyin = rs.string(forColumn: "Pinyin") ?? ""
                model.Jianpin = rs.string(forColumn: "Jianpin") ?? ""
                model.FirstChar = rs.string(forColumn: "FirstChar") ?? ""
                model.Lng = rs.double(forColumn: "Lng")
                model.Lat = rs.double(forColumn: "Lat")
                model.Remark = rs.string(forColumn: "Remark") ?? ""
                cityList.append(model)
            }
            rs.close()
        }
        return cityList
    }
    
    func city(byId id: String) -> AllCityInfo? {
        let resultList = getDataList("SELECT * FROM bh_areas where ID = ?", arguments: [id])
        return resultList.first
    }
    
    func city(byShortName name: String) -> AllCityInfo? {
        let resultList = getDataList("SELECT * FROM bh_areas where ShortName = ?", arguments: [name])
        return resultList.first
    }
    
    func city(byName name: String) -> AllCityInfo? {
        let resultList = getDataList("SELECT * FROM bh_areas where Name = ?", arguments: [name])
        return resultList.first
    }
    
    func parentID(by id: String) -> String {
        var parentID: String = ""
        let resultList = getDataList("SELECT * FROM bh_areas where ID = ?", arguments: [id])
        if resultList.count>0 {
            if let city = resultList.first {
                parentID = city.ParentId
            }
        }
        return parentID
    }
    
    func mergerShortName(by id: String) -> String {
        var name: String = ""
        let resultList = getDataList("SELECT * FROM bh_areas where ID = ?", arguments: [id])
        if resultList.count>0 {
            if let city = resultList.first {
                var nameArr = city.MergerShortName.components(separatedBy: ",")
                _ = nameArr.removeFirst()
                var newArr: [String] = []
                for name in nameArr {
                    if !newArr.contains(name) {
                        newArr.append(name)
                    }
                }
                while newArr.count>2 {
                    _ = newArr.removeLast()
                }
                
                name = newArr.joined()
            }
        }
        return name
    }
    
    func shortName(by id: String) -> String  {
        var name: String = ""
        let resultList = getDataList("SELECT * FROM bh_areas where ID = ?", arguments: [id])
        if let city = resultList.first {
            name = city.ShortName
        }
        return name
    }
    
    //MARK: - 数据库管理者的获取以及表的判定
    func errorMsg(_ msg: String) {
        SS.log("BEDataBaseManager Error: \(msg)")
    }
}
