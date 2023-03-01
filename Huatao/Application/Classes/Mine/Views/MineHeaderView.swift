//
//  MineHeaderView.swift
//  Huatao
//
//  Created on 2023/1/15.
//

import UIKit


protocol MineHeaderViewDelegate: NSObjectProtocol {
    
    func headerViewWillStartAction(_ action: MineHeaderView.HeaderAction)
    
}

class MineHeaderView: UICollectionReusableView {
    
    enum HeaderAction {
        case edit, card, bean, ticket, vip, money
    }
    
    weak var delegate: MineHeaderViewDelegate?
    
    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var copyBtn: SSButton!
    @IBOutlet weak var vipBtn: UIButton!
    
    @IBOutlet weak var moneyLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var cardLabel: UILabel!
    @IBOutlet weak var beanLabel: UILabel!
    @IBOutlet weak var ticketLabel: UILabel!
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var beanView: UIView!
    @IBOutlet weak var ticketView: UIView!
    
    @IBOutlet weak var moneyView: UIView!
    @IBOutlet weak var rateView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        
        moneyView.addGesture(.tap) { tap in
            if tap.state == .ended {
                self.delegate?.headerViewWillStartAction(.money)
            }
        }
        
        cardView.addGesture(.tap) { tap in
            if tap.state == .ended {
                self.delegate?.headerViewWillStartAction(.card)
            }
        }
        
        beanView.addGesture(.tap) { tap in
            if tap.state == .ended {
                self.delegate?.headerViewWillStartAction(.bean)
            }
        }
        
        ticketView.addGesture(.tap) { tap in
            if tap.state == .ended {
                self.delegate?.headerViewWillStartAction(.ticket)
            }
        }
        
        userIcon.addGesture(.tap) { tap in
            if tap.state == .ended {
                self.delegate?.headerViewWillStartAction(.edit)
            }
        }
        
        userName.addGesture(.tap) { tap in
            if tap.state == .ended {
                self.delegate?.headerViewWillStartAction(.edit)
            }
        }
    }
    
    deinit {
        delegate = nil
    }
    
    func config() {
        userIcon.ss_setImage(APP.userInfo.avatar, placeholder: SSImage.userDefault)
        userName.text = APP.userInfo.name
        codeLabel.text = "邀请码: \(APP.userInfo.inviteCode)"
        copyBtn.isHidden = APP.userInfo.inviteCode.isEmpty
        let level = DataManager.vipList.firstIndex(of: APP.userInfo.levelName) ?? 0
        vipBtn.image = UIImage(named: "ic_mine_vip_\(level + 1)")
        
        moneyLabel.text = "\(APP.userInfo.money)"
        rateLabel.text = APP.userInfo.rate.fixedZero()
        cardLabel.text = "\(APP.userInfo.cardCount)"
        beanLabel.text = APP.userInfo.silverBean.fixedZero()
    }
    
    @IBAction func toCopy(_ sender: Any) {
        UIPasteboard.general.string = codeLabel.text
        globalToast(message: "复制成功")
    }
    
    @IBAction func toVipRule(_ sender: Any) {
        delegate?.headerViewWillStartAction(.vip)
    }
    
}
