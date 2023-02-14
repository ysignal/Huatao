//
//  AboutViewController.swift
//  Huatao
//
//  Created on 2023/1/27.
//

import UIKit

class AboutViewController: BaseViewController {
    
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var newLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func buildUI() {
        view.backgroundColor = .hex("f6f6f6")
        fakeNav.title = "关于华涛生活"
        
        versionLabel.text = SS.versionS
    }

}
