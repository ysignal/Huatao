//
//  SSButton.swift
//  Huatao
//
//  Created by minse on 2023/1/10.
//

import UIKit

open class SSButton: UIButton {

    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        // 需要拓展的大小
        let margin: CGFloat = 10
        let touchBounds = bounds.insetBy(dx: -margin, dy: -margin)
        return touchBounds.contains(point)
    }

}
