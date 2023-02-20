//
//  UserCircleCell.swift
//  Huatao
//
//  Created on 2023/2/17.
//  
	

import UIKit

class UserCircleCell: UITableViewCell {
    
    @IBOutlet weak var circleView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    func config(images: [String]) {
        circleView.removeAllSubviews()
        // 计算最多显示图片数量
        let maxCount = Int(floor((SS.w - 96) / 56))
        for (i, image) in images.enumerated() {
            if i < maxCount {
                let offset: CGFloat = CGFloat(i) * 56
                let iv = UIImageView()
                iv.contentMode = .scaleAspectFill
                iv.loadOption([.cornerRadius(4)])
                circleView.addSubview(iv)
                iv.ss_setImage(image, placeholder: SSImage.userDefault)
                iv.snp.makeConstraints { make in
                    make.right.equalToSuperview().offset(-offset)
                    make.width.height.equalTo(50)
                    make.centerY.equalToSuperview()
                }
            } else {
                break
            }
        }
        
        
    }

}
