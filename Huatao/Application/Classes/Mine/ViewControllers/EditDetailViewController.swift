//
//  EditDetailViewController.swift
//  Huatao
//
//  Created on 2023/2/20.
//  
	

import UIKit

class EditDetailViewController: BaseViewController {
    
    enum EditType {
    case name, job, sign
    }
    
    @IBOutlet weak var tfView: UIView!
    @IBOutlet weak var tfTitle: UILabel!
    @IBOutlet weak var contentTF: UITextField!
    
    @IBOutlet weak var tvView: UIView!
    @IBOutlet weak var signTV: SSTextView!
    @IBOutlet weak var countLabel: UILabel!
    
    var type: EditType = .name
    
    var sign: String = ""
    
    var content: String = ""
    
    var updateBlock: NoneBlock?

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func buildUI() {
        fakeNav.rightButton.title = "确定"
        fakeNav.rightButton.titleFont = UIFont.systemFont(ofSize: 14)
        fakeNav.rightButton.titleColor = .ss_theme
        fakeNav.rightButton.isHidden = false
        fakeNav.rightButton.snp.updateConstraints { make in
            make.width.equalTo(40)
        }
        fakeNav.rightButtonHandler = {
            self.view.endEditing(true)
            switch self.type {
            case .name:
                self.toUpdateName()
            case .job:
                self.toUpdateJob()
            case .sign:
                self.toUpdatePersonSign()
            }
        }
        
        contentTF.text = content
        signTV.text = sign
        signTV.delegate = self
        
        switch type {
        case .name:
            tfView.isHidden = false
            tvView.isHidden = true
            tfTitle.text = "昵称"
            fakeNav.title = "昵称"
            contentTF.maxLength = 10
            contentTF.placeholder = "请输入昵称"
        case .job:
            tfView.isHidden = false
            tvView.isHidden = true
            tfTitle.text = "职业"
            contentTF.maxLength = 20
            fakeNav.title = "职业"
            contentTF.placeholder = "请输入职业"
        case .sign:
            tfView.isHidden = true
            tvView.isHidden = false
            fakeNav.title = "个性签名"
            countLabel.text = "\(min(sign.count, 50))/50"
        }
        
    }
    
    func toUpdateName() {
        if content.isEmpty {
            toast(message: "昵称不能为空")
            return
        }
        SS.keyWindow?.ss.showHUDLoading()
        HttpApi.Mine.putMyName(name: content).done { [weak self] _ in
            SSMainAsync {
                SS.keyWindow?.ss.hideHUD()
                SS.keyWindow?.toast(message: "更新成功")
                self?.updateBlock?()
                self?.back()
            }
        }.catch { error in
            SSMainAsync {
                SS.keyWindow?.ss.hideHUD()
                SS.keyWindow?.toast(message: error.localizedDescription)
            }
        }
    }
    
    func toUpdateJob() {
        if content.isEmpty {
            toast(message: "职业不能为空")
            return
        }
        SS.keyWindow?.ss.showHUDLoading()
        HttpApi.Mine.putMyJobName(jobName: content).done { [weak self] _ in
            SSMainAsync {
                SS.keyWindow?.ss.hideHUD()
                SS.keyWindow?.toast(message: "更新成功")
                self?.updateBlock?()
                self?.back()
            }
        }.catch { error in
            SSMainAsync {
                SS.keyWindow?.ss.hideHUD()
                SS.keyWindow?.toast(message: error.localizedDescription)
            }
        }
    }
    
    func toUpdatePersonSign() {
        if sign.isEmpty {
            toast(message: "职业不能为空")
            return
        }
        SS.keyWindow?.ss.showHUDLoading()
        HttpApi.Mine.putMyPersonSign(personSign: sign).done { [weak self] _ in
            SSMainAsync {
                SS.keyWindow?.ss.hideHUD()
                SS.keyWindow?.toast(message: "更新成功")
                self?.updateBlock?()
                self?.back()
            }
        }.catch { error in
            SSMainAsync {
                SS.keyWindow?.ss.hideHUD()
                SS.keyWindow?.toast(message: error.localizedDescription)
            }
        }
    }
    
    @IBAction func textFieldChanged(_ sender: UITextField) {
        if sender.markedTextRange == nil, let text = sender.text {
            content = text
        }
    }
    
}

extension EditDetailViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.markedTextRange == nil, let text = textView.text {
            sign = text
            countLabel.text = "\(min(text.count, 50))/50"
        }
    }
    
}
