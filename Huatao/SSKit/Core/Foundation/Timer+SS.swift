//
//  Timer+SS.swift
//  Huatao
//
//  Created by minse on 2023/1/15.
//

import Foundation

extension Timer {
    
    func start() {
        fireDate = Date.distantPast
    }
    
    func stop() {
        fireDate = Date.distantFuture
    }
    
}
