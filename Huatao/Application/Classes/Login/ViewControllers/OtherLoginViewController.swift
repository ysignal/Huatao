//
//  OtherLoginViewController.swift
//  Huatao
//
//  Created by minse on 2023/1/12.
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

    private var timer: Timer?
    
    deinit {
        // 注销事件
        timer?.invalidate()
        // 释放Timer
        timer = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func buildUI() {
        hideNavBar()
        
        if APP.phoneCount > 0 {
            startCountDown()
            codeBtn.isUserInteractionEnabled = false
        }
        
        loginView.drawGradient(start: .hex("f5a41b"), end: .hex("f08720"), size: CGSize(width: SS.w - 50, height: 42), direction: .t2b)
        
        loginView.isHidden = true
        loginBtn.backgroundColor = .hex("dddddd")
        
        checkTextFieldState()
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
            } else if tf == codeTF, codeTF.markedTextRange == nil, let text = phoneTF.text {
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
            APP.phoneCount = 59
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
