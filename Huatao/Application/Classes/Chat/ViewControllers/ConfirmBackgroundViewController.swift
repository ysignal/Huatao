//
//  ConfirmBackgroundViewController.swift
//  Huatao
//
//  Created on 2023/2/22.
//  
	

import UIKit

class ConfirmBackgroundViewController: BaseViewController {
    
    lazy var background: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    lazy var lineView: UIView = {
        return UIView(backgroundColor: .hex("eeeeee"))
    }()
    
    lazy var sendBtn: SSButton = {
        let btn = SSButton().loadOption([.cornerRadius(4), .border(1, .hex("ffb300")), .font(.ss_regular(size: 14)), .title("使用"), .titleColor(.white)])
        btn.drawGradient(start: .hex("ffa300"), end: .hex("ff8100"), size: CGSize(width: 50, height: 26))
        return btn
    }()
    
    var image: UIImage?
    
    var userId: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func buildUI() {
        
        fakeNav.addSubview(sendBtn)
        sendBtn.snp.makeConstraints { make in
            make.width.equalTo(50)
            make.height.equalTo(26)
            make.right.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-9)
        }
        sendBtn.addTarget(self, action: #selector(toSend), for: .touchUpInside)
        
        view.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(SS.statusWithNavBarHeight)
            make.height.equalTo(1)
        }
        
        view.addSubview(background)
        background.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.top.equalTo(lineView.snp.bottom)
        }
        
        background.image = image
    }
    
    @objc func toSend() {
        view.ss.showHUDLoading()
        if let data = image?.compress(maxSize: 200 * 1024) {
            HttpApi.File.uploadImage(data: data, fileName: "background.png").done { [weak self] data in
                guard let weakSelf = self else { return }
                let model = data.kj.model(AvatarUrl.self)
                DispatchQueue.global().async {
                    DataManager.cacheImage(model.allUrl)
                }
                HttpApi.Chat.putFriendDetail(userId: weakSelf.userId, backgroundImg: model.allUrl).done { _ in
                    DispatchQueue.global().async {
                        SSCacheLoader.loadIMUser(from: weakSelf.userId) { data in
                            if var user = data {
                                user.backgroundImage = model.allUrl
                                SSCacheSaver.saveIMUser(user)
                            }
                        }
                    }
                    SSMainAsync {
                        weakSelf.view.ss.hideHUD()
                        weakSelf.back(svc: UserDetailViewController.self)
                    }
                }.catch { error in
                    SSMainAsync {
                        weakSelf.view.ss.hideHUD()
                        weakSelf.toast(message: error.localizedDescription)
                    }
                }
            }.catch { [weak self] error in
                SSMainAsync {
                    self?.view.ss.hideHUD()
                    self?.toast(message: error.localizedDescription)
                }
            }
        } else {
            view.ss.hideHUD()
        }
    }

}
