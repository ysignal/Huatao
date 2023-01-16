//
//  SSImageBrowser.swift
//  Huatao
//
//  Created by minse on 2023/1/16.
//

import Foundation

fileprivate let IMAGE_MAX_SIZE_5k: CGFloat = 5120*2880

class SSImageBrowser: NSObject {
    
    static let shared = SSImageBrowser()
    
    private var photos: [SSPhoto] = []
    
    private lazy var photoBrowser: SSPhotoBrowser = {
        let pb = SSPhotoBrowser(delegate: self)
        pb.displayActionButton = true
        pb.displayNavArrows = true
        pb.displaySelectionButtons = false
        pb.alwaysShowControls = false
        pb.zoomPhotosToFill = true
        pb.enableGrid = false
        pb.startOnGrid = false
        pb.setCurrentPhotoIndex(0)
        return pb
    }()
    
    lazy var photoNavigationController: UINavigationController = {
        let vc = UINavigationController(rootViewController: photoBrowser)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .fullScreen
        return vc
    }()
    
    private weak var superController: UIViewController?

    func showImages(_ images: [UIImage], from controller: UIViewController) {
        if images.isEmpty {
            return
        }
        photos = images.compactMap({ image in
            let imageSize = image.size.width * image.size.height
            if imageSize > IMAGE_MAX_SIZE_5k {
                return SSPhoto(image: scaleImage(image, toScale: IMAGE_MAX_SIZE_5k/imageSize))
            }
            return SSPhoto(image: image)
        })

        photoBrowser.reloadData()
        superController = controller
        controller.present(photoNavigationController, animated: true)
    }
    
    func dismissViewController() {
        superController?.dismiss(animated: true, completion: { [weak self] in
            self?.superController = nil
        })
    }
    
    private func scaleImage(_ image: UIImage, toScale scale: CGFloat) -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: image.size.width * scale, height: image.size.height * scale))
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width * scale, height: image.size.height * scale))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext() ?? image
        UIGraphicsEndImageContext()
        return scaledImage
    }
}

extension SSImageBrowser: SSPhotoBrowserDelegate {
    func numberOfPhotos(in photoBrowser: SSPhotoBrowser) -> Int {
        return photos.count
    }
    
    func photoBrowser(_ photoBrowser: SSPhotoBrowser, photoAt index: Int) -> SSPhoto? {
        return index < photos.count ? photos[index] : nil
    }
    
    func photoBrowserDidFinishModalPresentation(_ photoBrowser: SSPhotoBrowser) -> Bool {
        dismissViewController()
        return true
    }
}
