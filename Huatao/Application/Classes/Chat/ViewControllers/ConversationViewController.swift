//
//  ConversationViewController.swift
//  Huatao
//
//  Created on 2023/2/20.
//  
	

import UIKit

class ConversationViewController: RCConversationViewController {
    
    var fakeNav: SSNavigationBar = SSNavigationBar()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        buildUI()
    }
    
    func buildUI() {
        view.addSubview(fakeNav)
        fakeNav.snp.makeConstraints({
            $0.left.right.top.equalToSuperview()
            $0.height.equalTo(SS.statusWithNavBarHeight)
        })
        fakeNav.leftButtonHandler = {
            self.back()
        }
        fakeNav.leftImage = SSImage.back
        
        enableNewComingMessageIcon = true
        RCKitConfig.default().ui.globalMessagePortraitSize = CGSize(width: 36, height: 36)
        
    }
    
    override func registerCustomCellsAndMessages() {
        super.registerCustomCellsAndMessages()
    }
    
    override func willDisplayMessageCell(_ cell: RCMessageBaseCell!, at indexPath: IndexPath!) {
        if let msgCell = cell as? RCMessageCell {
            msgCell.portraitImageView.layer.cornerRadius = 14
            msgCell.portraitImageView.contentMode = .scaleAspectFill
            if cell.model.senderUserId == "\(APP.loginData.userId)" {
                msgCell.portraitImageView.ss_setImage(APP.userInfo.avatar, placeholder: SSImage.userDefault)
            }
        }
    }

}
