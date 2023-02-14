//
//  TradeHistorySaleCell.swift
//  Huatao
//
//  Created on 2023/1/22.
//

import UIKit

class TradeHistorySaleCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var stateView: UIView!
    @IBOutlet weak var tradeTV: UITableView!
    
    private var list: [TradeSaleBuyItem] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        tradeTV.register(nibCell: TradeSaleBuyCell.self)
    }

    func config(item: TradeSaleListItem) {
        titleLabel.text = "出售\(item.total)金豆"
        timeLabel.text = item.createdAt
        
        tradeTV.isHidden = item.buyList.isEmpty
        stateView.isHidden = item.status != 1

        switch item.status {
        case 0:
            stateLabel.text = "正在匹配"
        case 1:
            stateLabel.text = "交易完成"
        default:
            stateLabel.text = ""
        }

        list = item.buyList
        tradeTV.reloadData()
    }
    
    @IBAction func toShowTrade(_ sender: Any) {
        
    }
    
    @IBAction func toConfirmTrade(_ sender: Any) {
        
    }
    
}

extension TradeHistorySaleCell: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
}

extension TradeHistorySaleCell: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: TradeSaleBuyCell.self)
        let item = list[indexPath.row]
        cell.config(item: item) { action in
            
        }
        return cell
    }
    
}
