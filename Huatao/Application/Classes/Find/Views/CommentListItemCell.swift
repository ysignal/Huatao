//
//  CommentListItemCell.swift
//  Huatao
//
//  Created on 2023/1/16.
//

import UIKit

class CommentListItemCell: UITableViewCell {
    
    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var contentLabel: LineHeightLabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var replyBtn: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var likeBtn: SSButton!
    
    @IBOutlet weak var toTitle: UILabel!
    @IBOutlet weak var toName: UILabel!
    
    private var actionBlock: IntBlock?
    
    private var model = CommentChildrenItem()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        likeBtn.selectedImage = UIImage(named: "ic_zan_red")
        likeBtn.image = UIImage(named: "ic_zan_off")
    }

    func config(item: CommentChildrenItem, topUser: Int , action: IntBlock?) {
        self.actionBlock = action
        model = item
        
        toTitle.isHidden = true
        toName.isHidden = true
        if item.receiveUserId != topUser && item.receiveUserId > 0 {
            // 接收对象不是楼主
            toTitle.isHidden = false
            toName.isHidden = false
            toName.text = item.receiveUser
        }
        
        userIcon.ss_setImage(item.sendUserAvatar, placeholder: SSImage.userDefault)
        userName.text = item.sendUser
        contentLabel.text = item.content
        timeLabel.text = item.createdAt
        likeLabel.text = "\(item.likeTotal)"
        likeBtn.isSelected = item.isLike == 1
    }
    
    @IBAction func toReply(_ sender: Any) {
        actionBlock?(1)
    }
    
    @IBAction func toLike(_ sender: Any) {
        actionBlock?(2)
    }
    
}
