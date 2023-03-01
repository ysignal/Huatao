//
//  PromoteItemCell.swift
//  Huatao
//
//  Created on 2023/2/24.
//  
	

import UIKit
import swiftScan

class PromoteItemCell: UICollectionViewCell {
    
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var backgroundBottom: NSLayoutConstraint!
    @IBOutlet weak var promoteImage: UIImageView!
    
    lazy var codeImage: UIImageView = {
        return UIImageView()
    }()
    
    lazy var userView: UIView = {
        let v = UIView(backgroundColor: .hex("e2e2e2"))
        v.cornerRadius = 13
        return v
    }()
    
    lazy var userIcon: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.cornerRadius = 10
        return iv
    }()
    
    lazy var contentLabel: UILabel = {
        let lb = UILabel(text: nil, textColor: .hex("333333"), textFont: .ss_semibold(size: 12))
        return lb
    }()
    
    lazy var screenshotView: UIImageView = {
        let iv = UIImageView(frame: CGRect(x: 0, y: SS.h, width: 375, height: 812))
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        promoteImage.cornerRadius = 8
        backgroundBottom.constant = SS.safeBottomHeight + 94
        background.clipsToBounds = false
        
        let size: CGFloat = 60
        codeImage.ss.showHUDLoading()
        DispatchQueue.global().async {
            let image = LBXScanWrapper.createCode(codeType: "CIQRCodeGenerator",
                                                  codeString: APP.shareUrl,
                                                  size: CGSize(width: size * 3, height: size * 3),
                                                  qrColor: .black,
                                                  bkColor: .white)
            DispatchQueue.main.async {
                self.codeImage.ss.hideHUD()
                self.codeImage.image = image
            }
        }
        
        background.addSubview(codeImage)
        codeImage.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-35)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(size)
        }
        
        let content = "\(APP.userInfo.name)邀请你扫码注册APP"
        let contentWidth = content.width(from: .ss_semibold(size: 12), height: 20)
        background.addSubview(userView)
        userView.snp.makeConstraints { make in
            make.bottom.equalTo(codeImage.snp.top).offset(-12)
            make.height.equalTo(26)
            make.width.equalTo(contentWidth + 40)
            make.centerX.equalToSuperview()
        }
        
        userIcon.ss_setImage(APP.userInfo.avatar, placeholder: SSImage.userDefault)
        userView.addSubview(userIcon)
        userIcon.snp.makeConstraints { make in
            make.width.height.equalTo(20)
            make.left.equalToSuperview().offset(3)
            make.centerY.equalToSuperview()
        }
        
        contentLabel.text = content
        userView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.left.equalTo(userIcon.snp.right).offset(8)
            make.centerY.equalToSuperview()
        }
        
        background.addGesture(.long) { long in
            if long.state == .began {
                if let image = self.screenshotView.screenshots() {
                    SSPhotoManager.saveImageToAlbum(image: image) { finished, _ in
                        if finished {
                            self.toast(message: "保存成功")
                        } else {
                            self.toast(message: "保存失败")
                        }
                    }
                }
            }
        }
        
        addSubview(screenshotView)
        setupScreenshotView()
    }
    
    func setupScreenshotView() {
        let size: CGFloat = 75

        let codeView = UIImageView()
        screenshotView.addSubview(codeView)
        codeView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-60)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(size)
        }
        
        DispatchQueue.global().async {
            let image = LBXScanWrapper.createCode(codeType: "CIQRCodeGenerator",
                                                  codeString: APP.shareUrl,
                                                  size: CGSize(width: size * 3, height: size * 3),
                                                  qrColor: .black,
                                                  bkColor: .white)
            DispatchQueue.main.async {
                codeView.image = image
            }
        }
        
        let content = "\(APP.userInfo.name)邀请你扫码注册APP"
        let contentWidth = content.width(from: .ss_semibold(size: 12), height: 20)
        let v1 = UIView(backgroundColor: .hex("e2e2e2"))
        v1.cornerRadius = 13
        screenshotView.addSubview(v1)
        v1.snp.makeConstraints { make in
            make.bottom.equalTo(codeView.snp.top).offset(-20)
            make.height.equalTo(26)
            make.width.equalTo(contentWidth + 40)
            make.centerX.equalToSuperview()
        }
        
        let ic = UIImageView()
        ic.contentMode = .scaleAspectFill
        ic.cornerRadius = 10
        ic.ss_setImage(APP.userInfo.avatar, placeholder: SSImage.userDefault)
        v1.addSubview(ic)
        ic.snp.makeConstraints { make in
            make.width.height.equalTo(20)
            make.left.equalToSuperview().offset(3)
            make.centerY.equalToSuperview()
        }
        
        let lb = UILabel(text: content, textColor: .hex("333333"), textFont: .ss_semibold(size: 12))
        v1.addSubview(lb)
        lb.snp.makeConstraints { make in
            make.left.equalTo(ic.snp.right).offset(8)
            make.centerY.equalToSuperview()
        }
        
    }
    
    func config(item: MaterialDetail) {
        promoteImage.ss_setImage(item.images.first ?? "", placeholder: nil)
        screenshotView.ss_setImage(item.images.first ?? "", placeholder: nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        background.shadow(ofColor: .black.withAlphaComponent(0.4), radius: 8, offset: CGSize(width: 3, height: 3), opacity: 10)
    }
    
}
