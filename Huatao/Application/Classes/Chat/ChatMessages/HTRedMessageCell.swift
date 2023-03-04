//
//  HTRedMessageCell.swift
//  Huatao
//
//  Created on 2023/3/3.
//  
	

import Foundation

class HTRedMessageCell: RCMessageCell {
    
    lazy var redView: UIView = {
        let v = UIView(backgroundColor: .white, cornerRadius: 4)
        v.cornerRadius = 4
        return v
    }()
    
    lazy var redBackground: UIView = {
        let v = UIView(backgroundColor: .hex("ffa846"))
        return v
    }()
    
    lazy var redType: UILabel = {
        let lb = UILabel(text: nil, textColor: .hex("999999"), textFont: .ss_regular(size: 10))
        return lb
    }()
    
    lazy var redImage: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "ic_red_middle"))
        return iv
    }()
    
    lazy var redDesc: UILabel = {
        let lb = UILabel(text: nil, textColor: .white, textFont: .ss_regular(size: 16))
        return lb
    }()
    
    override init!(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        buildUI()
    }
    
    func buildUI() {
        // 添加视图
        messageContentView.addSubview(redView)
        if messageDirection == .MessageDirection_SEND {
            redView.snp.makeConstraints { make in
                make.top.right.equalToSuperview()
                make.width.equalTo(230)
                make.height.equalTo(90)
            }
        } else {
            redView.snp.makeConstraints { make in
                make.top.left.equalToSuperview()
                make.width.equalTo(230)
                make.height.equalTo(90)
            }
        }
        
        redView.addSubview(redBackground)
        redBackground.snp.makeConstraints { make in
            redBackground.snp.makeConstraints { make in
                make.left.top.right.equalToSuperview()
                make.height.equalTo(70)
            }
        }
        
        redView.addSubview(redType)
        redType.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(6)
            make.bottom.equalToSuperview()
            make.top.equalTo(redBackground.snp.bottom)
        }
        
        redBackground.addSubview(redImage)
        redImage.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
        }
        
        redBackground.addSubview(redDesc)
        redDesc.snp.makeConstraints { make in
            make.left.equalTo(redImage.snp.right).offset(8)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-12)
        }
    }
    
    override class func size(for model: RCMessageModel!, withCollectionViewWidth collectionViewWidth: CGFloat, referenceExtraHeight extraHeight: CGFloat) -> CGSize {
        // 时间轴
        SS.log(extraHeight)
        return CGSize(width: collectionViewWidth, height: 90 + extraHeight)
    }
    
    override func setDataModel(_ model: RCMessageModel!) {
        super.setDataModel(model)
        statusContentView.isHidden = true
        isDisplayReadStatus = false
        allowsSelection = false
        // 设置显示区域大小
        messageContentView.contentSize = CGSize(width: 230, height: 90)
        
        if let redContent = model.content as? HTRedMessage {
            switch redContent.model?.type {
            case 0:
                redType.text = "银豆红包"
            case 1:
                redType.text = "现金红包"
            default:
                break
            }
            redDesc.text = redContent.model?.message
        }
    }
    
}
