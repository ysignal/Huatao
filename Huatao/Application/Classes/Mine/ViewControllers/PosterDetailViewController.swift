//
//  PosterDetailViewController.swift
//  Huatao
//
//  Created by minse on 2023/1/26.
//

import UIKit

class PosterDetailViewController: BaseViewController {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerViewWidth: NSLayoutConstraint!
    @IBOutlet weak var headerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentViewHeight: NSLayoutConstraint!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var contentLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var detailImage: UIImageView!
    
    var model = MaterialDetail()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func buildUI() {
        fakeNav.title = "详情"
        headerView.backgroundColor = .hex("f6f6f6")
        
        headerViewWidth.constant = SS.w
        contentLabel.text = model.content
        
        let contentHeight = model.content.height(from: .systemFont(ofSize: 14), width: SS.w - 48) + 6
        contentLabelHeight.constant = contentHeight
        contentViewHeight.constant = contentHeight + SS.w - 12
        headerViewHeight.constant = contentHeight + SS.w + 142
        
        detailImage.ss_setImage(model.images.first ?? "", placeholder: SSImage.photoDefaultWhite) { [weak self] image in
            SSMainAsync {
                let realHeight = image.size.height/image.size.width * (SS.w - 48)
                self?.contentViewHeight.constant = contentHeight + realHeight + 36
                self?.headerViewHeight.constant = contentHeight + realHeight + 190
            }
        }
        
    }
    
    @IBAction func copyText(_ sender: Any) {
        UIPasteboard.general.string = model.content
        toast(message: "复制成功")
    }
    
    @IBAction func saveImage(_ sender: Any) {
        if let image = detailImage.image {
            SSPhotoManager.saveImageToAlbum(image: image) { [weak self] isFinished, asset in
                SSMainAsync {
                    if isFinished {
                        self?.toast(message: "保存成功")
                    } else {
                        self?.toast(message: "保存失败")
                    }
                }
            }
        }
    }
    
}
