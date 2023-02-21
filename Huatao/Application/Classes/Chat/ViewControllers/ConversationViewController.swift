//
//  ConversationViewController.swift
//  Huatao
//
//  Created on 2023/2/20.
//  
	

import UIKit

class ConversationViewController: RCConversationViewController {
    
    var fakeNav: SSNavigationBar = SSNavigationBar()
    
    lazy var moreBtn: SSButton = {
        let btn = SSButton(type: .custom)
        btn.image = UIImage(named: "ic_find_more")?.color(.hex("666666"))
        return btn
    }()

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
        
        fakeNav.addSubview(moreBtn)
        moreBtn.snp.makeConstraints { make in
            make.width.equalTo(30)
            make.height.equalTo(24)
            make.right.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-10)
        }
        moreBtn.addTarget(self, action: #selector(toMore), for: .touchUpInside)
        
        enableNewComingMessageIcon = true
        RCKitConfig.default().ui.globalMessagePortraitSize = CGSize(width: 36, height: 36)
        
        
        navigationController?.navRemove([SelectUserViewController.self])
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
    
    @objc func toMore() {
        switch conversationType {
        case .ConversationType_PRIVATE:
            let vc = UserDetailViewController.from(sb: .chat)
            vc.userId = targetId.intValue
            go(vc)
        case .ConversationType_DISCUSSION, .ConversationType_GROUP, .ConversationType_ULTRAGROUP:
            let vc = GroupSettingViewController.from(sb: .chat)
            vc.teamId = targetId.intValue
            go(vc)
        default:
            break
        }
    }

}
