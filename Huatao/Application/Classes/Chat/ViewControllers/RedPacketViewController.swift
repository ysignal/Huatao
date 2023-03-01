//
//  RedPacketViewController.swift
//  Huatao
//
//  Created on 2023/2/23.
//  
	

import UIKit

class RedPacketViewController: BaseViewController {
    
    
    
    var targetId: String = ""
    
    var conversationType: RCConversationType = .ConversationType_PRIVATE

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func buildUI() {
        fakeNav.title = "红包"
        view.backgroundColor = .ss_f6
        
        
    }

}
