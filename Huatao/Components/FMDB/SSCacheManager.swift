//
//  SSCacheManager.swift
//  Huatao
//
//  Created by minse on 2023/1/16.
//

import FMDB

class SSCacheManager {
    
    static let shared = SSCacheManager()
    
    /// 数据库管理对象
    private var queue: FMDatabaseQueue!
    
    /// 注册的表格数组
    private var tables: [CacheModel] = []
    
    /// 当前缓存用户
    private var currentId: Int = 0
    
    /// 缓存地址
    private var cachePath: String {
        return SSSandbox.shared.documentDirectory + "/RCIMDB"
    }
    
    init() {
        let dbPath = cachePath

        queue = FMDatabaseQueue(path: dbPath)
        
        createTable()
    }
    
    /// 获取当前数据库管理对象
    /// - Returns: 根据当前登录用户返回不同数据库的管理对象
    private func checkDB() {
        // 未初始化，需要初始化数据库管理对象
        // 切换用户的情况下，需要切换数据库管理对象
        if queue == nil || currentId != APP.userInfo.userId {
            currentId = APP.userInfo.userId
            if currentId == 0 {
                // 默认ID，判断为用户未登录成功
                let dbPath = cachePath
                queue = FMDatabaseQueue(path: dbPath)
                createTable()
                return
            }
            // 用户ID和环信IM的ID都是唯一标识，用用户ID创建数据库
            let dbPath = cachePath + "\(currentId)"
            queue = FMDatabaseQueue(path: dbPath)
            SS.log("DBPath: ----------\(dbPath)")
            createTable()
        }
    }
    
    private func createTable() {
        queue.inDatabase { db in
            if db.open() {
                tables.forEach { model in
                    let propertys = model.jsonObject()
                    var sql = "create table if not exists '\(model.dbTable().rawValue)' ('id' integer not null primary key autoincrement"
                    for item in propertys {
                        sql += ",'\(item.key)' text"
                    }
                    sql += ")"
                    if db.executeUpdate(sql, withArgumentsIn: []) {
                        SS.log("[Cache] 表格'\(model.dbTable().rawValue)'创建成功!")
                    }
                }
                db.close()
            }
        }
    }
    
    func model(from table: SSTable, key: String, complete: @escaping (CacheModel?) -> Void) {
        guard let model = tables.first(where: { $0.dbTable() == table }) else {
            SS.log("[Cache] 读取表格'\(table)'数据失败")
            return
        }
        let sql = "select * from \(table.rawValue) where \(table.key) = '\(key)'"
        SS.log("[Cache] 从表格 '\(table.rawValue)' 中来获取 \(table.key) = '\(key)' 的数据")
        checkDB()
        var item: CacheModel?
        queue.inDatabase { db in
            if db.open() {
                if let result = db.executeQuery(sql, withArgumentsIn: []) {
                    while result.next() {
                        item = model.seriation(model.parse(result))
                        break
                    }
                    result.close()
                }
                db.close()
            } else {
                SS.log("[Cache] 打开数据库失败")
            }
        }
        if item == nil {
            SS.log("[Cache] 获取数据失败")
        } else {
            SS.log("[Cache] 获取数据成功")

        }
        complete(item)
    }
    
    func list(from table: SSTable, complete: @escaping ([CacheModel]) -> Void) {
        guard let model = tables.first(where: { $0.dbTable() == table }) else {
            SS.log("[Cache] 读取表格'\(table)'数据失败")
            return
        }
        let sql = "select * from \(table.rawValue)"
        SS.log("[Cache] 从表格 '\(table.rawValue)' 中获取所有数据")
        checkDB()
        var newList = [CacheModel]()
        queue.inDatabase { db in
            if db.open() {
                if let result = db.executeQuery(sql, withArgumentsIn: []) {
                    while result.next() {
                        newList.append(model.seriation(model.parse(result)))
                    }
                    result.close()
                }
                db.close()
            } else {
                SS.log("[Cache] 打开数据库失败")
            }
        }
        
        SS.log("[Cache] 获取表格 '\(table.rawValue)' 数据个数为\(newList.count)")
        complete(newList)
    }
    
    /// 更新数据库记录，如果数据库中没有该条记录就插入新记录，有则更新该条记录
    /// - Parameters:
    ///   - table: 数据表
    ///   - key: 数据模型的唯一标识
    ///   - json: json数据
    func update(_ table: SSTable, key: String, json: [String: Any]) {
        // 判断数据表中是否有该条数据记录
        model(from: table, key: key) { [weak self] data in
            if var model = data {
                // 更新模型数据
                model.loadJson(json)
                // 将模型更新到数据库
                self?.updateModel(model)
            } else {
                // 没有数据记录的情况下，获取相同表格的模型模板
                if let model = self?.tables.first(where: { $0.dbTable() == table }) {
                    var newJson = json
                    // 将标识该条记录的唯一标识key写入json数据
                    newJson[table.key] = key
                    // 生成新的模型
                    let newModel = model.seriation(newJson)
                    // 将新模型插入数据库
                    self?.insertModel(newModel)
                }
            }
        }
    }
    
    private func insertModel(_ model: CacheModel) {
        var keyString = ""
        var valueString = ""
        let propertys = model.jsonObject()
        for (i, item) in propertys.enumerated() {
            keyString += "\(i == 0 ? "" : ", ")\(item.key)"
            valueString += "\(i == 0 ? "" : ", ")'\(String(describing: item.value))'"
        }
        
        let sql = "insert into \(model.dbTable().rawValue) (\(keyString)) values (\(valueString))"
        SS.log("[Cache] FMDB execute sql: \(sql)")
        checkDB()
        queue.inDatabase { db in
            if db.open() {
                if db.executeUpdate(sql, withArgumentsIn: []) {
                    SS.log("[Cache] 表格'\(model.dbTable().rawValue)'数据新增成功")
                }
                db.close()
            }
        }
    }
    
    private func updateModel(_ model: CacheModel) {
        var updateString = ""
        let propertys = model.jsonObject()
        for (i, item) in propertys.enumerated() {
            updateString += "\(i == 0 ? "" : ", ")\(item.key) = '\(item.value)'"
        }
        let sql = "update \(model.dbTable().rawValue) set \(updateString) where \(model.dbTable().key) = '\(model.keyValue())'"
        SS.log("[Cache] FMDB execute sql: \(sql)")
        checkDB()
        queue.inDatabase { db in
            if db.open() {
                if db.executeUpdate(sql, withArgumentsIn: []) {
                    SS.log("[Cache] 表格'\(model.dbTable().rawValue)'中 \(model.dbTable().key) = '\(model.keyValue())' 的数据更新成功")
                }
                db.close()
            }
        }
    }
    
    func deleteModel(_ table: SSTable, key: String) {
        let sql = "delete from \(table.rawValue) where \(table.key) = '\(key)'"
        SS.log("[Cache] FMDB execute sql: \(sql)")
        checkDB()
        queue.inDatabase { db in
            if db.open() {
                if db.executeUpdate(sql, withArgumentsIn: []) {
                    SS.log("[Cache] 表格'\(table.rawValue)'中 \(table.key) = '\(key)' 的数据删除成功")
                }
                db.close()
            }
        }
    }
}
