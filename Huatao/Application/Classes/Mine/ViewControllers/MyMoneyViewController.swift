//
//  MyMoneyViewController.swift
//  Huatao
//
//  Created on 2023/2/17.
//  
	

import UIKit

class MyMoneyViewController: BaseViewController {
    
    @IBOutlet weak var moneyLabel: UILabel!
    @IBOutlet weak var detailStack: UIStackView!
    @IBOutlet weak var withdrawBtn: UIButton!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var cardLabel: UILabel!
    
    /// 提现用的卡号
    private var cardNo: String = "" {
        didSet {
            cardLabel.text = cardNo
        }
    }
        
    private var list: [BankCardItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestData()
    }
    
    override func buildUI() {
        fakeNav.title = "余额"
        fakeNav.backgroundColor = .clear
        
        view.backgroundColor = .ss_f6
        
        cardView.addGesture(.tap) { tap in
            if tap.state == .ended {
                if self.cardNo.isEmpty {
                    // 如果未绑定过银行卡, 前往绑卡说明
                    let vc = CardDescriptionViewController.from(sb: .mine)
                    self.go(vc)
                } else {
                    let vc = BankCardViewController.from(sb: .mine)
                    self.go(vc)
                }
            }
        }
        
        detailStack.addGesture(.tap) { tap in
            if tap.state == .ended {
                let vc = MoneyHistoryViewController.from(sb: .mine)
                self.go(vc)
            }
        }
        
        updateMoney()
    }
    
    func requestData() {
        view.ss.showHUDLoading()
        HttpApi.Mine.getUserBankList().done { [weak self] data in
            guard let weakSelf = self else { return }
            let listModel = data.kj.model(ListModel<BankCardItem>.self)
            weakSelf.list = listModel.list
            SSMainAsync {
                weakSelf.view.ss.hideHUD()
                weakSelf.cardNo = listModel.list.first?.cardNo ?? ""
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.view.ss.hideHUD()
            }
        }
    }
    
    func updateMoney() {
        moneyLabel.text = "\(APP.userInfo.money)"
    }

    @IBAction func toWithdraw(_ sender: Any) {
        if cardNo.isEmpty {
            toast(message: "请先选择提现账号")
            return
        }
        view.ss.showHUDLoading()
        HttpApi.Mine.postMoneyWithdraw(cardNo: cardNo).done { [weak self] _ in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.toast(message: "提现成功")
                APP.updateUserInfo {
                    self?.updateMoney()
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
