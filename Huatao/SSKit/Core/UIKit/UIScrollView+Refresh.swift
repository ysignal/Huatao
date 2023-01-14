//
//  UIScrollView+Refresh.swift
//  Huatao
//
//  Created by minse on 2023/1/13.
//

import UIKit
import MJRefresh

extension UIScrollView {
    
    var isAtTop: Bool {
        return contentOffset.y == -contentInset.top
    }
    
    func scrollToTop(animated: Bool = true) {
        let topPoint = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(topPoint, animated: animated)
    }
}


//MARK: 下拉刷新、上拉加载
protocol UIScrollViewRefreshDelegate: AnyObject {
    
    /// 下拉刷新
    /// - Parameter scrollView: 滚动视图
    func scrollViewHeaderRefreshData(_ scrollView: UIScrollView)
    
    /// 上拉加载
    /// - Parameter scrollView: 滚动视图
    func scrollViewFooterRefreshData(_ scrollView: UIScrollView)
}

enum UIScrollViewRefreshType {
    case none, header, footer, headerAndFooter
}

private var scrollViewRefreshDelegate: UIScrollViewRefreshDelegate?

extension UIScrollView {

    weak var refreshDelegate: UIScrollViewRefreshDelegate? {
        set {
            objc_setAssociatedObject(self, &scrollViewRefreshDelegate, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            return objc_getAssociatedObject(self, &scrollViewRefreshDelegate) as? UIScrollViewRefreshDelegate
        }
    }
    
    
    func addRefresh(type: UIScrollViewRefreshType, tintColor: UIColor = .gray, delegate: UIScrollViewRefreshDelegate) {
        self.refreshDelegate = delegate
        switch type {
        case .none:
            return
        case .header:
            createHeader(tintColor: tintColor)
        case .footer:
            createFooter()
        case .headerAndFooter:
            createHeader()
            createFooter()
        }
    }
    
    func createHeader(tintColor: UIColor = .gray) {
        let header = MJRefreshHeader {
            self.refreshDelegate?.scrollViewHeaderRefreshData(self)
        }.autoChangeTransparency(true)
        self.mj_header = header
    }
    
    func createFooter() {
        let footer = MJRefreshAutoNormalFooter {
            self.refreshDelegate?.scrollViewFooterRefreshData(self)
        }.autoChangeTransparency(true)
        mj_footer?.ignoredScrollViewContentInsetBottom = SS.safeBottomHeight
        self.mj_footer = footer
    }
    
    func beginRefresh() {
        self.mj_header?.beginRefreshing()
    }

    func endRefresh() {
        self.mj_header?.endRefreshing()
        self.mj_footer?.endRefreshing()
    }
}
