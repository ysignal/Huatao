//
//  DataEmptyView.swift
//  Huatao
//
//  Created by 杨茗智 on 2023/2/10.
//

import UIKit

private let EmptyViewTag = 12345

protocol DataEmptyViewProtocol: NSObjectProtocol {
    
    ///用以判断是会否显示空视图
    var showEmpty: Bool { get }
    
    ///配置空数据提示图用于展示
    func configEmptyView() -> UIView?
    
}

extension DataEmptyViewProtocol {
    
    func configEmptyView() -> UIView? { return nil }
    
}

extension UITableView {
    
    private struct AssociatedKeys {
        static var emptyViewDelegate = "tableView_emptyViewDelegate"
    }
    
    private static let takeOnceTime: (Selector) -> Void = { newSelector in
        let originSelecter: Selector = #selector(UITableView.layoutSubviews)
        if let originMethod = class_getClassMethod(UITableView.self, originSelecter) {
            class_replaceMethod(UITableView.self, newSelector, method_getImplementation(originMethod), method_getTypeEncoding(originMethod))
        }
    }
    
    private var emptyDelegate: DataEmptyViewProtocol? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.emptyViewDelegate) as? DataEmptyViewProtocol
        }
        set (newValue){
            objc_setAssociatedObject(self, &AssociatedKeys.emptyViewDelegate, newValue!, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func setEmtpyViewDelegate(_ target: DataEmptyViewProtocol) {
        emptyDelegate = target
        UITableView.takeOnceTime(#selector(self.re_layoutSubviews))
    }
    
    @objc func re_layoutSubviews() {
        SS.log("页面重载")
        if emptyDelegate?.showEmpty == true {
            guard let view = emptyDelegate?.configEmptyView() else { return }
            viewWithTag(EmptyViewTag)?.removeFromSuperview()
            view.tag = EmptyViewTag
            addSubview(view)
        } else {
            viewWithTag(EmptyViewTag)?.removeFromSuperview()
        }
    }
    
}

class DataEmptyView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
