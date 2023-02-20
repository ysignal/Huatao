//
//  CircleDetailHeaderView.swift
//  Huatao
//
//  Created on 2023/2/16.
//  
	

import UIKit
import Popover

protocol CircleDetailHeaderViewDelegate: NSObjectProtocol {
    
    func headerViewStartPlayVideo(_ url: String, image: UIImage?)
    func headerViewPreviewImages(_ images: [String], index: Int)
    func headerViewClickedAddFriend()
    func headerViewDidDeleteDynamic()
    
}

class CircleDetailHeaderView: UIView {

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
    @IBOutlet weak var addBtn: UIButton!
    
    @IBOutlet weak var likeView: CircleLikeUserView!
    
    var model = DynamicDetailModel()
    
    weak var delegate: CircleDetailHeaderViewDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageCV.register(nibCell: BaseImageItemCell.self)
        contentLabel.font = .ss_regular(size: 14)
        
        videoView.addGesture(.tap) { tap in
            if tap.state == .ended {
                self.delegate?.headerViewStartPlayVideo(self.model.video, image: self.videoImage.image)
            }
        }
    }
    
    func config(item: DynamicDetailModel, delegate: CircleDetailHeaderViewDelegate) {
        self.delegate = delegate
        model = item
        userIcon.ss_setImage(item.userinfo.avatar, placeholder: SSImage.userDefault)
        userName.text = item.userinfo.name
        contentLabel.text = item.content
        timeLabel.text = item.createdAt
        moreBtn.isHidden = item.userinfo.userId != APP.loginData.userId
        addBtn.isHidden = item.userinfo.userId == APP.loginData.userId
        likeView.isHidden = item.likeArray.isEmpty
        let baseHeight: CGFloat = 86
        let contentHeight = item.content.height(from: .ss_regular(size: 14), width: SS.w - 24, lineHeight: 20)
        let likeHeight: CGFloat = likeView.isHidden && moreBtn.isHidden ? 12 : 48

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
            ex_height = baseHeight + contentHeight + imageCVHeight.constant + likeHeight
        } else {
            imageCV.alpha = 0
            videoImage.image = nil
            videoView.isHidden = item.video.isEmpty
            imageCVHeight.constant = item.video.isEmpty ? 0 : 150

            videoImage.ss_setVideo(item.video)
            
            ex_height = baseHeight + 150 + contentHeight + likeHeight
        }
        imageCV.reloadData()
        
        likeView.config(data: item.likeArray)
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
    
    func toDelete() {
        SS.keyWindow?.ss.showHUDLoading()
        HttpApi.Find.deleteDynamic(dynamicId: model.dynamicId).done { [weak self] _ in
            guard let weakSelf = self else { return }
            SSMainAsync {
                SS.keyWindow?.ss.hideHUD()
                SS.keyWindow?.toast(message: "删除成功！")
                weakSelf.delegate?.headerViewDidDeleteDynamic()
            }
        }.catch { error in
            SSMainAsync {
                SS.keyWindow?.ss.hideHUD()
                SS.keyWindow?.toast(message: error.localizedDescription)
            }
        }
    }
    
    @IBAction func toAddFriend(_ sender: Any) {
        delegate?.headerViewClickedAddFriend()
    }
    
}

extension CircleDetailHeaderView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 86, height: 86)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.headerViewPreviewImages(model.images, index: indexPath.row)
    }

}

extension CircleDetailHeaderView: UICollectionViewDataSource {
    
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
