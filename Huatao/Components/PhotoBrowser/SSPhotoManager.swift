//
//  SSPhotoManager.swift
//  Huatao
//
//  Created by minse on 2023/1/16.
//

import UIKit
import Photos
import ZLPhotoBrowser

struct SSPhotoManager {
    
    /// 保存图片到相册
    /// - Parameters:
    ///   - image: 需要保存的图片
    ///   - completion: 结果回调
    static func saveImageToAlbum(image: UIImage, completion: ((Bool, PHAsset?) -> Void)?) {
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .denied || status == .restricted {
            completion?(false, nil)
            return
        }
        
        var placeholderAsset: PHObjectPlaceholder?
        PHPhotoLibrary.shared().performChanges({
            let newAssetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            placeholderAsset = newAssetRequest.placeholderForCreatedAsset
        }) { success, _ in
            SSMainAsync {
                if success {
                    let asset = self.getAsset(from: placeholderAsset?.localIdentifier)
                    completion?(success, asset)
                } else {
                    completion?(false, nil)
                }
            }
        }
    }
    
    /// 根据图片资源的identifier获取图片资源对象
    /// - Parameter localIdentifier: 图片资源identifier
    /// - Returns: 图片资源对象
    private static func getAsset(from localIdentifier: String?) -> PHAsset? {
        guard let id = localIdentifier else {
            return nil
        }
        let result = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: nil)
        return result.firstObject
    }
    
    /// 获取手机中相册的图片资源数组
    /// - Parameters:
    ///   - result: 图片资源集合
    ///   - ascending: 图片排序，concurrent = 升序，reverse = 倒序
    ///   - allowImage: 是否包含图片资源
    ///   - allowVideo: 是否包含视频资源
    ///   - limitCount: 资源最大数量
    /// - Returns: 返回自定义相册资源模型数组：SSPhotoModel
    static func fetchPhoto(in result: PHFetchResult<PHAsset>,
                           ascending: Bool,
                           allowSelectImage: Bool,
                           allowSelectVideo: Bool,
                           limitCount: Int = .max) -> [SSPhotoModel] {
        var models: [SSPhotoModel] = []
        let option: NSEnumerationOptions = ascending ? .init(rawValue: 0) : .reverse
        var count = 1
        
        result.enumerateObjects(options: option) { asset, _, stop in
            let m = SSPhotoModel(asset: asset)
            
            if m.type == .image, !allowSelectImage {
                return
            }
            if m.type == .video, !allowSelectVideo {
                return
            }
            if count == limitCount {
                stop.pointee = true
            }
            
            models.append(m)
            count += 1
        }
        
        return models
    }
    
    /// Fetch all album list.
    static func getPhotoAlbumList(ascending: Bool,
                                  allowSelectImage: Bool,
                                  allowSelectVideo: Bool,
                                  completion: ([SSAlbumListModel]) -> Void) {
        let option = PHFetchOptions()
        if !allowSelectImage {
            option.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.video.rawValue)
        }
        if !allowSelectVideo {
            option.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.image.rawValue)
        }
        
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum,
                                                                  subtype: .albumRegular,
                                                                  options: nil)
        let albums = PHAssetCollection.fetchAssetCollections(with: .album,
                                                             subtype: .albumRegular,
                                                             options: nil)
        let streamAlbums = PHAssetCollection.fetchAssetCollections(with: .album,
                                                                   subtype: .albumMyPhotoStream,
                                                                   options: nil)
        let syncedAlbums = PHAssetCollection.fetchAssetCollections(with: .album,
                                                                   subtype: .albumSyncedAlbum,
                                                                   options: nil)
        let sharedAlbums = PHAssetCollection.fetchAssetCollections(with: .album,
                                                                   subtype: .albumCloudShared,
                                                                   options: nil)
        let arr = [smartAlbums, albums, streamAlbums, syncedAlbums, sharedAlbums]
        
        var albumList: [SSAlbumListModel] = []
        arr.forEach { album in
            album.enumerateObjects { collection, _, _ in
                if collection.assetCollectionSubtype == .smartAlbumAllHidden {
                    return
                }
                if #available(iOS 11.0, *), collection.assetCollectionSubtype.rawValue > PHAssetCollectionSubtype.smartAlbumLongExposures.rawValue {
                    return
                }
                let result = PHAsset.fetchAssets(in: collection, options: option)
                if result.count == 0 {
                    return
                }
                let title = self.getCollectionTitle(collection)
                
                if collection.assetCollectionSubtype == .smartAlbumUserLibrary {
                    // 所有照片相册
                    let model = SSAlbumListModel(title: title, result: result, collection: collection, option: option, isCameraRoll: true)
                    albumList.insert(model, at: 0)
                } else {
                    let model = SSAlbumListModel(title: title, result: result, collection: collection, option: option, isCameraRoll: false)
                    albumList.append(model)
                }
            }
        }
        
        completion(albumList)
    }
    
    static func getCameraRollAlbum(allowSelectImage: Bool,
                                   allowSelectVideo: Bool,
                                   completion: @escaping (SSAlbumListModel) -> Void) {
        let option = PHFetchOptions()
        if !allowSelectImage {
            option.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.video.rawValue)
        }
        if !allowSelectVideo {
            option.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.image.rawValue)
        }
        
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        smartAlbums.enumerateObjects { collection, _, stop in
            if collection.assetCollectionSubtype == .smartAlbumUserLibrary {
                let result = PHAsset.fetchAssets(in: collection, options: option)
                let albumModel = SSAlbumListModel(title: self.getCollectionTitle(collection), result: result, collection: collection, option: option, isCameraRoll: true)
                completion(albumModel)
                stop.pointee = true
            }
        }
    }
    
    /// 转换资源集合的标题
    private static func getCollectionTitle(_ collection: PHAssetCollection) -> String {
        if collection.assetCollectionType == .album {
            // 用户创建的相册
            let title: String? = {
                switch collection.assetCollectionSubtype {
                case .albumMyPhotoStream:
                    return "我的照片流"
                default:
                    return collection.localizedTitle
                }
            }()
            return title ?? "所有照片"
        }
        
        var title: String? = {
            switch collection.assetCollectionSubtype {
            case .smartAlbumUserLibrary:
                return "所有照片"
            case .smartAlbumPanoramas:
                return "全景照片"
            case .smartAlbumVideos:
                return "视频"
            case .smartAlbumFavorites:
                return "个人收藏"
            case .smartAlbumTimelapses:
                return "延时摄影"
            case .smartAlbumRecentlyAdded:
                return "最近添加"
            case .smartAlbumBursts:
                return "连拍快照"
            case .smartAlbumSlomoVideos:
                return "慢动作"
            case .smartAlbumSelfPortraits:
                return "自拍"
            case .smartAlbumScreenshots:
                return "屏幕快照"
            case .smartAlbumDepthEffect:
                return "人像"
            case .smartAlbumLivePhotos:
                return "Live Photos"
            default:
                return collection.localizedTitle
            }
        }()
        
        if #available(iOS 11.0, *), collection.assetCollectionSubtype == .smartAlbumAnimated {
            title = "动图"
        }
        
        return title ?? "所有照片"
    }
    
    @discardableResult
    static func fetchImage(for asset: PHAsset,
                           size: CGSize,
                           progress: ((CGFloat, Error?, UnsafeMutablePointer<ObjCBool>, [AnyHashable: Any]?) -> Void)? = nil,
                           completion: @escaping (UIImage?, Bool) -> Void) -> PHImageRequestID {
        return fetchImage(for: asset,
                          size: size,
                          resizeMode: .fast,
                          progress: progress,
                          completion: completion)
    }
    
    @discardableResult
    static func fetchOriginalImage(for asset: PHAsset,
                                   progress: ((CGFloat, Error?, UnsafeMutablePointer<ObjCBool>, [AnyHashable: Any]?) -> Void)? = nil,
                                   completion: @escaping (UIImage?, Bool) -> Void) -> PHImageRequestID {
        return fetchImage(for: asset,
                          size: PHImageManagerMaximumSize,
                          resizeMode: .none,
                          progress: progress,
                          completion: completion)
    }
    
    /// Fetch asset data.
    @discardableResult
    static func fetchOriginalImageData(for asset: PHAsset,
                                                   progress: ((CGFloat, Error?, UnsafeMutablePointer<ObjCBool>, [AnyHashable: Any]?) -> Void)? = nil,
                                                   completion: @escaping (Data, [AnyHashable: Any]?, Bool) -> Void) -> PHImageRequestID {
        let option = PHImageRequestOptions()
        if (asset.value(forKey: "filename") as? String)?.hasSuffix("GIF") == true {
            option.version = .current
        }
        option.isNetworkAccessAllowed = true
        option.resizeMode = .none
        option.deliveryMode = .highQualityFormat
        option.progressHandler = { pro, error, stop, info in
            SSMainAsync {
                progress?(CGFloat(pro), error, stop, info)
            }
        }
        
        return PHImageManager.default().requestImageData(for: asset, options: option) { data, _, _, info in
            let cancel = info?[PHImageCancelledKey] as? Bool ?? false
            let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool ?? false)
            if !cancel, let data = data {
                completion(data, info, isDegraded)
            }
        }
    }
    
    /// Fetch image for asset.
    private static func fetchImage(for asset: PHAsset,
                                   size: CGSize,
                                   resizeMode: PHImageRequestOptionsResizeMode,
                                   progress: ((CGFloat, Error?, UnsafeMutablePointer<ObjCBool>, [AnyHashable: Any]?) -> Void)? = nil,
                                   completion: @escaping (UIImage?, Bool) -> Void) -> PHImageRequestID {
        let option = PHImageRequestOptions()
        option.resizeMode = resizeMode
        option.isNetworkAccessAllowed = true
        option.deliveryMode = .highQualityFormat
        option.progressHandler = { pro, error, stop, info in
            SSMainAsync {
                progress?(CGFloat(pro), error, stop, info)
            }
        }
        
        return PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: option) { image, info in
            var downloadFinished = false
            if let info = info {
                downloadFinished = !(info[PHImageCancelledKey] as? Bool ?? false) && (info[PHImageErrorKey] == nil)
            }
            let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool ?? false)
            if downloadFinished {
                completion(image, isDegraded)
            }
        }
    }
    
    static func fetchLivePhoto(for asset: PHAsset,
                                           completion: @escaping (PHLivePhoto?, [AnyHashable: Any]?, Bool) -> Void) -> PHImageRequestID {
        let option = PHLivePhotoRequestOptions()
        option.version = .current
        option.deliveryMode = .opportunistic
        option.isNetworkAccessAllowed = true
        
        return PHImageManager.default().requestLivePhoto(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: option) { livePhoto, info in
            let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool ?? false)
            completion(livePhoto, info, isDegraded)
        }
    }
    
    static func fetchVideo(for asset: PHAsset,
                                       progress: ((CGFloat, Error?, UnsafeMutablePointer<ObjCBool>, [AnyHashable: Any]?) -> Void)? = nil,
                                       completion: @escaping (AVPlayerItem?, [AnyHashable: Any]?, Bool) -> Void) -> PHImageRequestID {
        let option = PHVideoRequestOptions()
        option.isNetworkAccessAllowed = true
        option.progressHandler = { pro, error, stop, info in
            SSMainAsync {
                progress?(CGFloat(pro), error, stop, info)
            }
        }
        
        if asset.ss.isInCloud {
            return PHImageManager.default().requestExportSession(forVideo: asset, options: option, exportPreset: AVAssetExportPresetHighestQuality, resultHandler: { session, info in
                // iOS11 and earlier, callback is not on the main thread.
                SSMainAsync {
                    let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool ?? false)
                    if let avAsset = session?.asset {
                        let item = AVPlayerItem(asset: avAsset)
                        completion(item, info, isDegraded)
                    } else {
                        completion(nil, nil, true)
                    }
                }
            })
        } else {
            return PHImageManager.default().requestPlayerItem(forVideo: asset, options: option) { item, info in
                // iOS11 and earlier, callback is not on the main thread.
                SSMainAsync {
                    let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool ?? false)
                    completion(item, info, isDegraded)
                }
            }
        }
    }
    
    static func isFetchImageError(_ error: Error?) -> Bool {
        guard let e = error as NSError? else {
            return false
        }
        if e.domain == "CKErrorDomain" || e.domain == "CloudPhotoLibraryErrorDomain" {
            return true
        }
        return false
    }
    
    static func fetchAVAsset(forVideo asset: PHAsset,
                             completion: @escaping (AVAsset?, [AnyHashable: Any]?) -> Void) -> PHImageRequestID {
        let options = PHVideoRequestOptions()
        options.version = .original
        options.deliveryMode = .automatic
        options.isNetworkAccessAllowed = true
        
        if asset.ss.isInCloud {
            return PHImageManager.default().requestExportSession(forVideo: asset, options: options, exportPreset: AVAssetExportPresetHighestQuality) { session, info in
                // iOS11 and earlier, callback is not on the main thread.
                SSMainAsync {
                    if let avAsset = session?.asset {
                        completion(avAsset, info)
                    } else {
                        completion(nil, info)
                    }
                }
            }
        } else {
            return PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { avAsset, _, info in
                SSMainAsync {
                    completion(avAsset, info)
                }
            }
        }
    }
    
    /// Fetch asset local file path.
    static func fetchAssetFilePath(asset: PHAsset,
                                   completion: @escaping (String?) -> Void) {
        asset.requestContentEditingInput(with: nil) { input, _ in
            var path = input?.fullSizeImageURL?.absoluteString
            if path == nil, let dir = asset.value(forKey: "directory") as? String, let name = asset.value(forKey: "filename") as? String {
                path = String(format: "file:///var/mobile/Media/%@/%@", dir, name)
            }
            completion(path)
        }
    }
    
    /// Save asset original data to file url. Support save image and video.
    static func saveAsset(_ asset: PHAsset, toFile fileUrl: URL, completion: @escaping ((Error?) -> Void)) {
        guard let resource = asset.ss.resource else {
            completion(NSError(domain: "com.SSPhotoBrowser.error", code: -1, userInfo: [NSLocalizedDescriptionKey: "Asset save failed"]))
            return
        }
        
        PHAssetResourceManager.default().writeData(for: resource, toFile: fileUrl, options: nil) { error in
            SSMainAsync {
                completion(error)
            }
        }
    }
    
    /// 获取网络视频的第一帧图片
    /// - Parameter urlString: 视频链接
    /// - Returns: 图片
    static func getVideoFirstImage(forUrl urlString: String) -> UIImage? {
        if let url = URL(string: urlString) {
            let asset = AVURLAsset(url: url)
            return getVideoFirstImage(forAsset: asset)
        }
        return nil
    }
    
    /// 获取网络资源的第一帧图片
    /// - Parameter asset: 网络资源
    /// - Returns: 图片
    static func getVideoFirstImage(forAsset asset: AVAsset) -> UIImage? {
        let gen = AVAssetImageGenerator(asset: asset)
        gen.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(0, preferredTimescale: 1)
        var actualTime = CMTimeMakeWithSeconds(0, preferredTimescale: 0)
        if let image = try? gen.copyCGImage(at: time, actualTime: &actualTime) {
            return UIImage(cgImage: image)
        }
        return nil
    }
    
    /// 从本地视频库的视频中获取第一帧图片
    /// - Parameters:
    ///   - asset: 资源库
    ///   - completion: 异步回调
    /// - Returns: 返回请求序号
    static func getVideoFirstImage(forPHAsset asset: PHAsset, completion: @escaping ((UIImage?) -> Void)) -> PHImageRequestID {
        let options = PHVideoRequestOptions()
        options.version = .original
        options.deliveryMode = .automatic
        options.isNetworkAccessAllowed = true
        
        return fetchAVAsset(forVideo: asset) { avAsset, info in
            if let avAsset = avAsset {
                let image = getVideoFirstImage(forAsset: avAsset)
                completion(image)
            } else {
                completion(nil)
            }
        }
    }
}

enum SSNoAuthorityType: Int {
    case library
    case camera
    case microphone
}

/// Authority related.
extension SSPhotoManager {
    static func hasPhotoLibratyAuthority() -> Bool {
        return PHPhotoLibrary.authorizationStatus() == .authorized
    }
    
    static func hasCameraAuthority() -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .restricted || status == .denied {
            return false
        }
        return true
    }
    
    static func hasMicrophoneAuthority() -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        if status == .restricted || status == .denied {
            return false
        }
        return true
    }
    
}
