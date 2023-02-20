//
//  BaseViewController.swift
//  Huatao
//
//  Created on 2023/1/10.
//

import UIKit

class BaseViewController: SSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        showFakeNavBar()
        
        fakeNav.leftButtonHandler = {
            self.back()
        }
        fakeNav.leftImage = SSImage.back
        
        buildUI()
        view.bringSubviewToFront(fakeNav)
    }

}

