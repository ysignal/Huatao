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
        taskName.text = item.title

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
            if item.number > 1 {
                taskName.text = "观看广告(\(item.completeNumber)/\(item.number))"
            }
            taskIcon.image = SSImage.taskLook
        case "invite_user":
            if item.number > 1 {
                taskName.text = "邀请(\(item.completeNumber)/\(item.number))人"
            }
            taskIcon.image = SSImage.taskInvite
        case "share_friend":
            taskIcon.image = SSImage.taskFriend
        case "point_like":
            taskIcon.image = SSImage.taskLike
        case "complete_every_task":
            if item.number > 1 {
                taskName.text = "累计完成\(item.completeNumber)/\(item.number)天今日任务"
            }
            taskIcon.image = SSImage.taskComplete
        case "month_invite_total":
            if item.number > 1 {
                taskName.text = "本月邀请\(item.completeNumber)/\(item.number)人"
            }
            taskIcon.image = SSImage.taskTotal
        case "month_pay":
            taskIcon.image = SSImage.taskPay
        case "new_send_money":
            taskIcon.image = SSImage.taskMoney
        default:
            taskIcon.image = nil
        }
        
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
