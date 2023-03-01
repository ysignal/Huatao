//
//  SSCacheLoader.swift
//  Huatao
//
//  Created on 2023/1/16.
//

import Foundation

struct SSCacheLoader {

    static func loadIMUser(from userId: Int, complete: ((IMUserInfo?) -> Void)? = nil) {
        SSCacheManager.shared.model(from: .user, key: userId) { model in
            complete?(model as? IMUserInfo)
        }
    }
    
    static func loadIMGroup(from teamId: Int, complete: ((IMGroupInfo?) -> Void)? = nil) {
        SSCacheManager.shared.model(from: .group, key: teamId) { model in
            complete?(model as? IMGroupInfo)
        }
    }
    
    static func loadIMGroupUser(from teamId: Int, userId: Int, complete: ((IMGroupUserInfo?) -> Void)? = nil) {
        SSCacheManager.shared.model(from: .groupUser, key: "\(teamId)_\(userId)") { model in
            complete?(model as? IMGroupUserInfo)
        }
    }

}
