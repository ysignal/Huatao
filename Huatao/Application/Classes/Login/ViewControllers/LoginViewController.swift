//
//  LoginViewController.swift
//  Huatao
//
//  Created on 2023/1/10.
//

import UIKit

class LoginViewController: SSViewController {
    
    @IBOutlet weak var mobileTF: UITextField!
    @IBOutlet weak var codeTF: UITextField!
    @IBOutlet weak var inviteTF: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var codeBtn: UIButton!
    
    @IBOutlet weak var radioBtn: SSButton!
    
    private var mobile: String = ""
    private var code: String = ""
    private var inviteCode: String = ""
    
    var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        readCacheLogin()
    }
    
    override func buildUI() {
        hideNavBar()
        
        if !WXApi.isWXAppInstalled() {
            // 未安装微信，不支持微信登录
//            wechatBtn.isHidden = true
//            wechatLabel.isHidden = true
        }
        
        if !APP.isAgree {
            AgreementAlertView.show(title: "隐私协议",
                                    urlString: "https://www.pchome.net/app/privacy.html")
            { result in
                APP.isAgree = true
            }
        }
        
        mobileTF.delegate = self
        codeTF.delegate = self
        inviteTF.delegate = self
        
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
    }
    
    private func checkTextFieldState() {
        let isEnabled = mobile.count >= 11 && code.count >= 4
        if isEnabled {
            loginBtn.drawThemeGradient(CGSize(width: SS.w - 54, height: 44))
            loginBtn.isUserInteractionEnabled = true
        } else {
            loginBtn.drawDisable(CGSize(width: SS.w - 54, height: 44))
            loginBtn.isUserInteractionEnabled = false
        }
    }
    
    private func startCountDown() {
        // 注销事件
        timer?.invalidate()
        // 释放Timer
        timer = nil
        // 开启事件
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] t in
            if APP.phoneCount <= 1 {
                t.invalidate()
                SSMainAsync {
                    self?.codeBtn.isUserInteractionEnabled = true
                    self?.codeBtn.title = "获取验证码"
                }
                return
            }
            APP.phoneCount -= 1
            SSMainAsync {
                self?.codeBtn.title = "\(APP.phoneCount)秒后重新获取"
            }
        }
    }
    
    @IBAction func toGetCode(_ sender: Any) {
        // 收起键盘
        view.endEditing(true)
        if !mobile.isPhoneStr() {
            toast(message: "手机号格式错误")
            return
        }
        view.ss.showHUDLoading()
        HttpApi.Login.sendSms(mobile: mobile, sign: 1).done { [weak self] () in
            APP.phoneCount = 60
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.toast(message: "发送成功")
                self?.codeBtn.isUserInteractionEnabled = false
                self?.startCountDown()
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.toast(message: error.localizedDescription)
            }
        }
    }
    
    @IBAction func textFieldChanged(_ sender: UITextField) {
        if sender.markedTextRange == nil, let text = sender.text {
            switch sender {
            case mobileTF:
                mobile = text
            case codeTF:
                code = text
            case inviteTF:
                inviteCode = text
            default: break
            }
        }
        checkTextFieldState()
    }
    
    @IBAction func toLogin(_ sender: Any) {
        // 收起键盘
        view.endEditing(true)
        view.ss.showHUDLoading()
        HttpApi.Login.codeLogin(mobile: mobile, code: code).done { [weak self] data in
            guard let weakSelf = self else { return }
            let model = data.kj.model(LoginData.self)
            APP.loginDataString = model.kj.JSONString()
            APP.lastLogin = weakSelf.mobile
            SSMainAsync {
                weakSelf.view.ss.hideHUD()
                // 跳转到APP主页
                APP.switchMainViewController()
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.toast(message: error.localizedDescription)
            }
        }
    }
    
    @IBAction func toPrivate(_ sender: Any) {
        // 查看隐私政策
    }
    
    @IBAction func toChangeRadio(_ sender: Any) {
        radioBtn.isSelected.toggle()
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
