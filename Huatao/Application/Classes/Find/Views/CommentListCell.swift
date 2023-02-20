//
//  CommentListCell.swift
//  Huatao
//
//  Created on 2023/2/16.
//  
	

import UIKit

protocol CommentListCellDelegate: NSObjectProtocol {
    
    func cellChildrenOpen(_ item: CommentListItem)
    
    func cellComment(_ item: CommentListItem)
    
    func cellCommentChildren(_ item: CommentListItem, children: CommentChildrenItem)
    
    func cellLike(_ item: CommentListItem)
    
    func cellChildrenLike(_ item: CommentChildrenItem)
    
}

class CommentListCell: UITableViewCell {
    
    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var contentLabel: LineHeightLabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var replyBtn: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var likeBtn: SSButton!
    
    @IBOutlet weak var expandView: UIView!
    @IBOutlet weak var expandViewWidth: NSLayoutConstraint!
    @IBOutlet weak var expandLabel: UILabel!
    
    @IBOutlet weak var commentTV: UITableView!
    
    weak var delegate: CommentListCellDelegate?
    var model = CommentListItem()
    var list: [CommentChildrenItem] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        likeBtn.selectedImage = UIImage(named: "ic_zan_red")
        likeBtn.image = UIImage(named: "ic_zan_off")
        commentTV.register(nibCell: CommentListItemCell.self)
        
        expandView.addGesture(.tap) { tap in
            if tap.state == .ended {
                self.delegate?.cellChildrenOpen(self.model)
            }
        }
    }

    func config(item: CommentListItem, isOpen: Bool, delegate: CommentListCellDelegate?) {
        self.delegate = delegate
        model = item
        userIcon.ss_setImage(item.sendUserAvatar, placeholder: SSImage.userDefault)
        userName.text = item.sendUser
        contentLabel.text = item.content
        timeLabel.text = item.createdAt
        likeLabel.text = "\(item.likeTotal)"
        likeBtn.isSelected = item.isLike == 1
        
        
        if isOpen {
            expandView.isHidden = true
            commentTV.isHidden = false
        } else {
            commentTV.isHidden = true
            expandView.isHidden = item.children.isEmpty
            let expandText = "展开\(item.children.count)条回复"
            expandLabel.text = expandText
            expandViewWidth.constant = expandText.width(from: .ss_semibold(size: 12), height: 20) + 43
        }
        
        list = item.children
        commentTV.reloadData()
    }
    
    @IBAction func toReply(_ sender: Any) {
        delegate?.cellComment(model)
    }
    
    @IBAction func toLike(_ sender: Any) {
        delegate?.cellLike(model)
    }
    
}

extension CommentListCell: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = list[indexPath.row]
        return item.content.height(from: .ss_semibold(size: 14), width: SS.w - 96, lineHeight: 20) + 56
    }
    
}

extension CommentListCell: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: CommentListItemCell.self)
        let item = list[indexPath.row]
        cell.config(item: item, topUser: model.sendUserId) { action in
            if action == 1 {
                self.delegate?.cellCommentChildren(self.model, children: item)
            } else if action == 2 {
                self.delegate?.cellChildrenLike(item)
            }
        }
        return cell
    }
    
}
