//
//  ChatNoticeUnreadCell.swift
//  Huatao
//
//  Created by lgvae on 2023/2/14.
//

import UIKit


class ChatNoticeUnreadCell: ChatNoticeCell {
    
    var fuseActionBlock: (() -> Void)? = nil
    
    var agreeActionBlock: (() -> Void)? = nil
    
    lazy var fuseButton: UIButton = {
        
        let button = UIButton(title: "拒绝", titleColor: .hex("FF8100"), titleFont: UIFont.systemFont(ofSize: 14), backgroundColor: UIColor.white, cornerRadius: 4)
        
        button.borderColor = .hex("FF8100")
        
        button.borderWidth = 1
        
        return button
    }()
    
    lazy var agreeButton: UIButton = {
        
        let button = UIButton(title: "同意", titleColor: UIColor.white, titleFont: UIFont.systemFont(ofSize: 14), backgroundColor: .hex("FF8100"), cornerRadius: 4)
        
        return button
        
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        stattus.isHidden = true
        
        contentView.addSubview(fuseButton)
        
        contentView.addSubview(agreeButton)
        
        
        agreeButton.snp.makeConstraints { make in
            make.right.equalTo(-12)
            make.centerY.equalTo(contentView.snp.centerY)
            make.width.equalTo(50)
            make.height.equalTo(26)
        }
        
        fuseButton.snp.makeConstraints { make in
            make.right.equalTo(agreeButton.snp.left).offset(-8)
            make.centerY.equalTo(contentView.snp.centerY)
            make.width.equalTo(50)
            make.height.equalTo(26)
        }
        
        fuseButton.addTarget(self, action: #selector(fuseAction), for: .touchUpInside)
        
        agreeButton.addTarget(self, action: #selector(agreeAction), for: .touchUpInside)
    }
    
    
   @objc func fuseAction(){
        
        fuseActionBlock?()
    }
    
    @objc func agreeAction(){
         
         agreeActionBlock?()
     }
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        
    }
}
