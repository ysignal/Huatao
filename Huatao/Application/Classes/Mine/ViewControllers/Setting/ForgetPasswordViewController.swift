//
//  ForgetPasswordViewController.swift
//  Huatao
//
//  Created on 2023/1/24.
//

import UIKit

class ForgetPasswordViewController: BaseViewController {

    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var cardTF: UITextField!
    @IBOutlet weak var nextBtn: UIButton!
    
    var name: String = ""
    var card: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func buildUI() {
        nameTF.delegate = self
        cardTF.delegate = self
    }
    
    func checkButtonStatus() {
        let isEnabled = !name.isEmpty && !card.isEmpty
        nextBtn.isUserInteractionEnabled = isEnabled
        if isEnabled {
            nextBtn.drawThemeGradient(CGSize(width: 160, height: 44))
        } else {
            nextBtn.drawGradient(start: .ss_dd, end: .ss_dd, size: CGSize(width: 160, height: 44))
        }
    }
    
    @IBAction func textFieldChanged(_ sender: UITextField) {
        if sender.markedTextRange == nil, let text = sender.text {
            switch sender {
            case nameTF:
                name = text
            case cardTF:
                card = text
            default:
                break
            }
        }
        checkButtonStatus()
    }
    

    @IBAction func toNext(_ sender: Any) {
        view.ss.showHUDLoading()
        HttpApi.Mine.getEditPasswordAuth(realName: name, cardId: card).done { [weak self] data in
            SSMainAsync {
                self?.view.ss.hideHUD()
                let authStatus = data["auth_status"] as? Int ?? 0
                if authStatus == 1 {
                    // 认证通过
                    let vc = SetPasswordViewController.from(sb: .task)
                    vc.type = .edit
                    self?.go(vc)
                } else {
                    self?.toast(message: "认证未通过")
                }
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.toast(message: error.localizedDescription)
            }
        }
    }
}

extension ForgetPasswordViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTF {
            cardTF.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
}
