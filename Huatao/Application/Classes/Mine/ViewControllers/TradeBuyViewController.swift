//
//  TradeBuyViewController.swift
//  Huatao
//
//  Created on 2023/1/22.
//

import UIKit

class TradeBuyViewController: BaseViewController {
    
    @IBOutlet weak var numberTF: UITextField!
    @IBOutlet weak var priceTF: UITextField!
    @IBOutlet weak var confirmBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func buildUI() {
        view.backgroundColor = .hex("f6f6f6")
        fakeNav.title = "买入金豆"
        
        confirmBtn.drawThemeGradient(CGSize(width: SS.w - 24, height: 40))
    }
    
    @IBAction func toConfirm(_ sender: Any) {
        guard let number = numberTF.text?.intValue, number > 0 else {
            toast(message: "请输入正确的金豆数量")
            return
        }
        if number % 10 > 0 {
            toast(message: "金豆数量必须为10的倍数")
            return
        }
        guard let price = priceTF.text?.floatValue, price > 0 else {
            toast(message: "请输入正确的金豆价格")
            return
        }
        SS.keyWindow?.ss.showHUDLoading()
        HttpApi.Mine.postGoldBuy(total: number, price: price).done { [weak self] _ in
            SSMainAsync {
                SS.keyWindow?.ss.hideHUD()
                SS.keyWindow?.toast(message: "发布成功")
                self?.back()
            }
        }.catch { error in
            SSMainAsync {
                SS.keyWindow?.ss.hideHUD()
                SS.keyWindow?.toast(message: error.localizedDescription)
            }
        }
    }
    
}
