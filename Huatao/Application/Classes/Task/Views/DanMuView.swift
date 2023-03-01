//
//  DanMuView.swift
//  Huatao
//
//  Created on 2023/2/27.
//  
	

import Foundation

protocol DanMuViewDataSource: NSObjectProtocol {
    
    
    /// 点击穿透视图，因为弹幕视图显示在最前，会造成点击阻挡
    /// - Returns: 弹幕视图
    func danmuTouchView() -> UIView?
    
}

class DanMuView: UIView {
    
    /// 每行弹幕占用高度
    private let rowHeight: CGFloat = 26
    
    /// 弹幕之间的行间距
    private let lineSpace: CGFloat = 16
    
    /// 弹幕之间的间距
    private let itemSpace: CGFloat = 12
    
    /// 上下填充间距
    private let padding: CGFloat = 12
    
    /// 销毁间隔
    private let interval: CGFloat = 20
    
    /// 60次/秒的刷新率
    private let duration: TimeInterval = 1/60
    
    /// 弹幕数据源
    private var list: [TurnRecordListItem] = []
    
    /// 正在显示的弹幕视图
    private var aliveViews: [DanMuItemView] = []
    
    /// 回复池中的弹幕视图
    private var recycleViews: [DanMuItemView] = []
    
    /// 弹幕行数
    private var row: Int = 0
    
    /// 弹幕滚动计时器
    private var timer: Timer?
    
    /// 协议数据源
    weak var dataSource: DanMuViewDataSource?
    
    init() {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func destroy() {
        timer?.invalidate()
        timer = nil
        self.removeAllSubviews()
    }
    
    func show(offsetY: CGFloat, row: Int, data: [TurnRecordListItem], in view: UIView) {
        self.list = data
        self.row = row
        
        let height = CGFloat(row) * (rowHeight + lineSpace) - lineSpace + padding * 2
        frame = CGRect(x: 0, y: offsetY, width: SS.w, height: height)
        view.addSubview(self)
        // 初始化偏移值
        startTimer()
    }
    
    func startTimer() {
        if list.isEmpty {
            return
        }
        timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: true, block: { t in
            
            // 找出一个可以显示的数据
            if let index = self.list.firstIndex(where: { !$0.isShow }) {
                var rowDict: [Int: (CGFloat, CGFloat)] = [:]
                for view in self.aliveViews {
                    let viewRow = self.row(for: view.frame.minY)
                    if let x = rowDict[viewRow], view.frame.minX > x.0 {
                        rowDict[viewRow] = (view.frame.minX, view.frame.maxX)
                    } else {
                        rowDict[viewRow] = (view.frame.minX, view.frame.maxX)
                    }
                }
                // 计算显示的坐标
                let origin: CGPoint = {
                    // 当前显示的数据没有填满行数
                    if rowDict.keys.count < self.row {
                        var maxX: CGFloat = 0
                        if self.aliveViews.isEmpty {
                            maxX = SS.w
                        } else {
                            maxX = rowDict.values.compactMap({ $0.0 }).max() ?? 0
                            if maxX + self.itemSpace > SS.w {
                                return .zero
                            }
                        }
                        var row = 0
                        for i in 0..<self.row {
                            if !rowDict.keys.contains(i) {
                                row = i
                                break
                            }
                        }
                        return CGPoint(x: SS.w, y: self.padding + CGFloat(row) * (self.rowHeight + self.lineSpace))
                    } else {
                        // 找出能够显示弹幕的行
                        for val in rowDict {
                            if val.value.1 + self.itemSpace < SS.w {
                                return CGPoint(x: SS.w, y: self.minY(for: val.key))
                            }
                        }
                    }
                    return .zero
                }()
                if !origin.equalTo(.zero) {
                    let item = self.list.remove(at: index)
                    if let view = self.recycleViews.randomElement() {
                        // 随机获取一个再生的弹幕视图
                        view.show(item: item, origin: origin)
                        self.recycleViews.removeAll(where: { $0 === view })
                        self.aliveViews.append(view)
                        self.addSubview(view)
                    } else {
                        let view = DanMuItemView()
                        view.show(item: item, origin: origin)
                        self.recycleViews.removeAll(where: { $0 === view })
                        self.aliveViews.append(view)
                        self.addSubview(view)
                    }
                }
            }
            for (i, view) in self.aliveViews.enumerated() {
                view.ex_x -= 1
                if view.frame.maxX + self.interval < 0 {
                    view.removeFromSuperview()
                    self.aliveViews.remove(at: i)
                    self.recycleViews.append(view)
                    self.list.append(view.model)
                }
            }
        })
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    func row(for y: CGFloat) -> Int {
        return Int(round((y - padding)/(rowHeight + lineSpace)))
    }
    
    func minY(for row: Int) -> CGFloat {
        return CGFloat(row) * (rowHeight + lineSpace) + padding
    }
    
    
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.point(inside: point, with: event) {
            if let view = dataSource?.danmuTouchView() {
                let newPoint = self.convert(point, to: view)
                if view.point(inside: newPoint, with: event) {
                    return view
                }
            }
        }
        return super.hitTest(point, with: event)
    }
    
}

class DanMuItemView: UIView {
    
    private lazy var userIcon: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private lazy var contentLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = .white
        lb.font = .ss_regular(size: 10)
        return lb
    }()
    
    var model = TurnRecordListItem()

    init() {
        super.init(frame: .zero)
        buildUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        buildUI()
    }
    
    func buildUI() {
        backgroundColor = .hex("5e5e5e")
        
        addSubview(userIcon)
        userIcon.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(2)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(22)
        }
        
        addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.left.equalTo(userIcon.snp.right).offset(4)
            make.centerY.equalToSuperview()
        }
    }
    
    func show(item: TurnRecordListItem, origin: CGPoint, rowHeight: CGFloat = 26) {
        model = item
        
        cornerRadius = rowHeight/2
        let iconSize = rowHeight - 4
        userIcon.cornerRadius = iconSize/2
        userIcon.snp.updateConstraints { make in
            make.height.width.equalTo(iconSize)
        }
        
        userIcon.ss_setImage(item.avatar, placeholder: SSImage.userDefault)
        let content = "\(item.name)在\(item.createdAt)转发了海报"
        contentLabel.text = content
        
        let contentWidth = content.width(from: .ss_regular(size: 10), height: 16)
        
        frame = CGRect(origin: origin, size: CGSize(width: contentWidth + iconSize + 14, height: rowHeight))
    }
    
}
