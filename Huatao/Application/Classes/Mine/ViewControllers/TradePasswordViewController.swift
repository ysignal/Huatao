//
//  TradePasswordViewController.swift
//  Huatao
//
//  Created on 2023/1/24.
//

import UIKit

class TradePasswordViewController: BaseViewController {
    
    @IBOutlet weak var oldTF: UITextField!
    @IBOutlet weak var newTF: UITextField!
    @IBOutlet weak var confirmTF: UITextField!
    
    @IBOutlet weak var newSecret: SSButton!
    @IBOutlet weak var confirmSecret: SSButton!
    @IBOutlet weak var forgetBtn: SSButton!
    
    @IBOutlet weak var confirmBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func buildUI() {
        view.backgroundColor = .hex("f6f6f6")
        fakeNav.title = "支付密码"
        
        newSecret.image = UIImage(named: "ic_secret_close")
        newSecret.selectedImage = UIImage(named: "ic_secret_open")
        confirmSecret.image = UIImage(named: "ic_secret_close")
        confirmSecret.selectedImage = UIImage(named: "ic_secret_open")
    }
    
    func checkButtonStatus() {
        var isEnabled = true
        if let text = oldTF.text, text.count < 6 {
            isEnabled = false
        }
        if let text = newTF.text, text.count < 6 {
            isEnabled = false
        }
        if let text = confirmTF.text, text.count < 6 {
            isEnabled = false
        }
        if isEnabled {
            confirmBtn.drawThemeGradient(CGSize(width: SS.w - 24, height: 40))
            confirmBtn.isUserInteractionEnabled = true
        } else {
            confirmBtn.drawGradient(start: .hex("dddddd"), end: .hex("dddddd"), size: CGSize(width: SS.w - 24, height: 40))
            confirmBtn.isUserInteractionEnabled = false
        }
    }
    
    @IBAction func textFieldEditingChanged(_ sender: Any) {
        if let tf = sender as? UITextField, tf.markedTextRange == nil {
            checkButtonStatus()
        }
    }
    
    @IBAction func newSecretChange(_ sender: Any) {
        newSecret.isSelected.toggle()
        newTF.isSecureTextEntry = !newSecret.isSelected
    }
    
    @IBAction func confirmSecretChange(_ sender: Any) {
        confirmSecret.isSelected.toggle()
        confirmTF.isSecureTextEntry = !confirmSecret.isSelected
    }
    
    @IBAction func toForget(_ sender: Any) {
        let vc = ForgetPasswordViewController.from(sb: .mine)
        go(vc)
    }
    
    @IBAction func toConfirm(_ sender: Any) {
        view.ss.showHUDLoading()
        
    }
    
}
