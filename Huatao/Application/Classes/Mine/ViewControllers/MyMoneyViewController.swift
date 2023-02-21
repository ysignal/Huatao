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
        
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func buildUI() {
        fakeNav.title = "余额"
        fakeNav.backgroundColor = .clear
        
        moneyLabel.text = "\(APP.userInfo.money)"
        
        view.backgroundColor = .ss_f6
        
        cardView.addGesture(.tap) { tap in
            if tap.state == .ended {
                let vc = BankCardViewController.from(sb: .mine)
                self.go(vc)
            }
        }
        
        detailStack.addGesture(.tap) { tap in
            if tap.state == .ended {
                let vc = MoneyHistoryViewController.from(sb: .mine)
                self.go(vc)
            }
        }
    }

    @IBAction func toWithdraw(_ sender: Any) {
        
    }
}
