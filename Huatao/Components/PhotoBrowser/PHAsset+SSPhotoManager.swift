//
//  PHAsset+SSPhotoManager.swift
//  Huatao
//
//  Created on 2023/1/16.
//

import Photos

extension SSFramework where Base: PHAsset {
    var isInCloud: Bool {
        guard let resource = resource else {
            return false
        }
        return !(resource.value(forKey: "locallyAvailable") as? Bool ?? true)
    }
    
    var resource: PHAssetResource? {
        return PHAssetResource.assetResources(for: base).first
    }
}
