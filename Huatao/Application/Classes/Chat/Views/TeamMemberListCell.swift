//
//  TeamMemberListCell.swift
//  Huatao
//
//  Created on 2023/2/21.
//  
	

import UIKit

protocol TeamMemberListCellDelegate: NSObjectProtocol {
    
    func cellDidTapUser(_ item: TeamUser)
    func cellDidTapAdd()
    func cellDidTapDelete()
    
}

class TeamMemberListCell: UITableViewCell {
    
    @IBOutlet weak var memberCV: UICollectionView!
    
    private var list: [TeamUser] = []
    
    private var isMaster: Bool = false
    
    weak var delegate: TeamMemberListCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    deinit {
        delegate = nil
    }
    
    func config(data: [TeamUser], isMaster: Bool) {
        self.isMaster = isMaster
        list = data
        memberCV.reloadData()
    }

}

extension TeamMemberListCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (SS.w - 72)/5
        return CGSize(width: width, height: width + 21)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == list.count + 1 {
            // 群主/管理员踢人
            delegate?.cellDidTapDelete()
        } else if indexPath.row == list.count {
            // 拉人进群
            delegate?.cellDidTapAdd()
        } else {
            // 点击群成员查看详情
            let item = list[indexPath.row]
            delegate?.cellDidTapUser(item)
        }
    }
    
}

extension TeamMemberListCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isMaster ? list.count + 2 : list.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(with: TeamMemberItemCell.self, for: indexPath)
        if indexPath.row == list.count + 1 {
            cell.configDelete()
        } else if indexPath.row == list.count {
            cell.configAdd()
        } else {
            let item = list[indexPath.row]
            cell.config(item: item)
        }
        return cell
    }
    
}
