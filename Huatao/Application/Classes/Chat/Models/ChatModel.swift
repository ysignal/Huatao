//
//  ChatModel.swift
//  Huatao
//
//  Created by minse on 2023/1/16.
//

import Foundation

struct ChatModel {
    
    static var baseSections = [ChatSectionItem(icon: "ic_chat_book", title: "通讯录")
                               ,ChatSectionItem(icon: "ic_chat_group", title: "群组")
                               ,ChatSectionItem(icon: "ic_chat_team", title: "团队长群")
    ]
    
}

struct ChatSectionItem {
    
    var icon: String = ""
    
    var title: String = ""
    
}
