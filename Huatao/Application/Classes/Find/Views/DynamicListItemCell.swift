//
//  DynamicListItemCell.swift
//  Huatao
//
//  Created on 2023/1/16.
//

import UIKit
import Popover

class DynamicListItemCell: UITableViewCell {
    
    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    @IBOutlet weak var contentLabel: LineHeightLabel!
    @IBOutlet weak var imageCV: UICollectionView!
    @IBOutlet weak var imageCVWidth: NSLayoutConstraint!
    @IBOutlet weak var imageCVHeight: NSLayoutConstraint!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var videoImage: UIImageView!
    @IBOutlet weak var moreBtn: UIButton!
    
    @IBOutlet weak var likeView: UIView!
    @IBOutlet weak var likeImage: UIImageView!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var shareLabel: UILabel!
    
    var model = DynamicListItem() {
        didSet {
            likeImage.image = model.isLike == 1 ? UIImage(named: "ic_like_on") : UIImage(named: "ic_like_off")
            likeLabel.text = "\(model.likeCount)"
        }
    }
    
    // 更新类型，0-删除、1-点赞、2-评论
    var updateBlock: IntBlock?
    
    weak var target: UIViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = .clear
        imageCV.register(nibCell: BaseImageItemCell.self)
        contentLabel.font = .ss_regular(size: 14)
        
        videoView.addGesture(.tap) { tap in
            if tap.state == .ended {
                let vc = VideoPlayViewController()
                vc.urlString = self.model.video
                vc.videoImage = self.videoImage.image
                self.target?.present(vc, animated: true)
            }
        }
        
        likeView.addGesture(.tap) { tap in
            if tap.state == .ended {
                self.toLike()
            }
        }
        
        userIcon.addGesture(.tap) { tap in
            if tap.state == .ended {
                self.toDetail()
            }
        }
        userName.addGesture(.tap) { tap in
            if tap.state == .ended {
                self.toDetail()
            }
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if super.hitTest(point, with: event) == imageCV {
            return self
        }
        return super.hitTest(point, with: event)
    }
    
    func config(item: DynamicListItem, target: UIViewController? = nil) {
        self.target = target
        model = item
        userIcon.ss_setImage(item.avatar, placeholder: SSImage.userDefault)
        userName.text = item.name
        contentLabel.text = item.content
        commentLabel.text = "\(item.commentCount)"
        timeLabel.text = item.createdAt

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

            videoImage.ss_setVideo(item.video)
        }
        imageCV.reloadData()
        
        moreBtn.isHidden = item.userId != APP.loginData.userId
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
    
    func toDetail() {
        let vc = AddFriendViewController.from(sb: .chat)
        vc.userId = model.userId
        target?.go(vc)
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
                    weakSelf.model.likeCount -= 1
                } else {
                    weakSelf.model.likeCount += 1
                }
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
        return CGSize(width: 86, height: 86)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = PreviewViewController()
        vc.configPreview(model.images, index: indexPath.row)
        target?.go(vc)
    }

}

extension DynamicListItemCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(with: BaseImageItemCell.self, for: indexPath)
        let item = model.images[indexPath.row]
        cell.config(url: item, placeholder: SSImage.photoDefault)
        switch model.images.count {
        case 1:
            cell.baseImage.loadOption([.cornerCut(8, .allCorners, CGSize(width: 86, height: 86))])
        case 2:
            switch indexPath.row {
            case 0:
                cell.baseImage.loadOption([.cornerCut(8, [.topLeft, .bottomLeft], CGSize(width: 86, height: 86))])
            default:
                cell.baseImage.loadOption([.cornerCut(8, [.topRight, .bottomRight], CGSize(width: 86, height: 86))])
            }
        case 3:
            switch indexPath.row {
            case 0:
                cell.baseImage.loadOption([.cornerCut(8, [.topLeft, .bottomLeft], CGSize(width: 86, height: 86))])
            case 2:
                cell.baseImage.loadOption([.cornerCut(8, [.topRight, .bottomRight], CGSize(width: 86, height: 86))])
            default:
                cell.baseImage.loadOption([.cornerCut(0, .allCorners, CGSize(width: 86, height: 86))])
            }
        case 4,5,6:
            switch indexPath.row {
            case 0:
                cell.baseImage.loadOption([.cornerCut(8, [.topLeft], CGSize(width: 86, height: 86))])
            case 2:
                cell.baseImage.loadOption([.cornerCut(8, [.topRight], CGSize(width: 86, height: 86))])
            case 3:
                cell.baseImage.loadOption([.cornerCut(8, [.bottomLeft], CGSize(width: 86, height: 86))])
            case 5:
                cell.baseImage.loadOption([.cornerCut(8, [.bottomRight], CGSize(width: 86, height: 86))])
            default:
                cell.baseImage.loadOption([.cornerCut(0, .allCorners, CGSize(width: 86, height: 86))])
            }
        case 7,8,9:
            switch indexPath.row {
            case 0:
                cell.baseImage.loadOption([.cornerCut(8, [.topLeft], CGSize(width: 86, height: 86))])
            case 2:
                cell.baseImage.loadOption([.cornerCut(8, [.topRight], CGSize(width: 86, height: 86))])
            case 6:
                cell.baseImage.loadOption([.cornerCut(8, [.bottomLeft], CGSize(width: 86, height: 86))])
            case 8:
                cell.baseImage.loadOption([.cornerCut(8, [.bottomRight], CGSize(width: 86, height: 86))])
            default:
                cell.baseImage.loadOption([.cornerCut(0, .allCorners, CGSize(width: 86, height: 86))])
            }
        default:
            break
        }
        return cell
    }
    
}
