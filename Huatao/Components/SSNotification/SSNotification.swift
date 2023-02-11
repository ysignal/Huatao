//
//  SSNotification.swift
//  Charming
//
//  Created on 2022/11/18.
//

import Foundation
import SwiftNotificationCenter

protocol DataReload {
    func reloadData()
}

struct SSNotification {
    
    static func reloadData() {
        Broadcaster.notify(DataReload.self) {
            $0.reloadData()
        }
    }
}
