//
//  SSFullViewController.swift
//  SimpleSwift
//
//  Created by user on 2021/4/20.
//

import UIKit

open class SSFullViewController: SSViewController {
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        modalPresentationStyle = .fullScreen
    }
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        modalPresentationStyle = .fullScreen
    }
}

open class SSOverFullViewController: SSViewController {
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        modalPresentationStyle = .overFullScreen
    }
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        modalPresentationStyle = .overFullScreen
    }
}
