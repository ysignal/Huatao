//
//  SetPasswordViewController.swift
//  Huatao
//
//  Created on 2023/2/28.
//  
	

import UIKit

class SetPasswordViewController: BaseViewController {
    
    @IBOutlet weak var titleOne: UILabel!
    @IBOutlet weak var titleTwo: UILabel!
    
    @IBOutlet weak var tf1: SSTextField!
    @IBOutlet weak var tf2: SSTextField!
    @IBOutlet weak var tf3: SSTextField!
    @IBOutlet weak var tf4: SSTextField!
    @IBOutlet weak var tf5: SSTextField!
    @IBOutlet weak var tf6: SSTextField!
    
    @IBOutlet weak var completeBtn: UIButton!
    
    /// 设置步骤，1-设置初始密码，2-设置确认密码
    var step: Int = 1
    
    /// 第一次输入的密码
    var pwdOne: String = ""
    
    /// 第二次输入的密码
    var pwdTwo: String = ""
    
    var completeBlock: NoneBlock?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func buildUI() {
        
        tf1.ssDelegate = self
        tf2.ssDelegate = self
        tf3.ssDelegate = self
        tf4.ssDelegate = self
        tf5.ssDelegate = self
        tf6.ssDelegate = self
        
        tf1.becomeFirstResponder()
    }
    
    func clearInput() {
        tf1.text = ""
        tf2.text = ""
        tf3.text = ""
        tf4.text = ""
        tf5.text = ""
        tf6.text = ""
        tf1.becomeFirstResponder()
    }
    
    @IBAction func textFieldDidEditingChanged(_ sender: Any) {
        if let tf = sender as? UITextField, tf.markedTextRange == nil, let text = tf.text {
            if !text.isEmpty {
                if step == 1 {
                    titleTwo.text = "请设置华涛交易密码，用于支付验证"
                    titleTwo.textColor = .black
                }
                switch tf {
                case tf1:
                    tf2.text = ""
                    tf3.text = ""
                    tf4.text = ""
                    tf5.text = ""
                    tf6.text = ""
                    tf2.becomeFirstResponder()
                case tf2:
                    tf3.text = ""
                    tf4.text = ""
                    tf5.text = ""
                    tf6.text = ""
                    tf3.becomeFirstResponder()
                case tf3:
                    tf4.text = ""
                    tf5.text = ""
                    tf6.text = ""
                    tf4.becomeFirstResponder()
                case tf4:
                    tf5.text = ""
                    tf6.text = ""
                    tf5.becomeFirstResponder()
                case tf5:
                    tf6.text = ""
                    tf6.becomeFirstResponder()
                case tf6:
                    // 填写完成，进行验证
                    checkPassword()
                default:
                    break
                }
            }
        }
    }
    
    func checkPassword() {
        guard let text1 = tf1.text, !text1.isEmpty,
              let text2 = tf2.text, !text2.isEmpty,
              let text3 = tf3.text, !text3.isEmpty,
              let text4 = tf4.text, !text4.isEmpty,
              let text5 = tf5.text, !text5.isEmpty,
              let text6 = tf6.text, !text6.isEmpty else {
            clearInput()
            toast(message: "请输入6位数字密码")
            return
        }
        let allNum = "0123456789"
        guard allNum.contains(text1),
              allNum.contains(text2),
              allNum.contains(text3),
              allNum.contains(text4),
              allNum.contains(text5),
              allNum.contains(text6) else {
            clearInput()
            toast(message: "交易密码仅支持数字")
            return
        }
        
        if step == 1 {
            // 进入再次输入步骤
            step = 2
            titleTwo.text = "再次填写以确认"
            titleTwo.textColor = .black
            pwdOne = text1 + text2 + text3 + text4 + text5 + text6
            completeBtn.isHidden = false
            completeBtn.drawGradient(start: .ss_dd, end: .ss_dd, size: CGSize(width: 160, height: 44), direction: .l2r)
            completeBtn.isUserInteractionEnabled = false
            clearInput()
        } else {
            // 进行密码验证
            pwdTwo = text1 + text2 + text3 + text4 + text5 + text6
            completeBtn.drawThemeGradient(CGSize(width: 160, height: 44))
            completeBtn.isUserInteractionEnabled = true
            view.endEditing(true)
        }
        
    }
    
    @IBAction func toComplete(_ sender: Any) {
        if pwdOne != pwdTwo {
            step = 1
            clearInput()
            titleTwo.textColor = .hex("ef3131")
            titleTwo.text = "两次密码输入不一致"
            completeBtn.isHidden = true
            completeBtn.isUserInteractionEnabled = false
            return
        }
        
        view.ss.showHUDLoading()
        HttpApi.Task.putTradePassword(tradePassword: pwdOne, confirmPassword: pwdTwo).done { [weak self] _ in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.globalToast(message: "设置成功")
                self?.completeBlock?()
                self?.back()
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.toast(message: error.localizedDescription)
            }
        }
    }
    
}

extension SetPasswordViewController: SSTextFieldDelegate {
    
    func textFieldDidDeleteBackward(_ textField: SSTextField) {
        // 删除字符
        switch textField {
        case tf6:
            tf5.becomeFirstResponder()
        case tf5:
            tf4.becomeFirstResponder()
        case tf4:
            tf3.becomeFirstResponder()
        case tf3:
            tf2.becomeFirstResponder()
        case tf2:
            tf1.becomeFirstResponder()
        default:
            break
        }
    }
}
