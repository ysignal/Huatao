//
//  MineMemuListCell.swift
//  Huatao
//
//  Created on 2023/2/17.
//  
	

import UIKit

protocol MineMemuListCellDelegate: NSObjectProtocol {
    
    func cellClickedItem(_ item: MineMenuItem)
    
}

class MineMemuListCell: UITableViewCell {
    
    weak var delegate: MineMemuListCellDelegate?
    
    @IBOutlet weak var mineCV: UICollectionView!
    
    private let list = MineModel.menuList

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        mineCV.register(nibCell: MineMenuItemCell.self)
    }
    
    deinit {
        delegate = nil
    }

    func config(delegate: MineMemuListCellDelegate?) {
        self.delegate = delegate
    }
    
}


extension MineMemuListCell: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (SS.w - 24)/4
        return CGSize(width: width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = list[indexPath.row]
        delegate?.cellClickedItem(item)
    }
}

extension MineMemuListCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(with: MineMenuItemCell.self, for: indexPath)
        let item = list[indexPath.row]
        cell.config(item: item)
        return cell
    }
}
