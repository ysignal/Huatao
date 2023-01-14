//
//  CollectionSection.swift
//  Huatao
//
//  Created by minse on 2023/1/13.
//

import UIKit

protocol CollectionSectionDelegate: AnyObject {
    
    func sectionShouldLoadDataFromNet(_ section: CollectionSection) -> Bool
    func sectionStartLoadingDataFromNet(_ section: CollectionSection)
    func sectionLoadingDataFromNetSuccess(_ section: CollectionSection)
    func sectionLoadingDataFromNetFailure(_ section: CollectionSection, with error: Error)
    
}

protocol CollectionSection: AnyObject {
    
    var isHidden: Bool { get set }
    var collectionView: SectionCollectionView? { get set }
    var numberOfItems: Int { get }
    
    @available(iOS 13.0, *)
    var layout: NSCollectionLayoutSection { get }
    
    func inject(to collectionView: SectionCollectionView)
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView?
    func collectionView(_ collectionView: UICollectionView, didSelectedItemAt indexPath: IndexPath)
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath)
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath])

    func reloadData()
    func insertItems(at indexs: [Int])
    func deleteItems(at indexs: [Int])
    func moveItem(at: Int, to: Int)
}

extension CollectionSection {
    func reloadData() {
        collectionView?.reloadData()
    }
    func insertItems(at indexs: [Int]) {
        collectionView?.insertItems(at: indexs, in: self)
    }
    func deleteItems(at indexs: [Int]) {
        collectionView?.deleteItems(at: indexs, in: self)
    }
    func moveItem(at: Int, to: Int) {
        collectionView?.moveItem(at: at, to: to, in: self)
    }
}

@available(iOS 13.0, *)
extension NSCollectionLayoutSection {
    static var none: NSCollectionLayoutSection = {
        let size = NSCollectionLayoutSize(widthDimension: .absolute(0), heightDimension: .absolute(0))
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: size, subitems: [item])
        return NSCollectionLayoutSection(group: group)
    }()
}

class SingleCollectionSectionCell: UICollectionViewCell {
    
    func reloadData() {}
    
}

/// 只有一个Cell的分组
class SingleCollectionSection<C: SingleCollectionSectionCell>: CollectionSection {
    
    weak var collectionView: SectionCollectionView?
    var isHidden = false
    var numberOfItems: Int {
        return 1
    }
    
    @available(iOS 13.0, *)
    var layout: NSCollectionLayoutSection {
        return .none
    }
    
    func inject(to collectionView: SectionCollectionView) {
        self.collectionView = collectionView
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(with: C.self, for: indexPath)
        cell.reloadData()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView? {
        return nil
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectedItemAt indexPath: IndexPath) {}
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {}
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {}
}

class MutableCollectionSectionCell<M: Codable>: GenericCollectionViewCell<M> {
    
    
}


/// 有多个Cell的分组
class MutableCollectionSection<M: Codable, C: MutableCollectionSectionCell<M>>: CollectionSection {
    
    var page = 0
    var pageSize: Int {
        return 10
    }
    var dataArray = [M]()
    var reloadHandler: (() -> Void)?
    var refreshType: UIScrollViewRefreshType {
        return .headerAndFooter
    }
    var isMainSection: Bool {
        return true
    }

    weak var collectionView: SectionCollectionView?
    var isHidden = false
    
    var numberOfItems: Int {
        return dataArray.count
    }
    
    @available(iOS 13.0, *)
    var layout: NSCollectionLayoutSection {
        return .none
    }
    
    func inject(to collectionView: SectionCollectionView) {
        self.collectionView = collectionView
        collectionView.registerCell(cell: C.self)
        if refreshType != .none {
            collectionView.addRefresh(type: refreshType, delegate: self)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(with: C.self, for: indexPath)
        cell.data = dataArray[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView? {
        return nil
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectedItemAt indexPath: IndexPath) {}
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {}
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]){}
    
    @objc func reloadDataFromNet() {
        page = 0
        loadDataFromNet()
        reloadHandler?()
    }
    
    @objc func loadMoreDataFromNet() {
        loadDataFromNet()
    }
    
    // MARK: - load list data from net
    @objc func loadDataFromNet() {

    }
    
    func loadDataSuccess(_ list: [M]) {
        if page == 0 {
            dataArray = list
        }else {
            dataArray.append(contentsOf: list)
        }
        if dataArray.count == 0 {
        }else {
            page += 1
        }
        if list.count < pageSize {
            collectionView?.mj_header?.endRefreshing()
            collectionView?.mj_footer?.endRefreshingWithNoMoreData()
        }else {
            collectionView?.endRefresh()
        }
        collectionView?.reloadData()
    }

}

extension MutableCollectionSection: UIScrollViewRefreshDelegate {
    //MARK: - header and footer refresh action
    func scrollViewHeaderRefreshData(_ scrollView: UIScrollView) {
        reloadDataFromNet()
    }
    
    func scrollViewFooterRefreshData(_ scrollView: UIScrollView) {
        loadMoreDataFromNet()
    }
}
