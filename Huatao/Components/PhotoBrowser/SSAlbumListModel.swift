//
//  c.swift
//  Huatao
//
//  Created by minse on 2023/1/16.
//

import UIKit
import Photos

struct SSAlbumListModel {
    
    public let title: String
    
    public var count: Int {
        return result.count
    }
    
    public var result: PHFetchResult<PHAsset>
    
    public let collection: PHAssetCollection
    
    public let option: PHFetchOptions
    
    public let isCameraRoll: Bool
    
    public var headImageAsset: PHAsset? {
        return result.lastObject
    }
    
    public var models: [SSPhotoModel] = []
    
    // 暂未用到
    private var selectedModels: [SSPhotoModel] = []
    
    // 暂未用到
    private var selectedCount: Int = 0
    
    public init(
        title: String,
        result: PHFetchResult<PHAsset>,
        collection: PHAssetCollection,
        option: PHFetchOptions,
        isCameraRoll: Bool
    ) {
        self.title = title
        self.result = result
        self.collection = collection
        self.option = option
        self.isCameraRoll = isCameraRoll
    }
    
    mutating func refetchPhotos() {
        let models = SSPhotoManager.fetchPhoto(
            in: result,
            ascending: SSPhotoOptions.default.sortAscending,
            allowSelectImage: SSPhotoOptions.default.allowSelectImage,
            allowSelectVideo: SSPhotoOptions.default.allowSelectVideo
        )
    
        self.models.removeAll()
        self.models.append(contentsOf: models)
    }
    
    mutating func refreshResult() {
        result = PHAsset.fetchAssets(in: collection, options: option)
    }
}

extension SSAlbumListModel {
    
    static func ==(lhs: SSAlbumListModel, rhs: SSAlbumListModel) -> Bool {
        return lhs.title == rhs.title &&
               lhs.count == rhs.count &&
               lhs.headImageAsset?.localIdentifier == rhs.headImageAsset?.localIdentifier
    }
    
}
