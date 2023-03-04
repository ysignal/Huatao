//
//  MobileChangeViewController.swift
//  Huatao
//
//  Created on 2023/3/2.
//  
	

import UIKit

class MobileChangeViewController: BaseViewController {

    @IBOutlet weak var codeButton: UIButton!
    @IBOutlet weak var codeTF: UITextField!
    @IBOutlet weak var mobileTF: UITextField!
    @IBOutlet weak var newButton: UIButton!
    @IBOutlet weak var newTF: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    
    var mobile: String = ""
    
    var code: String = ""
    
    var newCode: String = ""
    
    var completeBlock: NoneBlock?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func buildUI() {
        view.backgroundColor = .ss_f6
        fakeNav.title = "手机绑定"
        
        if TimerManager.isCountDown() {
            startCountDown()
            codeButton.title = "\(TimerManager.phoneCount)秒后重新获取"
        }
        if TimerManager.isNewCountDown() {
            startNewCountDown()
            newButton.title = "\(TimerManager.newCount)秒后重新获取"
        }
        
        doneButton.drawDisable(CGSize(width: SS.w - 48, height: 44))
        
        codeTF.delegate = self
        mobileTF.delegate = self
    }
    
    func startCountDown() {
        TimerManager.countDown { [weak self] count, isEnded in
            if isEnded {
                self?.codeButton.isUserInteractionEnabled = true
                self?.codeButton.title = "获取验证码"
            } else {
                self?.codeButton.title = "\(count)秒后重新获取"
            }
        }
    }
    
    private func checkTextFieldState() {
        let isEnabled = mobile.count >= 11 && code.count >= 4 && newCode.count >= 4
        if isEnabled {
            doneButton.drawThemeGradient(CGSize(width: SS.w - 48, height: 44))
            doneButton.isUserInteractionEnabled = true
        } else {
            doneButton.drawDisable(CGSize(width: SS.w - 48, height: 44))
            doneButton.isUserInteractionEnabled = false
        }
    }
    
    @IBAction func textFieldChanged(_ sender: UITextField) {
        if sender.markedTextRange == nil, let text = sender.text {
            switch sender {
            case mobileTF:
                mobile = text
            case codeTF:
                code = text
            case newTF:
                newCode = text
            default: break
            }
        }
        checkTextFieldState()
    }
    
    @IBAction func toGetCode(_ sender: Any) {
        view.endEditing(true)
        if TimerManager.phoneCount > 0 {
            return
        }
        view.ss.showHUDLoading()
        HttpApi.Login.sendSms(mobile: APP.userInfo.mobile, sign: 4).done { [weak self] () in
            TimerManager.phoneCount = 60
            SSMainAsync {
                self?.startCountDown()
                self?.view.ss.hideHUD()
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.toast(message: error.localizedDescription)
            }
        }
    }
    
    func startNewCountDown() {
        TimerManager.newCountDown { [weak self] count, isEnded in
            if isEnded {
                self?.newButton.isUserInteractionEnabled = true
                self?.newButton.title = "获取验证码"
            } else {
                self?.newButton.title = "\(count)秒后重新获取"
            }
        }
    }
    
    @IBAction func toGetNewCode(_ sender: Any) {
        view.endEditing(true)
        if !mobile.isPhoneStr() {
            toast(message: "手机号码格式不正确")
            return
        }
        if TimerManager.newCount > 0 {
            return
        }
        view.ss.showHUDLoading()
        HttpApi.Login.sendSms(mobile: mobile, sign: 4).done { [weak self] () in
            TimerManager.newCount = 60
            SSMainAsync {
                self?.startNewCountDown()
                self?.view.ss.hideHUD()
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.toast(message: error.localizedDescription)
            }
        }
    }
    
    @IBAction func toNext(_ sender: Any) {
        view.endEditing(true)
        SS.log("mobile=\(mobile)  code=\(code)")
        showConfirm(title: "提示", message: "是否确定更换绑定手机号码") {
            self.toUploadChange()
        }
    }
    
    func toUploadChange() {
        APP.userInfo.mobile = mobile
        completeBlock?()
        back(svc: SettingViewController.self)
    }
}

extension MobileChangeViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
