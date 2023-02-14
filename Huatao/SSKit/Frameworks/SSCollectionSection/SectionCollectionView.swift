//
//  SectionCollectionView.swift
//  Huatao
//
//  Created on 2023/1/13.
//

import UIKit

class SectionCollectionView: UICollectionView {

    private var showSections: [CollectionSection] = [CollectionSection]()
    var sections = [CollectionSection]() {
        didSet {
            injectSections()
            showSections = sections.filter{ $0.isHidden == false }
            collectionViewLayout.invalidateLayout()
        }
    }
    var interSectionSpacing: CGFloat = 22 {
        didSet {
            if #available(iOS 13.0, *) {
                if let layout = (collectionViewLayout as? UICollectionViewCompositionalLayout) {
                    let configuration = layout.configuration
                    configuration.interSectionSpacing = interSectionSpacing
                    layout.configuration = configuration
                    layout.invalidateLayout()
                }
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    weak var scrollDelegate: UIScrollViewDelegate?
    var pinView: UIView?
    
    convenience init() {
        self.init(frame: SS.bounds, collectionViewLayout: UICollectionViewLayout())
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        config()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        config()
    }
    
    private func config() {
        if #available(iOS 13.0, *) {
            let configuration = UICollectionViewCompositionalLayoutConfiguration()
            configuration.scrollDirection = .vertical
            configuration.interSectionSpacing = interSectionSpacing
            let layout = UICollectionViewCompositionalLayout { [weak self] (section, _) in
                return self?.showSections[section].layout
            }
            layout.configuration = configuration
            collectionViewLayout = layout
        } else {
            // Fallback on earlier versions
        }
        register(view: UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
        register(view: UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter)
        delegate = self
        dataSource = self
    }
    
    private func injectSections() {
        for section in sections {
            section.inject(to: self)
        }
    }
    
    override func reloadData() {
        showSections = sections.filter{ $0.isHidden == false }
        super.reloadData()
    }

}

extension SectionCollectionView {
   
    func reloadSection(_ section: CollectionSection) {
        guard let index = showSections.firstIndex(where: { $0 === section }) else { return }
        reloadSections([index])
    }
    
    func insertItems(at indexs: [Int], in section: CollectionSection) {
        guard let index = showSections.firstIndex(where: { $0 === section }) else { return }
        insertItems(at: indexs.map{ IndexPath(row: $0, section: index) })
    }
    
    func deleteItems(at indexs: [Int], in section: CollectionSection) {
        guard let index = showSections.firstIndex(where: { $0 === section }) else { return }
        deleteItems(at: indexs.map{ IndexPath(row: $0, section: index) })
    }
    
    func moveItem(at: Int, to: Int, in section: CollectionSection) {
        guard let index = showSections.firstIndex(where: { $0 === section }) else { return }
        moveItem(at: IndexPath(row: at, section: index), to: IndexPath(row: to, section: index))
    }
    
    func selectItem(at index: Int, in section: CollectionSection, animated: Bool, scrollPosition: UICollectionView.ScrollPosition = .bottom) {
        guard let temp = showSections.firstIndex(where: { $0 === section }) else { return }
        selectItem(at: IndexPath(row: index, section: temp), animated: animated, scrollPosition: scrollPosition)
    }
    
    func deselectItem(at index: Int, in section: CollectionSection, animated: Bool) {
        guard let temp = showSections.firstIndex(where: { $0 === section }) else { return }
        deselectItem(at: IndexPath(row: index, section: temp), animated: animated)
    }
    
}

extension SectionCollectionView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return showSections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return showSections[section].numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return showSections[indexPath.section].collectionView(collectionView, cellForItemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let view = showSections[indexPath.section].collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath) {
            return view
        }else {
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, view: UICollectionReusableView.self, for: indexPath)
        }
    }
}

extension SectionCollectionView: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for item in indexPaths {
            showSections[item.section].collectionView(collectionView, prefetchItemsAt: [item])
        }
    }
}

extension SectionCollectionView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showSections[indexPath.section].collectionView(collectionView, didSelectedItemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        showSections[indexPath.section].collectionView(collectionView, didDeselectItemAt: indexPath)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = min(-scrollView.contentOffset.y, 0)
        pinView?.transform = CGAffineTransform.init(translationX: 0, y: y)
        scrollDelegate?.scrollViewDidScroll?(scrollView)
    }
    
}
