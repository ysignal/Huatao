//
//  SSPhoto.swift
//  Huatao
//
//  Created on 2023/1/16.
//

import Foundation
import Photos

class SSPhoto: NSObject {

    var caption: String = ""
    
    var emptyImage: Bool = false
    
    var isVideo: Bool = false
    
    var underlyingImage: UIImage? = nil
    
    
    var image: UIImage?
    var photoURL: URL?
    var asset: PHAsset?
    var assetTargetSize: CGSize = .zero
    
    var loadingInProgress: Bool = false
    var assetRequestID: PHImageRequestID = PHInvalidImageRequestID
    
    override init() {
        emptyImage = true
    }
    
    init(image: UIImage) {
        self.image = image
    }
    
    init(url: URL) {
        self.photoURL = url
    }
    
    init(asset: PHAsset, targetSize: CGSize) {
        self.asset = asset
        self.assetTargetSize = targetSize
        self.isVideo = asset.mediaType == .video
    }
    
    func loadUnderlyingImageAndNotify() {
        assert(Thread.current.isMainThread, "This method must be called on the main thread.")
        if loadingInProgress { return }
        loadingInProgress = true
        if underlyingImage != nil {
            imageLoadingComplete()
        } else {
            performLoadUnderlyingImageAndNotify()
        }
    }
    
    
    func imageLoadingComplete() {
        assert(Thread.current.isMainThread, "This method must be called on the main thread.")
        // Complete so notify
        loadingInProgress = false
        // Notify on next run loop
//        perform(#selector(postCompleteNotification), with: nil, afterDelay: 0)
        postCompleteNotification()
    }

    func postCompleteNotification() {
        NotificationCenter.default.post(name: .SS_PHOTO_LOADING_DID_END_NOTIFICATION, object: self)
    }
    
    func performLoadUnderlyingImageAndNotify() {
        // Get underlying image
        if let image = self.image {
            // We have UIImage!
            underlyingImage = image
        } else if let asset = self.asset {
            // Load from photos asset
            performLoadUnderlyingImageAndNotify(with: asset, targetSize: assetTargetSize)
        } else {
            // Image is empty
            imageLoadingComplete()
        }
    }
    
    // Load from photos library
    func performLoadUnderlyingImageAndNotify(with asset: PHAsset, targetSize: CGSize) {
        let imageManager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.resizeMode = .fast
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = false
        options.progressHandler = { progress, error, stop, info in
            let dict = ["progress": progress, "photo": self]
            NotificationCenter.default.post(name: .SS_PHOTO_PROGRESS_NOTIFICATION, object: dict)
        }
        assetRequestID = imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options, resultHandler: { [weak self] result, info in
            DispatchQueue.main.async {
                self?.underlyingImage = result
                self?.imageLoadingComplete()
            }
        })
    }
    
    
    // Release if we can get it again from path or url
    func unloadUnderlyingImage() {
        loadingInProgress = false
        underlyingImage = nil
    }
    
    
    func cancelAnyLoading() {
        PHImageManager.default().cancelImageRequest(assetRequestID)
        assetRequestID = PHInvalidImageRequestID
    }
    
    func getVideoURL(_ complete: ((URL?) -> Void)?) {
        complete?(photoURL)
    }
}
