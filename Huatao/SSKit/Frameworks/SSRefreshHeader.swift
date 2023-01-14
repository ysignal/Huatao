//
//  SSRefreshHeader.swift
//  Huatao
//
//  Created by minse on 2023/1/13.
//

import UIKit
import MJRefresh

class SSRefreshHeader: MJRefreshHeader {
    
    override var tintColor: UIColor! {
        didSet {
            activityIndicator.color = tintColor
        }
    }
    
    private let activityIndicator = UIActivityIndicatorView(style: .gray)
    
    override func prepare() {
        super.prepare()
        activityIndicator.hidesWhenStopped = true
    }
    
    override func placeSubviews() {
        super.placeSubviews()
        activityIndicator.color = tintColor
        addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    override var state: MJRefreshState {
        didSet {
            if oldValue == state { return }
            if state == .idle {
                activityIndicator.stopAnimating()
            } else {
                activityIndicator.startAnimating()
            }
        }
    }
    
}
