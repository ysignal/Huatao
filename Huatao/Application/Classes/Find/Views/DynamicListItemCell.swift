//
//  DynamicListItemCell.swift
//  Huatao
//
//  Created by minse on 2023/1/16.
//

import UIKit

class DynamicListItemCell: UITableViewCell {
    
    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var contentLabel: LineHeightLabel!
    @IBOutlet weak var imageCV: UICollectionView!
    @IBOutlet weak var imageCVHeight: NSLayoutConstraint!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var videoImage: UIImageView!
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var action: SSButton!
    
    @IBOutlet weak var likeLabel: LineHeightLabel!
    @IBOutlet weak var likeImage: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var commentLine: UIView!
    @IBOutlet weak var commentTV: UITableView!
    
    var model = DynamicListItem()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = .clear
        imageCV.register(nibCell: BaseImageItemCell.self)
        contentLabel.font = .ss_regular(size: 14)
    }
    
    func config(item: DynamicListItem) {
        model = item
        userIcon.ss_setImage(item.avatar, placeholder: SSImage.userDefault)
        userName.text = item.name
        contentLabel.text = item.content
        if item.type == 0 {
            // 图片
            if item.images.isEmpty {
                imageCV.alpha = 0
                imageCVHeight.constant = 0
            } else {
                imageCV.alpha = 1
                imageCVHeight.constant = APP.imageHeight(total: item.images.count, lineMax: 3, lineHeight: 86, lineSpace: 2)
            }
            videoView.isHidden = true
        } else {
            imageCV.alpha = 0
            videoImage.image = nil
            videoView.isHidden = item.video.isEmpty
            imageCVHeight.constant = item.video.isEmpty ? 0 : 150

            if DataManager.cacheVideoImage.has(key: item.video), let image = DataManager.cacheVideoImage[item.video] {
                videoImage.image = image
            } else {
                DispatchQueue.global().async { [weak self] in
                    guard let weakSelf = self else { return }
                    let image = SSPhotoManager.getVideoFirstImage(forUrl: item.video)
                    DispatchQueue.main.async {
                        if weakSelf.model.dynamicId == item.dynamicId {
                            DataManager.cacheVideoImage[weakSelf.model.video] = image
                            self?.videoImage.image = image
                        }
                    }
                }
            }
        }
        imageCV.reloadData()
        
        timeLabel.text = item.createdAt
        
        likeLabel.text = "订单12323哈哈"
        likeLabel.isHidden = item.likeArray.isEmpty
        likeImage.isHidden = item.likeArray.isEmpty
        commentLine.isHidden = item.commentArray.isEmpty
        commentTV.isHidden = item.commentArray.isEmpty
    }
    
    
    
    @IBAction func toMore(_ sender: Any) {
        
    }
    
    @IBAction func toAction(_ sender: Any) {
        
    }
    
}

extension DynamicListItemCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 86, height: 86)
    }

}

extension DynamicListItemCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(with: BaseImageItemCell.self, for: indexPath)
        let item = model.images[indexPath.row]
        cell.config(url: item, placeholder: SSImage.photoDefaultWhite)
        return cell
    }
    
}

extension DynamicListItemCell: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 22
    }
    
}

extension DynamicListItemCell: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: CommentListItemCell.self)
        cell.config(item: CommentListItem())
        return cell
    }
    
}
