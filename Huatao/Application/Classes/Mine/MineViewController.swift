//
//  MineViewController.swift
//  Huatao
//
//  Created by minse on 2023/1/10.
//

import UIKit

class MineViewController: SSViewController {
    
    lazy var background: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: SS.w, height: 262))
        view.drawGradient(start: .hex("fff1e2"), end: .hex("f6f6f6"), size: view.frame.size, direction: .t2b)
        return view
    }()
    
    @IBOutlet weak var mineCV: UICollectionView!
    
    private let list = MineModel.menuList

    override func viewDidLoad() {
        super.viewDidLoad()

        buildUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestUserInfo()
    }
    
    override func buildUI() {
        view.backgroundColor = .hex("f6f6f6")
        view.insertSubview(background, belowSubview: mineCV)
        
        showFakeNavBar()
        fakeNav.backgroundColor = .clear
        fakeNav.titleLabel.font = .ss_semibold(size: 18)
        fakeNav.title = "个人中心"
        fakeNav.titleColor = .hex("333333")
        
        mineCV.register(nibView: MineHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
        mineCV.reloadData()
    }
    
    func requestUserInfo() {
        APP.updateUserInfo {
            self.mineCV.reloadData()
        }
    }
}

extension MineViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: SS.w, height: 175)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = SS.w/4
        return CGSize(width: width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = list[indexPath.row]
        SS.log(item.title)
    }
}

extension MineViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(with: MineMenuItemCell.self, for: indexPath)
        let item = list[indexPath.row]
        cell.config(item: item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, view: MineHeaderView.self, for: indexPath)
            header.config()
            return header
        }
        return UICollectionReusableView()
    }
}
