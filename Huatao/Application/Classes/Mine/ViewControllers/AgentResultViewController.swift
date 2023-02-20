//
//  AgentResultViewController.swift
//  Huatao
//
//  Created on 2023/2/15.
//  
	

import UIKit

class AgentResultViewController: BaseViewController {

    @IBOutlet weak var backBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .hex("f6f6f6")
        
        fakeNav.title = "成为代理商"
        fakeNav.leftButtonHandler = {
            self.back(svc: MineViewController.self)
        }
        backBtn.drawThemeGradient(CGSize(width: SS.w - 24, height: 40))
    }
    
    @IBAction func toBack(_ sender: Any) {
        back(svc: MineViewController.self)
    }
    

}
