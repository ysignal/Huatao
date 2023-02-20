//
//  ApplyFriendViewController.swift
//  Huatao
//
//  Created on 2023/2/20.
//  
	

import UIKit

class ApplyFriendViewController: BaseViewController {
    
    @IBOutlet weak var textView: SSTextView!
    @IBOutlet weak var renameTF: UITextField!
    @IBOutlet weak var sendBtn: UIButton!
    
    var userId: Int = 0
    var name: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func buildUI() {
        fakeNav.title = "申请添加好友"
        
        textView.text = APP.lastApplyContent
        renameTF.text = name
        
        sendBtn.drawThemeGradient(CGSize(width: SS.w - 24, height: 40))
    }

    @IBAction func toSend(_ sender: Any) {
        view.endEditing(true)
        guard let text = textView.text, !text.isEmpty else {
            toast(message: "请输入申请内容")
            return
        }
        let rename = renameTF.text ?? name
        
        view.ss.showHUDLoading()
        HttpApi.Chat.postAddFriend(userId: userId, desc: text, name: rename).done { [weak self] _ in
            SSMainAsync {
                self?.view.ss.hideHUD()
                SS.keyWindow?.toast(message: "申请成功")
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
