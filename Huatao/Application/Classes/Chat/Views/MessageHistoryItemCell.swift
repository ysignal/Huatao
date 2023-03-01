//
//  MessageHistoryItemCell.swift
//  Huatao
//
//  Created on 2023/2/23.
//  
	

import UIKit

class MessageHistoryItemCell: UITableViewCell {
    
    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
    }

    func config(item: RCMessage, keyword: String) {
        let userId = item.targetId.intValue
        if userId == APP.loginData.userId {
            userIcon.ss_setImage(APP.userInfo.avatar, placeholder: SSImage.userDefault)
            userName.text = APP.userInfo.name
        } else {
            SSCacheLoader.loadIMUser(from: userId) { [weak self] data in
                SSMainAsync {
                    if let userInfo = data {
                        self?.userIcon.ss_setImage(userInfo.avatar, placeholder: SSImage.userDefault)
                        self?.userName.text = userInfo.name
                    } else {
                        self?.userIcon.image = SSImage.userDefault
                        self?.userName.text = ""
                    }

                }
            }
        }
        timeLabel.text = SSDateHelper.formattedTime(from: item.receivedTime)
        
        if keyword.isEmpty {
            messageLabel.attributedText = nil
            messageLabel.text = item.content?.conversationDigest()
        } else {
            let mulStr = NSMutableAttributedString()
            if let content = item.content?.conversationDigest(),
               let range = content.range(of: keyword) {
                let maxCount = Int((SS.w - 80)/14)
                if keyword.count >= maxCount {
                    // 全部标亮
                    let newText = content.suffix(from: range.lowerBound).prefix(maxCount)
                    mulStr.append(NSAttributedString(string: String(newText)))
                    let location = 0
                    let length = keyword.count
                    mulStr.addAttributes([.foregroundColor: UIColor.ss_theme], range: NSRange(location: location, length: length))
                } else {
                    let prefixText = content.prefix(upTo: range.upperBound)
                    if prefixText.count >= maxCount {
                        let suffixText = prefixText.suffix(maxCount)
                        mulStr.append(NSAttributedString(string: String(suffixText)))
                        let location = maxCount - keyword.count
                        let length = keyword.count
                        mulStr.addAttributes([.foregroundColor: UIColor.ss_theme], range: NSRange(location: location, length: length))
                    } else {
                        let newText = content.prefix(maxCount)
                        mulStr.append(NSAttributedString(string: String(newText)))
                        let location = prefixText.count - keyword.count
                        let length = keyword.count
                        mulStr.addAttributes([.foregroundColor: UIColor.ss_theme], range: NSRange(location: location, length: length))
                    }
                }
                messageLabel.attributedText = mulStr
            }
        }
    }

}
