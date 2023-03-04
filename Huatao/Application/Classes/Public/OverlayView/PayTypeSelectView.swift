//
//  PayTypeSelectView.swift
//  Huatao
//
//  Created on 2023/3/3.
//  
	

import UIKit

class PayTypeSelectView: UIView {
    
    @IBOutlet weak var moneyLabel: UILabel!
    @IBOutlet weak var typeTitle: UILabel!
    @IBOutlet weak var wxView: UIView!
    @IBOutlet weak var aliView: UIView!
    @IBOutlet weak var beanView: UIView!
    
    @IBOutlet weak var wxIcon: UIImageView!
    @IBOutlet weak var aliIcon: UIImageView!
    
    @IBOutlet weak var beanLabel: UILabel!
    
    @IBOutlet weak var passwordView: PasswordInputView!
    
    private var completionBlock: NoneBlock?
    
    /// 支付类型，0-银豆，1-微信支付，2-支付宝支付
    var payType: Int = 0

    override func awakeFromNib() {
        super.awakeFromNib()
        
        buildUI()
    }

    private func buildUI() {
        backgroundColor = .white
        cornerRadius = 8
        
        passwordView.delegate = self
        
        wxView.addGesture(.tap) { tap in
            if tap.state == .ended {
                self.payType = 1
                self.reloadPayTypeView()
            }
        }
        
        aliView.addGesture(.tap) { tap in
            if tap.state == .ended {
                self.payType = 2
                self.reloadPayTypeView()
            }
        }
        
        passwordView.config(delegate: self)
    }

    static func show(money: String, type: Int, completion: NoneBlock? = nil)  {
        let view = fromNib()
        view.config(money: money, type: type)
        view.completionBlock = completion
        
        let config = OverlayConfig()
        config.name = view.named
        config.width = 254
        // 列表最多显示8个
        config.height = 300
        config.location = .center
        config.statusBarStyle = .lightContent
        config.isEditContainer = true
        config.overlayBackMode = .color(color: .black.withAlphaComponent(0.6))
        config.contentAnimation = ZoomOutAniamtion()
        SSOverlayController.show(view, config: config)
    }

    func config(money: String, type: Int) {
        if type == 0 {
            beanView.isHidden = false
            aliView.isHidden = true
            wxView.isHidden = true
            payType = 0
        } else {
            beanView.isHidden = true
            aliView.isHidden = false
            payType = 2
        }
        reloadPayTypeView()
        beanLabel.text = APP.userInfo.silverBean.fixedZero()
        
        let unit = type == 0 ? "银豆" : "元"
        let mulStr = NSMutableAttributedString(string: money.fixedZero(), attributes: [.foregroundColor: UIColor.ss_33, .font: UIFont.ss_semibold(size: 40)])
        mulStr.append(NSAttributedString(string: " \(unit)", attributes: [.foregroundColor: UIColor.ss_33, .font: UIFont.ss_semibold(size: 12)]))
        moneyLabel.attributedText = mulStr
        
        passwordView.startInput()
    }
    
    func reloadPayTypeView() {
        switch payType {
        case 0:
            typeTitle.text = "剩余银豆"
        case 1:
            typeTitle.text = "支付方式"
            wxIcon.image = SSImage.checkboxOn
            aliIcon.image = SSImage.checkboxOff
        case 2:
            typeTitle.text = "支付方式"
            aliIcon.image = SSImage.checkboxOn
            wxIcon.image = SSImage.checkboxOff
        default:
            break
        }
    }
    
}

extension PayTypeSelectView: PasswordInputViewDelegate {

    func passwordDidEndedInput(_ text: String) {
        // 需要进行密码验证
        
        SSOverlayController.dismiss(named)
    }
    
}
