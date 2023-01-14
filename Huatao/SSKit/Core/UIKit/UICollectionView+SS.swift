//
//  UICollectionView+SS.swift
//  Huatao
//
//  Created by minse on 2023/1/13.
//

import Foundation

extension UICollectionView {
    /// 快速注册xib cell
    func register(nibCell cellClass: AnyClass) {
        let nib = UINib(nibName: String(describing: cellClass), bundle: nil)
        
        self.register(nib, forCellWithReuseIdentifier: String(describing: cellClass))
    }
    
    /// 快速注册cell
    func registerCell(cell cellClass: AnyClass) {
        self.register(cellClass, forCellWithReuseIdentifier: String(describing: cellClass))
    }
    
    /// 快速注册xib View
    func register(nibView viewClass: AnyClass, forSupplementaryViewOfKind elementKind: String) -> Void {
        let nib = UINib(nibName: String(describing: viewClass), bundle: nil)
        self.register(nib, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: String(describing: viewClass))
    }
    
    /// 快速注册View
    func register(view viewClass: AnyClass, forSupplementaryViewOfKind elementKind: String) -> Void {
        self.register(viewClass, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: String(describing: viewClass))
    }

}

extension UICollectionView {
    /// cell复用
    func dequeueReusableCell<T: UICollectionViewCell>(with cellClass: T.Type, for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withReuseIdentifier: String(describing: cellClass), for: indexPath) as! T
    }
    
    /// header/footer复用
    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(ofKind kind: String, view viewClass: T.Type, for indexPath: IndexPath) -> T {
        return dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String(describing: viewClass), for: indexPath) as! T
    }
}

