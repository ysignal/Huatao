//
//  SearchFriendViewController.swift
//  Huatao
//
//  Created on 2023/2/17.
//  
	

import UIKit

class SearchFriendViewController: BaseViewController {
    
    @IBOutlet weak var mobileTF: UITextField!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var codeBtn: SSButton!

    lazy var searchBtn: SSButton = {
        let btn = SSButton().loadOption([.cornerRadius(4), .border(1, .hex("ffb300")), .font(.ss_regular(size: 14)), .title("查找"), .titleColor(.white)])
        btn.drawGradient(start: .hex("ffa300"), end: .hex("ff8100"), size: CGSize(width: 50, height: 26))
        return btn
    }()
    
    var mobile: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func buildUI() {
        fakeNav.title = "添加好友"
        
        fakeNav.addSubview(searchBtn)
        searchBtn.snp.makeConstraints { make in
            make.width.equalTo(50)
            make.height.equalTo(26)
            make.right.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-9)
        }
        searchBtn.addTarget(self, action: #selector(toSearch), for: .touchUpInside)
        
        
    }
    
    @IBAction func textFieldChanged(_ sender: Any) {
        if mobileTF.markedTextRange == nil, let text = mobileTF.text {
            mobile = text
        }
    }
    
    @objc func toSearch() {
        mobileTF.resignFirstResponder()
        if mobile.isEmpty {
            toast(message: "请输入手机号")
            return
        }
        view.ss.showHUDLoading()
        HttpApi.Chat.getSearchFriend(mobile: mobile).done { [weak self] data in
            let model = data.kj.model(FriendDetailModel.self)
            SSMainAsync {
                self?.view.ss.hideHUD()
                let vc = AddFriendViewController.from(sb: .chat)
                vc.userId = model.userId
                self?.go(vc)
            }
        }.catch { [weak self] errpr in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.showErrorView()
            }
        }
    }

    @IBAction func toShowCode(_ sender: Any) {
        mobileTF.resignFirstResponder()
        let vc = MyCodeViewController.from(sb: .chat)
        go(vc)
    }
    
    func showErrorView() {
        errorView.alpha = 1
        errorView.isHidden = false
        SSMainAsync(after: 2) {
            UIView.animate(withDuration: 0.15) {
                self.errorView.alpha = 0
            } completion: { finished in
                self.errorView.isHidden = true
            }
        }
    }
}

extension SearchFriendViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        toSearch()
        return true
    }
    
}
