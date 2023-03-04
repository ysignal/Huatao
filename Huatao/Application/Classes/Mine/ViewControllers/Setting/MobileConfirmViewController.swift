//
//  MobileConfirmViewController.swift
//  Huatao
//
//  Created on 2023/3/2.
//  
	

import UIKit

class MobileConfirmViewController: BaseViewController {
    
    @IBOutlet weak var mobileLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!

    var completeBlock: NoneBlock?
    
    var code: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func buildUI() {
        view.backgroundColor = .ss_f6
        fakeNav.title = "绑定手机"
        
        let mobileValue = APP.userInfo.mobile.isEmpty ? "" : (APP.userInfo.mobile.prefix(3) + "****" + APP.userInfo.mobile.suffix(4))
        mobileLabel.text = mobileValue
        
        doneButton.drawThemeGradient(CGSize(width: SS.w - 48, height: 44))
    }
    
    @IBAction func toNext(_ sender: Any) {
        if TimerManager.isCountDown() {
            // 已经发送了验证码
            let vc = MobileChangeViewController.from(sb: .mine)
            vc.completeBlock = completeBlock
            go(vc)
        } else {
            view.ss.showHUDLoading()
            HttpApi.Login.sendSms(mobile: APP.userInfo.mobile, sign: 4).done { [weak self] () in
                SSMainAsync {
                    TimerManager.phoneCount = 60
                    TimerManager.countDown(handler: nil)
                    self?.view.ss.hideHUD()
                    let vc = MobileChangeViewController.from(sb: .mine)
                    vc.completeBlock = self?.completeBlock
                    self?.go(vc)
                }
            }.catch { [weak self] error in
                SSMainAsync {
                    self?.view.ss.hideHUD()
                    self?.toast(message: error.localizedDescription)
                }
            }
        }
    }
    
}
