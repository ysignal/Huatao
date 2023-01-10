//
//  Scale.swift
//  SimpleSwift
//
//  Created by user on 2021/4/20.
//

import UIKit

public extension CGFloat {
    var scale: CGFloat {
        return SS.scale(self)
    }
}

public extension Int {
    var scale: CGFloat {
        return SS.scale(CGFloat(self))
    }
}

public extension Double {
    var scale: CGFloat {
        return SS.scale(CGFloat(self))
    }
}
