//
//  OtherLoginViewController.swift
//  Huatao
//
//  Created on 2023/1/12.
//

import UIKit

class OtherLoginViewController: SSViewController {
    
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var codeTF: UITextField!
    @IBOutlet weak var codeBtn: UIButton!
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var loginBtn: UIButton!
    
    private var mobile: String = ""
    
    private var code: String = ""
    
    deinit {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func buildUI() {
        hideNavBar()
        
        if TimerManager.isCountDown() {
            startCountDown()
            codeBtn.isUserInteractionEnabled = false
            codeBtn.title = "\(TimerManager.phoneCount)秒后重新获取"
        }
        
        loginView.drawThemeGradient(CGSize(width: SS.w - 50, height: 42))
        
        loginView.isHidden = true
        loginBtn.backgroundColor = .hex("dddddd")
        
        checkTextFieldState()
    }
    
    private func startCountDown() {
        TimerManager.countDown { [weak self] count, isEnded in
            if isEnded {
                self?.codeBtn.isUserInteractionEnabled = true
                self?.codeBtn.title = "获取验证码"
            } else {
                self?.codeBtn.title = "\(count)秒后重新获取"
            }
        }
    }
    
    
    
    private func checkTextFieldState() {
        let isEnabled = mobile.count >= 11 && code.count >= 4
        if isEnabled {
            loginView.isHidden = false
            loginBtn.backgroundColor = .clear
            loginBtn.isUserInteractionEnabled = true
        } else {
            loginView.isHidden = true
            loginBtn.backgroundColor = .hex("dddddd")
            loginBtn.isUserInteractionEnabled = false
        }
    }
    
    @IBAction func textFieldDidChanged(_ sender: Any) {
        if let tf = sender as? UITextField {
            if tf == phoneTF, phoneTF.markedTextRange == nil, let text = phoneTF.text {
                mobile = text
            } else if tf == codeTF, codeTF.markedTextRange == nil, let text = codeTF.text {
                code = text
            }
        }
        checkTextFieldState()
    }
    
    @IBAction func toGetCode(_ sender: Any) {
        // 收起键盘
        phoneTF.resignFirstResponder()
        codeTF.resignFirstResponder()
        view.ss.showHUDLoading()
        HttpApi.Login.sendSms(mobile: mobile, sign: 1).done { [weak self] () in
            TimerManager.phoneCount = 60
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
    
    @IBAction func toLogin(_ sender: Any) {
        // 收起键盘
        phoneTF.resignFirstResponder()
        codeTF.resignFirstResponder()
        
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

}
