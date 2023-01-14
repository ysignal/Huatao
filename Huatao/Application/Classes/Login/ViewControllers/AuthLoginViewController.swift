//
//  AuthLoginViewController.swift
//  Huatao
//
//  Created by minse on 2023/1/12.
//

import UIKit

class AuthLoginViewController: SSViewController, WXApiDelegate {
    
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var codeTF: UITextField!
    @IBOutlet weak var codeBtn: UIButton!
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var wechatBtn: SSButton!
    @IBOutlet weak var wechatLabel: UILabel!
    @IBOutlet weak var faceBtn: UIButton!
    
    var mobile: String = ""
    
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
        
        if !mobile.isEmpty {
            let pre = mobile.prefix(3)
            let suf = mobile.suffix(4)
            phoneLabel.text = pre + "****" + suf
        }
        
        loginView.drawGradient(start: .hex("f5a41b"), end: .hex("f08720"), size: CGSize(width: SS.w - 50, height: 42), direction: .t2b)
        
        loginView.isHidden = true
        loginBtn.backgroundColor = .hex("dddddd")
        loginBtn.isUserInteractionEnabled = false
        
        if !WXApi.isWXAppInstalled() {
            // 未安装微信，不支持微信登录
            wechatBtn.isHidden = true
            wechatLabel.isHidden = true
        }
        
        if APP.authCount > 0 {
            startCountDown()
            codeBtn.isUserInteractionEnabled = false
        }
    }
    
    private func startCountDown() {
        // 注销事件
        timer?.invalidate()
        // 释放Timer
        timer = nil
        // 开启事件
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] t in
            if APP.authCount <= 1 {
                t.invalidate()
                SSMainAsync {
                    self?.codeBtn.isUserInteractionEnabled = true
                    self?.codeBtn.title = "获取验证码"
                }
                return
            }
            APP.authCount -= 1
            SSMainAsync {
                self?.codeBtn.title = "\(APP.authCount)秒后重新获取"
            }
        }
    }
    
    @IBAction func codeDidChange(_ sender: Any) {
        if codeTF.markedTextRange == nil, let text = codeTF.text {
            code = text
            if code.count >= 4 {
                loginView.isHidden = false
                loginBtn.backgroundColor = .clear
                loginBtn.isUserInteractionEnabled = true
            } else {
                loginView.isHidden = true
                loginBtn.backgroundColor = .hex("dddddd")
                loginBtn.isUserInteractionEnabled = false
            }
        }
    }
    
    @IBAction func toGetCode(_ sender: Any) {
        // 收起键盘
        codeTF.resignFirstResponder()
        view.ss.showHUDLoading()
        HttpApi.Login.sendSms(mobile: mobile, sign: 1).done { [weak self] () in
            APP.authCount = 60
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
    
    @IBAction func toWechatLogin(_ sender: Any) {
        let req = SendAuthReq()
        req.scope = "snsapi_userinfo"
        req.state = "huatao"
        WXApi.sendAuthReq(req, viewController: self, delegate: self)
    }
    
    func onResp(_ resp: BaseResp) {
        if let auth = resp as? SendAuthResp {
            SS.log(auth.code ?? resp.errStr)
        }
    }
    
    @IBAction func toFaceLogin(_ sender: Any) {

    }
    
}
