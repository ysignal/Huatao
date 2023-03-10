//
//  NameCertViewController.swift
//  Huatao
//
//  Created on 2023/2/28.
//  
	

import UIKit

class NameCertViewController: BaseViewController {
    
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var cardTF: UITextField!
    
    @IBOutlet weak var doneBtn: UIButton!
    
    var completeBlock: NoneBlock?
    
    var certifyId: String = ""
    
    var name: String = ""
    
    var card: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameTF.text = "杨茗智"
        cardTF.text = "440882199201094412"
    }
    
    override func buildUI() {
        fakeNav.title = "实名认证"
        
        doneBtn.drawThemeGradient(CGSize(width: SS.w - 24, height: 40))
    }
    
    @IBAction func toCert(_ sender: Any) {
        guard let name = nameTF.text, !name.isEmpty else {
            toast(message: "姓名不能为空")
            return
        }
        guard let card = cardTF.text, !card.isEmpty else {
            toast(message: "身份证号不能为空")
            return
        }
        self.name = name
        self.card = card
        view.ss.showHUDLoading()
        let metaInfo = fixedDict(AliyunFaceManager.getMetaInfo())
        HttpApi.Task.postFaceAuth(certName: name, certNo: card, metaInfo: metaInfo).done { [weak self] certifyId in
            SS.log(certifyId)
            self?.certifyId = certifyId
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.toVerify()
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.toast(message: error.localizedDescription)
            }
        }
    }
    
    func toVerify() {
        let params: [String: Any] = ["currentCtr": self]
        AliyunFaceManager.verify(with: certifyId, extParams: params) { [weak self] success, errorMsg in
            SSMainAsync {
                if success {
                    self?.uploadCertData()
                } else {
                    SS.log(errorMsg)
                }
            }
        }
    }
    
    func uploadCertData() {
        view.ss.showHUDLoading(text: "正在提交数据")
        HttpApi.Task.putCardAuth(realName: name, cardId: card).done { [weak self] _ in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.globalToast(message: "验证成功，请耐心等待审核")
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
    
    func fixedDict(_ data: [AnyHashable: Any]) -> String {
        return data.toJson() ?? ""
    }
    
}
