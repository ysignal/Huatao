//
//  AddresssBookCell.swift
//  Huatao
//
//  Created by lgvae on 2023/2/11.
//

import UIKit

class AddressBookCell: UITableViewCell{
    
   lazy var headImageView: UIImageView = {
        
        let headImnageView = UIImageView()
    
        headImnageView.backgroundColor = UIColor.red
        
        return headImnageView
    }()
    
    lazy var nickName: UILabel = {
        
        let nickName = UILabel(text: "夜色朦胧", textColor: .hex("333333"), textFont: UIFont.systemFont(ofSize: 16))
        
        return nickName
        
    }()
    
    
    
   lazy var lineView: UIView = {
        
        let lineView = UIView(backgroundColor: .hex("EEEEEE"))
        
        return lineView
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        creatUI()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        
        
    
    }
    
    func creatUI(){
    
        contentView.addSubview(headImageView)
        
        headImageView.snp.makeConstraints { make in
            
            make.width.height.equalTo(38)
            
            make.centerY.equalTo(contentView)
            
            make.left.equalTo(contentView).offset(12)
        }
        
        contentView.addSubview(nickName)
        
        nickName.snp.makeConstraints { make in
            
            make.left.equalTo(headImageView.snp.right).offset(8)
            
            make.centerY.equalTo(contentView)
            
            make.right.equalTo(contentView.snp.right).offset(-10)

        }
        
        
        contentView.addSubview(lineView)
        
        lineView.snp.makeConstraints { make in
            
            make.left.equalTo(58)
            
            make.bottom.equalTo(contentView)
            
            make.height.equalTo(1)
            
            make.right.equalTo(contentView)
        }
    }
    
}
