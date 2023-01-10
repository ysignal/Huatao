//
//  UITableView+SS.swift
//  SimpleSwift
//
//  Created by user on 2021/4/20.
//

import UIKit

// MARK: Methods
public extension UITableView {

    /// Retrieve the indexPath of the corresponding cell from the view.
    /// - Parameter child: The incoming view.
    /// - Returns: IndexPath of the corresponding cell.
    func indexPath(by child: UIView) -> IndexPath? {
        let point = child.convert(CGPoint.zero, to: self)
        return indexPathForRow(at: point)
    }

    /// Get the corresponding cell according to the Child View.
    /// - Parameter child: The incoming view.
    /// - Returns: The corresponding cell.
    func cell(by child: UIView) -> UITableViewCell? {
        let point = child.convert(CGPoint.zero, to: self)
        if let indexPath = indexPathForRow(at: point) {
            return cellForRow(at: indexPath)
        }
        return nil
    }
    
    var isRefreshing: Bool {
        return self.refreshControl?.isRefreshing == true
    }
    
    func enableRefresh(title: String, tiniColor: UIColor) {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = tiniColor
        refreshControl.attributedTitle = NSAttributedString(string: title)
        self.refreshControl = refreshControl
    }
    
    func disableRefresh() {
        self.refreshControl = nil
    }

    func endRefreshing() {
        self.refreshControl?.endRefreshing()
    }
}
