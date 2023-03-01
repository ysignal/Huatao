//
//  DataEmptyView.swift
//  Huatao
//
//  Created on 2023/2/10.
//

import UIKit

extension UITableView {
    
    private struct AssociatedKeys {
        static var emptyView = "scrollview_emptyView"
    }

    private var emptyView: DataEmptyView {
        get {
            if let view = objc_getAssociatedObject(self, &AssociatedKeys.emptyView) as? DataEmptyView {
                return view
            }
            let view = DataEmptyView(content: "")
            self.emptyView = view
            return view
        }
        set (newValue){
            objc_setAssociatedObject(self, &AssociatedKeys.emptyView, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func showEmpty(_ isEmpty: Bool, content: String = "", offset: CGFloat = 0) {
        if isEmpty {
            emptyView.frame = bounds
            emptyView.contentLabel.text = content
            emptyView.viewOffset = offset
            addSubview(emptyView)
        } else {
            emptyView.removeFromSuperview()
        }
    }
    
}

class DataEmptyView: UIView {
    
    lazy var emptyIV: UIImageView = {
        return UIImageView(image: UIImage(named: "img_no_data"))
    }()
    
    lazy var contentLabel: UILabel = {
        return UILabel(text: nil, textColor: .hex("797979"), textFont: .ss_regular(size: 14), textAlignment: .center, numberLines: 0)
    }()
    
    var viewOffset: CGFloat = 0 {
        didSet {
            emptyIV.snp.updateConstraints { make in
                make.centerY.equalToSuperview().offset(-108 + viewOffset)
            }
        }
    }

    init(content: String) {
        super.init(frame: .zero)
        buildUI()
        contentLabel.text = content
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        buildUI()
    }
    
    func buildUI() {
        addSubview(emptyIV)
        emptyIV.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-108)
            make.width.height.equalTo(300)
        }
        
        addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(emptyIV.snp.bottom).offset(8)
            make.height.equalTo(20)
        }
    }

}
