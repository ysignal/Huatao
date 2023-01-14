//
//  LoginViewController.swift
//  Huatao
//
//  Created by minse on 2023/1/10.
//

import UIKit

class LoginViewController: SSViewController {
    
    @IBOutlet weak var phoneView: UIView!
    @IBOutlet weak var phoneBtn: UIButton!
    @IBOutlet weak var faceBtn: UIButton!
    @IBOutlet weak var wechatBtn: SSButton!
    @IBOutlet weak var wechatLabel: UILabel!
    @IBOutlet weak var radioBtn: SSButton!
    
    var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        readCacheLogin()
    }
    
    override func buildUI() {
        hideNavBar()
        
        
        if !WXApi.isWXAppInstalled() {
            // 未安装微信，不支持微信登录
            wechatBtn.isHidden = true
            wechatLabel.isHidden = true
        }

        phoneView.drawGradient(start: .hex("f5a41b"), end: .hex("f08720"), size: CGSize(width: SS.w - 50, height: 42), direction: .t2b)
        faceBtn.title = "其他手机号登录"
        
        radioBtn.image = SSImage.radioOff
        radioBtn.selectedImage = SSImage.radioOn
    }
    
    private func readCacheLogin() {
        if !APP.loginData.accessToken.isEmpty {
            SS.log(APP.loginData)
            view.ss.showHUDLoading(text: "自动登录")
            SSMainAsync(after: 1) {
                self.view.ss.hideHUD()
                // 跳转到APP主页
                APP.switchMainViewController()
            }
        }

        if APP.isLogout {
            APP.isLogout = false
            AgreementAlertView.show(title: "隐私协议",
                                    urlString: "https://www.pchome.net/app/privacy.html")
            { result in
                
            }
        }
    }
    
    @IBAction func toPhoneLogin(_ sender: Any) {
        if !radioBtn.isSelected {
            toast(message: "请先同意隐私政策")
            return
        }
        let vc = AuthLoginViewController.from(sb: .login)
        go(vc)
    }
    
    @IBAction func toFaceLogin(_ sender: Any) {
        if !radioBtn.isSelected {
            toast(message: "请先同意隐私政策")
            return
        }
        let vc = OtherLoginViewController.from(sb: .login)
        go(vc)
    }
    
    @IBAction func toWechatLogin(_ sender: Any) {
        if !radioBtn.isSelected {
            toast(message: "请先同意隐私政策")
            return
        }
    }
    
    @IBAction func toChangeRadio(_ sender: Any) {
        radioBtn.isSelected.toggle()
    }
}
