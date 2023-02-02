//
//  TradeSaleBuyCell.swift
//  Huatao
//
//  Created by minse on 2023/1/22.
//

import UIKit

class TradeSaleBuyCell: UITableViewCell {
    
    @IBOutlet weak var tradeNumber: UILabel!
    @IBOutlet weak var tradePrice: UILabel!
    @IBOutlet weak var tradeStatus: UILabel!
    @IBOutlet weak var agreeBtn: UIButton!
    @IBOutlet weak var refuseBtn: UIButton!
    
    private var completeBlock: IntBlock?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func config(item: TradeSaleBuyItem, complete: IntBlock?) {
        completeBlock = complete
        
        tradeNumber.text = "\(item.total)"
        tradePrice.text = "\(item.money)"
        
        resetViews()
        
        switch item.status {
        case 0:
            tradeStatus.isHidden = false
            tradeStatus.text = "待匹配"
        case 1:
            tradeStatus.isHidden = false
            tradeStatus.text = "完成"
        case 2:
            agreeBtn.isHidden = false
            refuseBtn.isHidden = false
        case 3:
            tradeStatus.isHidden = false
            tradeStatus.text = "待上传"
        case 4:
            tradeStatus.isHidden = false
            tradeStatus.text = "拒绝"
        default:
            break
        }
    }
    
    func resetViews() {
        agreeBtn.isHidden = true
        refuseBtn.isHidden = true
        tradeStatus.isHidden = true
    }
    
    @IBAction func toAgree(_ sender: Any) {
        completeBlock?(3)
    }
    
    @IBAction func toRefuse(_ sender: Any) {
        completeBlock?(4)
    }
    
}
