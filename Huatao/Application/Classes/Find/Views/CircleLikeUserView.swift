//
//  CircleLikeUserView.swift
//  Huatao
//
//  Created on 2023/2/16.
//  
	

import UIKit

class CircleLikeUserView: UIView {
    
    lazy var countLabel: UILabel = {
        return UILabel(text: "", textColor: .hex("999999"), textFont: .ss_regular(size: 12))
    }()
    
    func config(data: [LikeListItem]) {
        removeAllSubviews()
        countLabel.text = "等\(data.count)人赞过"
        
        for (i, item) in data.reversed().enumerated() {
            let offset = CGFloat(data.count - i - 1) * 14
            let iv = UIImageView()
            iv.contentMode = .scaleAspectFill
            iv.loadOption([.border(1, .white), .cornerRadius(12)])
            addSubview(iv)
            iv.snp.makeConstraints { make in
                make.width.height.equalTo(24)
                make.centerY.equalToSuperview()
                make.left.equalToSuperview().offset(offset)
            }
            iv.ss_setImage(item.userAvatar, placeholder: SSImage.userDefault)
        }
        
        let maxOffset = 10 + CGFloat(data.count) * 14
        addSubview(countLabel)
        countLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(maxOffset + 8)
            make.centerY.equalToSuperview()
        }
    }

}
