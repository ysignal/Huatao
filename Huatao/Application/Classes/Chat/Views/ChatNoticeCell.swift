//
//  ChatNoticeCell.swift
//  Huatao
//
//  Created by lgvae on 2023/2/14.
//

import UIKit

class ChatNoticeCell: UITableViewCell {
    
    lazy var headImageView: UIImageView = {
         
         let headImnageView = UIImageView()
     
         headImnageView.backgroundColor = UIColor.red
         
         return headImnageView
     }()
     
     lazy var nickName: UILabel = {
         
         let nickName = UILabel(text: "夜色朦胧", textColor: .hex("333333"), textFont: UIFont.systemFont(ofSize: 16))
         
         return nickName
         
     }()
     
    
    lazy var remark: UILabel = {
        
        let remark = UILabel(text: "备注信息", textColor: .hex("999999"), textFont: UIFont.systemFont(ofSize: 12))
        
        return remark
        
    }()
    
    lazy var stattus: UILabel = {
        
        let stattus = UILabel(text: "已添加/拒绝", textColor: .hex("999999"), textFont: UIFont.systemFont(ofSize: 12))
        
        stattus.textAlignment = .right
        
        return stattus
        
    }()
     
     
    lazy var lineView: UIView = {
         
         let lineView = UIView(backgroundColor: .hex("EEEEEE"))
         
         return lineView
     }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(headImageView)
        
        contentView.addSubview(nickName)
        
        contentView.addSubview(remark)
        
        contentView.addSubview(lineView)
        
        contentView.addSubview(stattus)
        
        
        headImageView.snp.makeConstraints { make in
            
            make.centerY.equalTo(contentView)
            make.left.equalTo(12)
            make.width.height.equalTo(38)
        }
        nickName.snp.makeConstraints { make in
            make.left.equalTo(headImageView.snp.right).offset(8)
            make.bottom.equalTo(headImageView.snp.centerY).offset(4)
            make.height.equalTo(20)
        }
        
        remark.snp.makeConstraints { make in
        
            make.left.equalTo(headImageView.snp.right).offset(8)
            make.top.equalTo(nickName.snp.bottom)
            make.height.equalTo(16)
        }
        
        stattus.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.right.equalTo(contentView.snp.right).offset(-12)
            make.centerY.equalTo(contentView)
        }
        
        lineView.snp.makeConstraints { make in
            
            make.left.equalTo(58)
            
            make.bottom.equalTo(contentView)
            
            make.height.equalTo(1)
            
            make.right.equalTo(contentView)
        }
        
    }
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        
    }
}
