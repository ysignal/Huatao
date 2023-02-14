//
//  TradeHistoryBuyCell.swift
//  Huatao
//
//  Created on 2023/1/22.
//

import UIKit

class TradeHistoryBuyCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var stateView: UIView!
    @IBOutlet weak var leftState: UILabel!
    @IBOutlet weak var rightState: UILabel!
    @IBOutlet weak var tradeBtn: UIButton!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    func config(item: TradeBuyListItem) {
        titleLabel.text = "买入\(item.total)金豆"
        timeLabel.text = item.createdAt
        
        leftState.text = ""
        tradeBtn.isHidden = true
        switch item.status {
        case 0:
            leftState.text = "正在匹配"
            rightState.text = "待确认"
        case 1:
            rightState.text = "交易完成"
        case 2:
            tradeBtn.isHidden = false
            leftState.text = "对方同意交易"
        case 3:
            rightState.text = "待上传"
        case 4:
            rightState.text = "待卖家确认"
        default:
            rightState.text = ""
        }
    }

    @IBAction func toTrade(_ sender: Any) {
        
    }
    
}
