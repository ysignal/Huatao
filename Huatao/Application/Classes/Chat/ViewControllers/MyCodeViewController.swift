//
//  MyCodeViewController.swift
//  Huatao
//
//  Created on 2023/2/18.
//  
	

import UIKit
import swiftScan

class MyCodeViewController: BaseViewController {
    
    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var codeImage: UIImageView!
    @IBOutlet weak var screenshotView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func buildUI() {
        fakeNav.title = "我的二维码"
        
        userIcon.ss_setImage(APP.userInfo.avatar, placeholder: SSImage.userDefault)
        userName.text = APP.userInfo.name
        
        // 生成二维码
        let codeString = "huatao://add_friend?user_id=\(APP.loginData.userId)"
        codeImage.ss.showHUDLoading()
        DispatchQueue.global().async {
            let image = LBXScanWrapper.createCode(codeType: "CIQRCodeGenerator",
                                                  codeString: codeString,
                                                  size: CGSize(width: 540, height: 540),
                                                  qrColor: .black,
                                                  bkColor: .white)
            DispatchQueue.main.async {
                self.codeImage.ss.hideHUD()
                self.codeImage.image = image
            }
        }
    }
    
    @IBAction func toScan(_ sender: Any) {
        let vc = LBXScanViewController()
        vc.scanResultDelegate = self
        go(vc)
    }
    
    @IBAction func toSave(_ sender: Any) {
        if let image = screenshotView.screenshots() {
            SSPhotoManager.saveImageToAlbum(image: image) { [weak self] isFinished, asset in
                SSMainAsync {
                    if isFinished {
                        self?.toast(message: "保存成功")
                    } else {
                        self?.toast(message: "保存失败")
                    }
                }
            }
        } else {
            // 获取截图失败，开始绘图
        }
    }
    
}

extension MyCodeViewController: LBXScanViewControllerDelegate {
    
    func scanFinished(scanResult: LBXScanResult, error: String?) {
        if let result = scanResult.strScanned {
            SS.log(result)
        }
    }
    
}
