//
//  TaskModel.swift
//  Huatao
//
//  Created on 2023/1/13.
//

import Foundation

struct MaterialDetail: SSConvertible {
    
    /// id
    var materialId: Int = 0
    
    /// 标题
    var title: String = ""
    
    /// 文字内容
    var content: String = ""
    
    /// 图片
    var images: [String] = []
    
}

struct TaskListModel: SSConvertible {
    
    /// 常规任务
    var list: [TaskListItem] = []
    
    /// 每日任务
    var dayList: [TaskListItem] = []
    
    /// 每月任务
    var monthList: [TaskListItem] = []
    
}

struct TaskListItem: SSConvertible {
    
    /// ID
    var id: Int = 0
    
    /// 任务标识
    var name: String = ""
    
    /// 任务标题
    var title: String = ""
    
    /// 需要完成数量
    var nubmer: Int = 0
    
    /// 已完成数量
    var completeNumber: Int = 0
    
    /// 任务类型
    var taskType: Int = 0
    
    /// 是否完成
    var isComplete: Int = 0
    
    /// 今日任务对象
    var dayTask = TaskDetail()
    
    /// 本月任务对象
    var monthTask = TaskDetail()
    
}

struct TaskDetail: SSConvertible {
    
    /// 完成任务ID
    var id: Int = 0
    
    /// 完成任务用户ID
    var userId: Int = 0
    
    /// 完成时间
    var completeTime: String = ""
    
    /// 已完成数量
    var completeNumber: Int = 0
    
    /// 比例
    var ratio: String = ""
    
    /// 任务类型
    var type: Int = 0
    
    /// 创建时间
    var createdAt: String = ""
    
    /// 更新时间
    var updatedAt: String = ""
    
    /// 完成任务图片凭证
    var image: String = ""
    
    /// 任务状态
    var status: Int = 0
    
    /// 任务标识
    var name: String = ""
    
}

struct BannerImageItem: SSConvertible {
    
    var image: String = ""
    
}
