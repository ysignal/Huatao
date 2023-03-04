//
//  BankCardItemCell.swift
//  Huatao
//
//  Created on 2023/3/1.
//  
	

import UIKit

class BankCardItemCell: UITableViewCell {
    
    @IBOutlet weak var labelStack: UIStackView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var deleteBtn: SSButton!
    
    var completeBlock: NoneBlock?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func config(item: BankCardItem, isEditMode: Bool, complete: NoneBlock?) {
        completeBlock = complete
        deleteBtn.isHidden = !isEditMode
        labelStack.removeAllSubviews()
        fixedLabels(str: item.cardNo)
        timeLabel.text = "绑定时间：\(item.createdAt)"
    }
    
    func fixedLabels(str: String) {
        var mulStr = str
        var list: [String] = []
        while mulStr.count > 0 {
            let text = String(mulStr.prefix(min(4, mulStr.count)))
            if mulStr.count > 4 {
                mulStr = String(mulStr.suffix(mulStr.count - 4))
            } else {
                mulStr = ""
            }
            if mulStr.isEmpty {
                list.append(text)
            } else {
                list.append("*".repeatCount(text.count))
            }
        }
        for item in list {
            let lb = UILabel(text: item, textColor: .white, textFont: .ss_dinbold(size: 30), textAlignment: .center)
            labelStack.addArrangedSubview(lb)
        }
    }
    
    @IBAction func toDelete(_ sender: Any) {
        completeBlock?()
    }
}
