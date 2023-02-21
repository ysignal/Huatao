//
//  AddresssBookCell.swift
//  Huatao
//
//  Created by lgvae on 2023/2/11.
//

import UIKit

class AddressBookCell: UITableViewCell{

    lazy var groupImageView: GroupImageView = {
        return GroupImageView.fromNib()
    }()
    
    lazy var nickName: UILabel = {
        let nickName = UILabel(text: "夜色朦胧", textColor: .hex("333333"), textFont: .ss_regular(size: 16))
        return nickName
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        creatUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        creatUI()
    }

    func creatUI(){
        backgroundColor = .white
        contentView.addSubview(groupImageView)
        groupImageView.snp.makeConstraints { make in
            make.width.height.equalTo(48)
            make.centerY.equalToSuperview()
            make.left.equalTo(contentView).offset(12)
        }
        
        contentView.addSubview(nickName)
        nickName.snp.makeConstraints { make in
            make.left.equalTo(groupImageView.snp.right).offset(8)
            make.centerY.equalToSuperview()
            make.right.equalTo(contentView.snp.right).offset(-10)
        }
    }
    
    func config(item: TeamListItem) {
        nickName.text = item.title
        let images = item.listAvatar.compactMap({ $0.avatar })
        groupImageView.config(images: images, cornerRadius: 18)
    }
    
}
