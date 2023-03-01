//
//  DataManager.swift
//  Charming
//
//  Created on 2022/11/3.
//

import Foundation
import Kingfisher

struct DataManager {
        
    static var cacheVideoImage: [String: UIImage] = [:]
    
    static var vipList: [String] = ["普通会员","铜牌会员","银牌会员","金牌会员","一星会员","二星会员"]
    
    /// 选择省份城市数据
    static var provinceList: [ProvinceModel] = []
    
    /// 通讯录数据
    static var contactList: [FriendListItem] = []
    
    /// 通讯录数据页数
    private static var contactPage: Int = 1
    
    static func cacheImage(_ url: String) {
        if url.isEmpty { return }
        if KingfisherManager.shared.cache.isCached(forKey: url) { return }
        KingfisherManager.shared.cache.retrieveImageInDiskCache(forKey: url, completionHandler: { result in })
    }
    
}

extension DataManager {
    
    /// 刷新通讯录数据
    static func realoadAddressBook() {
        contactPage = 1
        requestAddressBook()
    }
    
    private static func requestAddressBook() {
        HttpApi.Chat.getFriendList(page: contactPage).done { data in
            let listModel = data.kj.model(ListModel<FriendListItem>.self)
            if contactPage == 1 {
                DataManager.contactList = listModel.list
            } else {
                DataManager.contactList.append(contentsOf: listModel.list)
            }
            if DataManager.contactList.count < listModel.total {
                contactPage += 1
                requestAddressBook()
            }
            SSMainAsync {
                APP.isUpdateAddressBook = true
            }
        }.catch { error in
            SSMainAsync {
                SS.keyWindow?.toast(message: error.localizedDescription)
            }
        }
    }
}

protocol CityData {
    
    var code: String {set get}
    
    var name: String {set get}
}

struct ProvinceModel: SSConvertible {
    
    var code: String = ""
    
    var name: String = ""
    
    var cityList: [CityModel] = []
    
}

struct CityModel: SSConvertible {
    
    var code: String = ""
    
    var name: String = ""
    
    var areaList: [AreaModel] = []
    
}

struct AreaModel: SSConvertible {
    
    var code: String = ""
    
    var name: String = ""
    
}
