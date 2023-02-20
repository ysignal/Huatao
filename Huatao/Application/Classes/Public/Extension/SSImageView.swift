//
//  SSImageView.swift
//  Huatao
//
//  Created on 2023/1/13.
//

import KingfisherWebP
import Kingfisher

extension UIImageView {
    
    func ss_setImage(_ path: String, placeholder: UIImage? , complete: ((UIImage) -> Void)? = nil) {
        if path.hasPrefix("http") {
            self.kf.setImage(with: URL(string: path), placeholder: placeholder, options: [.processor(WebPProcessor.default), .cacheSerializer(WebPSerializer.default), .transition(.fade(0.25))]) { result in
                switch result {
                case .success(let res):
                    complete?(res.image)
                default:
                    break
                }
            }
        } else if !path.isEmpty, let img = UIImage(named: path) {
            self.image = img
        } else {
            self.image = placeholder
        }
    }
    
    func ss_setVideo(_ path: String, placeholder: UIImage? = nil, animated: Bool = true) {
        let loadImage = {
            self.image = nil
            if animated {
                self.ss.showHUDLoading()
            }
            DispatchQueue.global().async {
                if let image = SSPhotoManager.getVideoFirstImage(forUrl: path) {
                    if let data = image.pngData() {
                        KingfisherManager.shared.cache.storeToDisk(data, forKey: path)
                    }
                    DispatchQueue.main.async {
                        self.image = image
                        self.ss.hideHUD()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.image = placeholder
                        self.ss.hideHUD()
                    }
                }
            }
        }
        KingfisherManager.shared.cache.retrieveImageInDiskCache(forKey: path) { result in
            SSMainAsync {
                switch result {
                case .success(let data):
                    if let image = data {
                        self.image = image
                    } else {
                        loadImage()
                    }
                case .failure(_):
                    loadImage()
                }
            }
        }
    }
}
