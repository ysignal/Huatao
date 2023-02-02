//
//  CirclePublishViewController.swift
//  Huatao
//
//  Created by minse on 2023/1/29.
//

import UIKit
import ZLPhotoBrowser

class CirclePublishViewController: BaseViewController {
    
    @IBOutlet weak var textView: SSTextView!
    @IBOutlet weak var imageCV: UICollectionView!
    
    private var maxCount: Int = 9
    
    var list: [ZLResultModel] = []
    
    var completeBlock: NoneBlock?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func buildUI() {
        fakeNav.title = "发布动态"
        
        imageCV.register(nibCell: BaseImageItemCell.self)
    }
    
    func toPickerImage() {
        let zl = ZLPhotoPreviewSheet()
        ZLPhotoConfiguration.default().allowRecordVideo(false).maxSelectCount(9 - list.count)
        
        zl.selectImageBlock = { images, isFull in
            self.list.append(contentsOf: images)
            self.imageCV.reloadData()
        }
        zl.showPhotoLibrary(sender: self)
    }

}

extension CirclePublishViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row >= list.count {
            toPickerImage()
        } else {
            let index = indexPath.row - 1
            
        }
    }
    
}

extension CirclePublishViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return list.count < maxCount ? list.count + 1 : list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(with: BaseImageItemCell.self, for: indexPath)
        if indexPath.row >= list.count {
            cell.baseImage.image = UIImage(named: "btn_image_add_fill")
        } else {
            let item = list[indexPath.row]
            cell.baseImage.image = item.image
        }
        return cell
    }
    
}
