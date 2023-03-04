//
//  CreateCardViewController.swift
//  Huatao
//
//  Created on 2023/3/1.
//  
	

import UIKit

class CreateCardViewController: BaseViewController {
    
    @IBOutlet weak var cardTF: UITextField!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var numberTF: UITextField!
    @IBOutlet weak var bindBtn: UIButton!
    
    var card: String = ""
    var name: String = ""
    var number: String = ""
    
    /// 该回调闭包将用来判断页面跳转来源，如果需要额外调用闭包需要新增闭包或者修改此闭包的使用方式
    var completeBlock: NoneBlock?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func buildUI() {
        fakeNav.title = "绑定银行卡"
        
        cardTF.delegate = self
        nameTF.delegate = self
        numberTF.delegate = self
    }
    
    func checkButtonState() {
        let isEnabled = !card.isEmpty && !name.isEmpty && !number.isEmpty
        bindBtn.isUserInteractionEnabled = isEnabled
        if isEnabled {
            bindBtn.drawThemeGradient(CGSize(width: SS.w - 50, height: 44))
        } else {
            bindBtn.drawGradient(start: .ss_dd, end: .ss_dd, size: CGSize(width: SS.w - 50, height: 44))
        }
    }
    
    @IBAction func textFieldChanged(_ sender: UITextField) {
        if sender.markedTextRange == nil, let text = sender.text {
            switch sender {
            case nameTF:
                name = text
            case cardTF:
                card = text
            case numberTF:
                number = text
            default:
                break
            }
        }
        checkButtonState()
    }
    
    @IBAction func toBind(_ sender: Any) {
        view.endEditing(true)
        guard card.isNumberStr() else {
            toast(message: "银行卡号只支持纯数字")
            return
        }
        view.ss.showHUDLoading()
        HttpApi.Mine.postAddBank(name: name, cardNo: card, cardId: number).done { [weak self] _ in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.globalToast(message: "添加成功")
                self?.completeBlock?()
                // 根据completeBlock是否存在判断来源
                if self?.completeBlock != nil {
                    self?.back()
                } else {
                    let vc = BankCardViewController.from(sb: .mine)
                    self?.go(vc)
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

extension CreateCardViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == cardTF {
            nameTF.becomeFirstResponder()
        } else if textField == nameTF {
            numberTF.becomeFirstResponder()
        } else {
            view.endEditing(true)
        }
        return true
    }
    
}
