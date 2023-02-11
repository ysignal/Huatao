//
//  TaskListItemCell.swift
//  Huatao
//
//  Created on 2023/1/13.
//

import UIKit

class TaskListItemCell: UITableViewCell {

    @IBOutlet weak var taskIcon: UIImageView!
    @IBOutlet weak var taskName: UILabel!
    @IBOutlet weak var completeLabel: UILabel!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var completeBtn: UIButton!
    
    var completionBlock: NoneBlock?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    func config(item: TaskListItem) {
        switch item.name {
        case "turn_promote":
            taskIcon.image = SSImage.taskPromote
        case "card_auth":
            taskIcon.image = SSImage.taskAuth
        case "trade_password":
            taskIcon.image = SSImage.taskTrade
        case "set_place":
            taskIcon.image = SSImage.taskPlace
        case "look_ad":
            taskIcon.image = SSImage.taskLook
        case "invite_user":
            taskIcon.image = SSImage.taskInvite
        case "share_friend":
            taskIcon.image = SSImage.taskFriend
        case "point_like":
            taskIcon.image = SSImage.taskLike
        case "complete_every_task":
            taskIcon.image = SSImage.taskComplete
        case "month_invite_total":
            taskIcon.image = SSImage.taskTotal
        case "month_pay":
            taskIcon.image = SSImage.taskPay
        default:
            taskIcon.image = nil
        }
        
        taskName.text = item.title
        if item.isComplete == 1 {
            completeLabel.isHidden = false
            buttonView.isHidden = true
        } else {
            completeLabel.isHidden = true
            buttonView.isHidden = false
        }
    }
    
    @IBAction func toComplete(_ sender: Any) {
        completionBlock?()
    }
}
