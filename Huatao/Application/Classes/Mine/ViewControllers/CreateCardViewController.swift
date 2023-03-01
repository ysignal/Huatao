//
//  CreateCardViewController.swift
//  Huatao
//
//  Created on 2023/3/1.
//  
	

import UIKit

class CreateCardViewController: BaseViewController {
    
    
    @IBOutlet weak var bindBtn: UIButton!
    
    var completeBlock: NoneBlock?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func buildUI() {
        fakeNav.title = "绑定银行卡"
        
        
    }
    
    @IBAction func toBind(_ sender: Any) {
        
    }

}
