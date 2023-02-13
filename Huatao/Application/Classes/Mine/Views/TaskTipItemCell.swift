//
//  TaskTipItemCell.swift
//  Huatao
//
//  Created on 2023/2/13.
//  
	

import UIKit

class TaskTipItemCell: UITableViewCell {
    
    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userMobile: UILabel!
    @IBOutlet weak var completeBtn: SSButton!
    @IBOutlet weak var tipBtn: SSButton!
    
    var completeBlock: NoneBlock?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func config(item: TaskNoticeItem, complete: NoneBlock? = nil) {
        completeBlock = complete
        userIcon.ss_setImage(item.avatar, placeholder: SSImage.userDefault)
        userName.text = item.name
        userMobile.text = item.mobile
        if item.todayTask == 1 {
            completeBtn.isHidden = false
            tipBtn.isHidden = true
        } else {
            completeBtn.isHidden = true
            tipBtn.isHidden = false
        }
    }
    
    @IBAction func tipBtn(_ sender: Any) {
        completeBlock?()
    }
    
}
