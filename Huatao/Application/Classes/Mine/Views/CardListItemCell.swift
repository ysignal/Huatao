//
//  CardListItemCell.swift
//  Huatao
//
//  Created on 2023/2/13.
//  
	

import UIKit

class CardListItemCell: UITableViewCell {
    
    @IBOutlet weak var cardBackground: UIImageView!
    @IBOutlet weak var cardTitle: UILabel!
    @IBOutlet weak var cardTotal: UILabel!
    
    @IBOutlet weak var convertBtn: UIButton!
    @IBOutlet weak var convertTitle: UILabel!
    @IBOutlet weak var convertTime: UILabel!
    
    @IBOutlet weak var beanLabel: UILabel!
    @IBOutlet weak var pvLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contriLabel: UILabel!
    
    var completeBlock: NoneBlock?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func config(item: CardListItem, isComplete: Bool, complete: NoneBlock? = nil) {
        completeBlock = complete
        convertBtn.isHidden = isComplete
        convertTitle.isHidden = !isComplete
        convertTime.isHidden = !isComplete
        
        convertTime.text = item.createdAt
        cardTitle.text = isComplete ? item.name : "\(item.name)(\(item.haveNum)/\(item.holdNum)张)"
        cardTotal.text = item.total.fixedZero()
        
        beanLabel.text = item.silverNum.fixedZero()
        pvLabel.text = item.pv.fixedZero()
        dateLabel.text = "\(item.cycleDays)"
        contriLabel.text = item.contributeValue.fixedZero()
        
        switch item.name {
        case "新手卡包":
            cardBackground.image = UIImage(named: "bg_card_00")
        case "铜牌卡包":
            cardBackground.image = UIImage(named: "bg_card_01")
        case "银牌卡包":
            cardBackground.image = UIImage(named: "bg_card_02")
        case "金牌卡包":
            cardBackground.image = UIImage(named: "bg_card_03")
        default:
            cardBackground.image = UIImage(named: "bg_card_04")
        }
    }
    
    @IBAction func toConvert(_ sender: Any) {
        completeBlock?()
    }
    
}
