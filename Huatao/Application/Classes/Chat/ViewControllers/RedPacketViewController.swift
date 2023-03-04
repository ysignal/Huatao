//
//  RedPacketViewController.swift
//  Huatao
//
//  Created on 2023/2/23.
//  
	

import UIKit

class RedPacketViewController: BaseViewController {
    
    @IBOutlet weak var beanView: UIView!
    @IBOutlet weak var beanTitle: UILabel!
    @IBOutlet weak var moneyView: UIView!
    @IBOutlet weak var moneyTitle: UILabel!
    
    @IBOutlet weak var groupView: UIView!
    @IBOutlet weak var typeBtn: SSButton!
    @IBOutlet weak var countTF: UITextField!
    @IBOutlet weak var groupLabel: UILabel!
    
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var tagTitle: UILabel!
    @IBOutlet weak var tagUnit: UILabel!
    @IBOutlet weak var totalTF: UITextField!
    
    @IBOutlet weak var descTF: UITextField!
    
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var sendBtn: UIButton!
    
    var targetId: String = ""
    
    var conversationType: RCConversationType = .ConversationType_PRIVATE
    
    /// 红包支付方式
    enum RedPayType {
        case bean // 豆子
        case money // 现金
    }
    
    /// 红包获取方式
    enum RedGetType {
        case random // 拼手气
        case average // 平均
    }
    
    var total: CGFloat = 0
    
    var payType: RedPayType = .bean
    
    var getType: RedGetType = .average
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func buildUI() {
        fakeNav.title = "红包"
        view.backgroundColor = .ss_f6
        
        if conversationType == .ConversationType_PRIVATE {
            groupView.isHidden = true
        }
        
        beanView.addGesture(.tap) { tap in
            self.view.endEditing(true)
            if tap.state == .ended {
                self.payType = .bean
                self.reloadViews()
            }
        }
        
        moneyView.addGesture(.tap) { tap in
            self.view.endEditing(true)
            if tap.state == .ended {
                self.payType = .money
                self.reloadViews()
            }
        }
        
        countTF.delegate = self
        totalTF.delegate = self
        descTF.delegate = self
        
        sendBtn.drawGradient(start: .hex("ffa300"), end: .hex("ff8100"), size: CGSize(width: 178, height: 46), direction: .l2r)
        
        reloadViews()
    }
    
    func reloadViews() {
        switch payType {
        case .bean:
            tagLabel.text = "豆"
            tagTitle.text = "银豆数量"
            tagUnit.text = "个"
            sendBtn.title = "塞银豆进红包"
            beanView.drawGradient(start: .hex("ffa300"), end: .hex("ff8100"), size: CGSize(width: (SS.w - 44)/2, height: 46), direction: .l2r)
            beanTitle.textColor = .white
            moneyView.drawGradient(start: .white, end: .white, size: CGSize(width: (SS.w - 44)/2, height: 46), direction: .l2r)
            moneyTitle.textColor = .ss_33
        case .money:
            moneyView.drawGradient(start: .hex("ffa300"), end: .hex("ff8100"), size: CGSize(width: (SS.w - 44)/2, height: 46), direction: .l2r)
            moneyTitle.textColor = .white
            beanView.drawGradient(start: .white, end: .white, size: CGSize(width: (SS.w - 44)/2, height: 46), direction: .l2r)
            beanTitle.textColor = .ss_33
            tagUnit.text = "元"
            sendBtn.title = "塞钱进红包"
            switch getType {
            case .random:
                tagLabel.text = "拼"
                tagTitle.text = "总金额"
            case .average:
                tagLabel.text = "单"
                tagTitle.text = "单个金额"
            }
        }
        switch getType {
        case .random:
            typeBtn.title = "拼手气红包"
        case .average:
            typeBtn.title = "普通红包"
        }
        calculateTotal()
    }
    
    func calculateTotal() {
        let count = countTF.text?.floatValue ?? 0
        let money = totalTF.text?.floatValue ?? 0
        
        let unit: String = {
            if payType == .bean {
                return "银豆"
            }
            return "元"
        }()
        total = {
            if conversationType == .ConversationType_PRIVATE {
                return money
            } else {
                if getType == .average {
                    return count * money
                }
                return money
            }
        }()
        let totalStr = String(format: "%.02f", total)
        let mulStr = NSMutableAttributedString(string: totalStr.fixedZero(), attributes: [.foregroundColor: UIColor.ss_33, .font: UIFont.ss_semibold(size: 40)])
        mulStr.append(NSAttributedString(string: " \(unit)", attributes: [.foregroundColor: UIColor.ss_33, .font: UIFont.ss_semibold(size: 12)]))
        totalLabel.attributedText = mulStr
    }
    
    @IBAction func textFieldChanged(_ sender: UITextField) {
        calculateTotal()
    }
    
    @IBAction func toSelectType(_ sender: Any) {
        self.view.endEditing(true)
        BaseActionSheetView.show(list: ["拼手气红包", "普通红包"]) { index in
            if index == 0 {
                self.getType = .random
                self.reloadViews()
            } else if index == 1 {
                self.getType = .average
                self.reloadViews()
            }
        }
    }
    
    @IBAction func toSend(_ sender: Any) {
        self.view.endEditing(true)
        if total <= 0 {
            toast(message: "红包金额不能为0")
            return
        }

        if payType == .bean {
            view.ss.showHUDLoading()
            HttpApi.Chat.putUserSendRed(userId: targetId.intValue, type: 0, payType: 0, money: total).done { [weak self] data in
                guard let weakSelf = self else { return }
                let redId = data["red_id"] as? Int ?? 0
                SSMainAsync {
                    weakSelf.view.ss.hideHUD()
                    if redId == 0 {
                        weakSelf.toast(message: "获取红包ID失败！")
                        return
                    }
                    weakSelf.sendRedMessage(with: redId, type: 0, total: weakSelf.total)
                }
            }.catch { [weak self] error in
                SSMainAsync {
                    self?.view.ss.hideHUD()
                    self?.toast(message: error.localizedDescription)
                }
            }
        } else {
            // 现金
        }
    }
    
    func sendRedMessage(with redId: Int, type: Int, total: CGFloat) {
        let text = descTF.text ?? ""
        let desc = text.isEmpty ? "恭喜发财，大吉大利" : text
        let content = HTRedMessage(name: APP.userInfo.name, avatar: APP.userInfo.avatar, redid: redId, message: desc, type: type, money: "\(total)")
        let message = RCMessage(type: .ConversationType_PRIVATE, targetId: targetId, direction: .MessageDirection_SEND, content: content)
        message.canIncludeExpansion = true
        message.expansionDic = ["isopen": "0"]
        RCIM.shared().send(message, pushContent: "你收到一个红包", pushData: nil) { [weak self] msg in
            SSMainAsync {
                self?.back()
            }
        } errorBlock: { [weak self] code, msg in
            self?.view.toast(message: "消息发送失败：\(code.rawValue)")
        }
    }
    
    
    
}

extension RedPacketViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
