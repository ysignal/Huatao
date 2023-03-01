//
//  SSCacheSaver.swift
//  Huatao
//
//  Created on 2023/1/16.
//

import Foundation
import KakaJSON

struct SSCacheSaver {
    
    static func saveIMUser(_ user: IMUserInfo) {
        var saveUser = user
        saveUser.updated = Date().toString(.custom(APP.dateFormat))
        SSMainAsync {
            SSCacheManager.shared.update(.user, key: saveUser.userId, json: saveUser.kj.JSONObject())
        }
    }
    
    static func saveIMGroup(_ group: IMGroupInfo) {
        var saveGroup = group
        saveGroup.updated = Date().toString(.custom(APP.dateFormat))
        SSMainAsync {
            SSCacheManager.shared.update(.group, key: saveGroup.teamId, json: saveGroup.kj.JSONObject())
        }
    }
    
    static func saveIMGroup(_ user: IMGroupUserInfo) {
        var saveUser = user
        saveUser.updated = Date().toString(.custom(APP.dateFormat))
        SSMainAsync {
            SSCacheManager.shared.update(.groupUser, key: saveUser.tableId, json: saveUser.kj.JSONObject())
        }
    }
    
}
