//
//  DynamicListItemCell.swift
//  Huatao
//
//  Created by minse on 2023/1/16.
//

import UIKit
import Popover

class DynamicListItemCell: UITableViewCell {
    
    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var contentLabel: LineHeightLabel!
    @IBOutlet weak var imageCV: UICollectionView!
    @IBOutlet weak var imageCVHeight: NSLayoutConstraint!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var videoImage: UIImageView!
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var actionBtn: SSButton!
    
    @IBOutlet weak var likeCV: UICollectionView!
    @IBOutlet weak var likeCVHeight: NSLayoutConstraint!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var commentLine: UIView!
    @IBOutlet weak var commentTV: UITableView!
    
    var model = DynamicListItem()
    
    // 更新类型，0-删除、1-点赞、2-评论
    var updateBlock: IntBlock?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = .clear
        likeCV.register(nibCell: LikeListItemCell.self)
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
                            DataManager.cacheVideoImage[item.video] = image
                            self?.videoImage.image = image
                        }
                    }
                }
            }
        }
        imageCV.reloadData()
        likeCV.reloadData()
        commentTV.reloadData()
        timeLabel.text = item.createdAt
        
        moreBtn.isHidden = item.userId != APP.loginData.userId

        likeCVHeight.constant = APP.likeHeight(for: item)
        likeCV.isHidden = item.likeArray.isEmpty
        commentLine.isHidden = item.commentArray.isEmpty
        commentTV.isHidden = item.commentArray.isEmpty
    }

    @IBAction func toMore(_ sender: Any) {
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 88, height: 42)))
        let deleteLabel = UILabel(text: "删除", textColor: .white, textFont: .ss_regular(size: 14))
        deleteLabel.textAlignment = .center
        view.addSubview(deleteLabel)
        deleteLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.left.bottom.right.equalToSuperview()
        }
        let popover = Popover(options: [.color(.black.withAlphaComponent(0.7)),
                                        .blackOverlayColor(.clear),
                                        .arrowSize(CGSize(width: 12, height: 6)),
                                        .cornerRadius(8),
                                        .sideEdge(12)])
        view.addGesture(.tap) { tap in
            if tap.state == .ended {
                popover.dismiss()
                self.toDelete()
            }
        }
        popover.popoverType = .down
        popover.show(view, fromView: moreBtn)

    }
    
    @IBAction func toAction(_ sender: Any) {
        let popover = Popover(options: [.color(.black.withAlphaComponent(0.7)),
                                        .blackOverlayColor(.clear),
                                        .cornerRadius(4),
                                        .arrowSize(.zero),
                                        .sideEdge(12)])
        popover.popoverType = .left
        let menuView = CircleActionView(size: CGSize(width: 140, height: 32))
        menuView.selectedBlock = { [weak self] index in
            popover.dismiss()
            switch index {
            case 1:
                // 点赞
                self?.toLike()
            case 2:
                break
            default:
                break
            }
        }
        popover.show(menuView, fromView: actionBtn)
    }
    
    func toDelete() {
        SS.keyWindow?.ss.showHUDLoading()
        HttpApi.Find.deleteDynamic(dynamicId: model.dynamicId).done { [weak self] _ in
            guard let weakSelf = self else { return }
            SSMainAsync {
                SS.keyWindow?.ss.hideHUD()
                SS.keyWindow?.toast(message: "删除成功！")
                weakSelf.updateBlock?(0)
            }
        }.catch { error in
            SSMainAsync {
                SS.keyWindow?.ss.hideHUD()
                SS.keyWindow?.toast(message: error.localizedDescription)
            }
        }
    }
    
    func toLike() {
        let isLike = model.isLike == 1
        HttpApi.Find.putDynamicLike(dynamicId: model.dynamicId).done { [weak self] _ in
            guard let weakSelf = self else { return }
            SSMainAsync {
                weakSelf.model.isLike = isLike ? 0 : 1
                if isLike {
                    weakSelf.model.likeArray.removeAll(where: { $0.userName == APP.userInfo.name && $0.userAvatar == APP.userInfo.avatar })
                    SS.keyWindow?.toast(message: "取消点赞成功！")
                } else {
                    weakSelf.model.likeArray.append(LikeListItem.myItem())
                    SS.keyWindow?.toast(message: "点赞成功！")
                }
                weakSelf.updateBlock?(1)
            }
        }.catch { error in
            SSMainAsync {
                SS.keyWindow?.toast(message: error.localizedDescription)
            }
        }
    }
    
}

extension DynamicListItemCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == likeCV {
            let item = model.likeArray[indexPath.row]
            let textWidth = item.userName.width(from: .ss_regular(size: 12), height: 21)
            return CGSize(width: textWidth + 20, height: 21)
        }
        return CGSize(width: 86, height: 86)
    }

}

extension DynamicListItemCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == likeCV {
            return model.likeArray.count
        }
        return model.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == likeCV {
            let cell = collectionView.dequeueReusableCell(with: LikeListItemCell.self, for: indexPath)
            let item = model.likeArray[indexPath.row]
            cell.nameLabel.text = item.userName
            return cell
        }
        let cell = collectionView.dequeueReusableCell(with: BaseImageItemCell.self, for: indexPath)
        let item = model.images[indexPath.row]
        cell.config(url: item, placeholder: SSImage.photoDefault)
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
