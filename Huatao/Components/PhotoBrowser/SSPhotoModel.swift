//
//  SSPhotoModel.swift
//  Huatao
//
//  Created on 2023/1/16.
//

import UIKit
import Photos

let SSMaxImageWidth: CGFloat = 500

struct SSPhotoModel {
    
    enum MediaType: Int {
        case unknown = 0
        case image
        case gif
        case livePhoto
        case video
    }
    
    var identifier: String
    
    var asset: PHAsset
    
    var type: MediaType = .image
    
    var duration: String = ""
    
    var isSelected: Bool = false
    
    var editImage: UIImage? = nil
    
    var thumbImage: UIImage? = nil
    
    var originalImage: UIImage? = nil
    
    var second: Int {
        guard type == .video else {
            return 0
        }
        return Int(round(asset.duration))
    }
    
    var whRatio: CGFloat {
        return CGFloat(asset.pixelWidth) / CGFloat(asset.pixelHeight)
    }
    
    var previewSize: CGSize {
        let scale: CGFloat = UIScreen.main.scale
        if whRatio > 1 {
            let h = min(UIScreen.main.bounds.height, SSMaxImageWidth) * scale
            let w = h * whRatio
            return CGSize(width: w, height: h)
        } else {
            let w = min(UIScreen.main.bounds.width, SSMaxImageWidth) * scale
            let h = w / whRatio
            return CGSize(width: w, height: h)
        }
    }
    
    // Content of the last edit.
    var editImageModel: SSEditImageModel?
    
    init(asset: PHAsset) {
        self.identifier = asset.localIdentifier
        self.asset = asset
        
        type = transformAssetType(for: asset)
        if type == .video {
            duration = transformDuration(for: asset)
        }
    }

    private func transformAssetType(for asset: PHAsset) -> MediaType {
        switch asset.mediaType {
        case .video:
            return .video
        case .image:
            if (asset.value(forKey: "filename") as? String)?.hasSuffix("GIF") == true {
                return .gif
            }
            if #available(iOS 9.1, *) {
                if asset.mediaSubtypes.contains(.photoLive) {
                    return .livePhoto
                }
            }
            return .image
        default:
            return .unknown
        }
    }
    
    private func transformDuration(for asset: PHAsset) -> String {
        let dur = Int(round(asset.duration))
        
        switch dur {
        case 0..<60:
            return String(format: "00:%02d", dur)
        case 60..<3600:
            let m = dur / 60
            let s = dur % 60
            return String(format: "%02d:%02d", m, s)
        case 3600...:
            let h = dur / 3600
            let m = (dur % 3600) / 60
            let s = dur % 60
            return String(format: "%02d:%02d:%02d", h, m, s)
        default:
            return ""
        }
    }
    
}

extension SSPhotoModel {
    
    static func ==(lhs: SSPhotoModel, rhs: SSPhotoModel) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
}
