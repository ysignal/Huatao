//
//  SSNavigationBar.swift
//  SimpleSwift
//
//  Created by user on 2021/4/20.
//

import UIKit
import SnapKit

open class SSNavigationBar: UIView {
    open var statusBackground = UIView()
    open var leftButton = SSButton(type: .custom)
    open var titleLabel = UILabel(text: "", textColor: .hex("#222222"), textFont: .ss_medium(size: 16), textAlignment: .center)
    open var rightButton = SSButton(type: .custom)
    
    open var leftButtonHandler : (() -> ())?
    open var rightButtonHandler : (() -> ())?
    
    open var title: String {
        get { return titleLabel.text ?? "" }
        set { titleLabel.text = newValue }
    }
    
    open var titleColor: UIColor {
        get { return titleLabel.textColor }
        set { titleLabel.textColor = newValue }
    }
    
    open var leftImage: UIImage? {
        didSet {
            leftButton.setImage(leftImage, for: .normal)
        }
    }
    
    open override var backgroundColor: UIColor? {
        didSet {
            statusBackground.backgroundColor = backgroundColor
        }
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .white
        buildUI()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        buildUI()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = .white
        buildUI()
    }
    
    private func buildUI() {
        buildStatusBackground()
        buildLeftBtn()
        buildTitleLabel()
        buildRightButton()
    }
    
    private func buildStatusBackground() {
        clipsToBounds = false
        
        addSubview(statusBackground)
        statusBackground.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(-SS.statusBarHeight)
            make.height.equalTo(SS.statusBarHeight)
        }
    }
    
    private func buildLeftBtn(){
        leftButton.addTarget(self, action: #selector(leftButtonAction), for: .touchUpInside)
        leftButton.imageView?.contentMode = .center
        addSubview(leftButton)

        leftButton.snp.makeConstraints({ (make) in
            make.left.equalTo(12)
            make.bottom.equalTo(-6)
            make.width.height.equalTo(32)
        })
    }
    
    private func buildTitleLabel(){
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints({ (make) in
            make.left.equalTo(44)
            make.right.equalTo(-44)
            make.height.equalTo(22.0)
            make.bottom.equalTo(-11.0)
        })
    }
    
    private func buildRightButton(){
        rightButton.loadOption([.titleColor(.black, .normal), .font(.ss_semibold(size: 16))])
        rightButton = SSButton(title: "", titleColor: UIColor.black, titleFont: UIFont.ss_semibold(size: 16))
        rightButton.addTarget(self, action: #selector(rightButtonAction), for: .touchUpInside)
        rightButton.isHidden = true
        addSubview(rightButton)

        rightButton.snp.makeConstraints({ (make) in
            make.right.equalTo(-12)
            make.bottom.equalTo(-6)
            make.width.height.equalTo(32)
        })
    }
    
    @objc private func leftButtonAction() {
        if let handler = self.leftButtonHandler {
            handler()
        }
    }
    
    @objc private func rightButtonAction() {
        if let handler = self.rightButtonHandler {
            handler()
        }
    }
}
