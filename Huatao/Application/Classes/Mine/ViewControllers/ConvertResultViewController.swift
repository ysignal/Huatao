//
//  ConvertResultViewController.swift
//  Huatao
//
//  Created by minse on 2023/1/29.
//

import UIKit

class ConvertResultViewController: BaseViewController {
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var resultTitle: UILabel!
    
    var changedBlock: NoneBlock?

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func buildUI() {
        fakeNav.title = "兑换结果"
        fakeNav.leftButtonHandler = {
            self.backAction()
        }
        
        backBtn.drawGradient(start: .hex("ffa300"), end: .hex("ff8100"), size: CGSize(width: 220, height: 40), direction: .l2r)
    }
    
    @IBAction func toBack(_ sender: Any) {
        backAction()
    }
    
    private func backAction() {
        changedBlock?()
        back(svc: MyWalletViewController.self)
    }
}
