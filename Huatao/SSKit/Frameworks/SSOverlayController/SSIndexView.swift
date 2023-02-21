//
//  SSIndexView.swift
//  Huatao
//
//  Created on 2023/2/18.
//  
	

import UIKit

protocol SSIndexViewDelegate: NSObjectProtocol {
    
    func indexViewDidSelect(_ index: Int)
    
}

protocol SSIndexViewDataSource: NSObjectProtocol {
    
    func titlesForIndexView() -> [String]
    
    func itemNoHighlightIndexArrayForIndexView() -> [Int]
    
}

extension SSIndexViewDataSource {
    func itemNoHighlightIndexArrayForIndexView() -> [Int] { return [] }
}

class SSIndexItemView: UIButton {
    
    lazy var badge: UILabel = {
        return UILabel()
    }()
    
    lazy var contentLabel: UILabel = {
        return UILabel()
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        contentLabel.textAlignment = .center
        addSubview(badge)
        addSubview(contentLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let badgeWH = min(frame.width, frame.height)
        badge.frame = CGRect(x: (frame.width - badgeWH)/2, y: (frame.height - badgeWH)/2, width: badgeWH, height: badgeWH)
        badge.layer.cornerRadius = badgeWH/2
        
        contentLabel.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
    }
    
}

class SSIndexView: UIView {
    
    // MARK: public property
    
    /// 背景色，默认为黑色
    var contentBackgroundColor: UIColor = .black {
        didSet {
            self.backgroundColor = contentBackgroundColor
        }
    }
    
    /// 标题色，默认为黑色
    var itemTitleColor: UIColor = .black {
        didSet {
            for i in 0..<indexButtons.count {
                if i == selectedIndex {
                    indexButtons[i].contentLabel.textColor = itemHighlightTitleColor
                } else {
                    indexButtons[i].contentLabel.textColor = itemTitleColor
                }
            }
        }
    }
    
    /// 标题高亮颜色，默认为系统蓝
    var itemHighlightTitleColor: UIColor = .systemBlue {
        didSet {
            for i in 0..<indexButtons.count {
                if i == selectedIndex {
                    indexButtons[i].contentLabel.textColor = itemHighlightTitleColor
                } else {
                    indexButtons[i].contentLabel.textColor = itemTitleColor
                }
            }
        }
    }
    
    /// 背景高亮颜色，默认为clear
    var itemHighlightColor: UIColor = .clear
    
    /// 标题字体，默认为13.0
    var itemTitleFont: UIFont = .systemFont(ofSize: 13) {
        didSet {
            for i in 0..<indexButtons.count {
                indexButtons[i].contentLabel.font = itemTitleFont
            }
        }
    }
    
    /// 是否显示指示器，默认为true
    var showIndicatorView: Bool = true
    
    /// 指示器背景颜色，#000000 70%
    var indicatorBackgroundColor: UIColor = .black.withAlphaComponent(0.7)
    
    /// 指示器文字颜色，默认为white
    var indicatorTextColor: UIColor = .white
    
    /// 指示器字体大小，默认为15
    var indicatorTextFont: UIFont = .systemFont(ofSize: 15)
    
    /// 指示器高度大小，默认为20
    var indicatorHeight: CGFloat = 20
    
    /// 指示器右边间距，默认为15
    var indicatorRightMargin: CGFloat = 15
    
    /// 指示器切角，默认为10
    var indicatorCornerRadius: CGFloat = 10
    
    weak var delegate: SSIndexViewDelegate?
    
    weak var dataSource: SSIndexViewDataSource?
    
    // MARK: private property
    
    
    /// 中间显示视图
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    /// 标题数组
    private var indexTitles: [String] = []
    
    /// 标题视图数组
    private var indexButtons: [SSIndexItemView] = []
    
    /// 不高亮数组
    private var itemNoHighlightIndexArray: [Int] = []
    
    /// 标题视图高度
    private var buttonHeight: CGFloat = 20
    
    /// 当前选中
    private var selectedIndex: Int = 0
    
    private lazy var indicatorView: UILabel = {
        let lb = UILabel()
        lb.textColor = indicatorTextColor
        lb.font = indicatorTextFont
        lb.textAlignment = .center
        lb.backgroundColor = indicatorBackgroundColor
        lb.isHidden = true
        
        let indicatorRadius = indicatorHeight/2
        let sinPI_4_Radius = sin(CGFloat.pi/4) * indicatorRadius
        lb.bounds = CGRect(origin: .zero, size: CGSize(width: 4 * sinPI_4_Radius, height: 2 * indicatorRadius))
        let maskLayer = CAShapeLayer()
        maskLayer.path = drawIndicatorPath().cgPath
        lb.layer.mask = maskLayer
        
        return lb
    }()
    
    private var contentHeight: CGFloat = 0
    
    // MARK: init
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    //MARK: Public method
    
    func updateItemHighlightWhenScrollStop(with dispalyView: UIView) {
        let index = determineTopSection(on: dispalyView)
        changeSelectItemColor(with: index)
    }
    
    func reloadData() {
        indexTitles = dataSource?.titlesForIndexView() ?? []
        itemNoHighlightIndexArray = dataSource?.itemNoHighlightIndexArrayForIndexView() ?? []
        
        contentHeight = CGFloat(indexTitles.count) * buttonHeight
        createAllButtons()
        containerView.snp.updateConstraints { make in
            make.height.equalTo(contentHeight)
        }
        
        if showIndicatorView {
            addSubview(indicatorView)
        }
        
        layoutIfNeeded()
    }
    
    //MARK: Private method

    private func setup() {
        addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.left.right.centerY.equalToSuperview()
            make.height.equalTo(buttonHeight)
        }
        reloadData()
    }

    private func determineTopSection(on dispalyView: UIView) -> Int {
        if let collectionView = dispalyView as? UICollectionView {
            let indexPathsForVisibleRows = collectionView.indexPathsForVisibleItems
            var minIndexPath = IndexPath(row: 0, section: 9999)
            for indexPath in indexPathsForVisibleRows {
                minIndexPath = indexPath.compare(minIndexPath) == .orderedDescending ? minIndexPath : indexPath
            }
            return minIndexPath.section
        } else if let tableView = dispalyView as? UITableView {
            if let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows {
                var minIndexPath = IndexPath(row: 0, section: 9999)
                for indexPath in indexPathsForVisibleRows {
                    minIndexPath = indexPath.compare(minIndexPath) == .orderedDescending ? minIndexPath : indexPath
                }
                return minIndexPath.section
            }
        }
        return 0
    }
    
    private func createAllButtons() {
        for view in containerView.subviews {
            view.removeFromSuperview()
        }
        indexButtons = []
        for (i, title) in indexTitles.enumerated() {
            let btn = SSIndexItemView(type: .system)
            btn.tag = i
            btn.contentLabel.textColor = i == selectedIndex ? itemHighlightTitleColor : itemTitleColor
            btn.contentLabel.font = itemTitleFont
            btn.contentLabel.text = title
            btn.isUserInteractionEnabled = false
            containerView.addSubview(btn)
            // 添加约束
            let constant = CGFloat(i) * buttonHeight
            btn.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.height.equalTo(buttonHeight)
                make.top.equalToSuperview().offset(constant)
            }
            
            indexButtons.append(btn)
        }
    }
    
    private func changeSelectItemColor(with index: Int) {
        selectedIndex = index
        for (i, btn) in indexButtons.enumerated() {
            if i == selectedIndex {
                if itemNoHighlightIndexArray.contains(i) {
                    btn.badge.backgroundColor = .clear
                    btn.contentLabel.textColor = itemHighlightColor
                } else {
                    btn.badge.backgroundColor = itemHighlightColor
                    btn.contentLabel.textColor = itemHighlightTitleColor
                }
            } else {
                btn.badge.backgroundColor = .clear
                btn.contentLabel.textColor = itemTitleColor
            }
        }
    }
    
    private func drawIndicatorPath() -> UIBezierPath {
        let indicatorRadius = indicatorHeight/2
        let sinPI_4_Radius = sin(CGFloat.pi/4) * indicatorRadius
        let margin = sinPI_4_Radius * 2 - indicatorRadius
        
        let startPoint = CGPoint(x: margin + indicatorRadius + sinPI_4_Radius, y: indicatorRadius - sinPI_4_Radius)
        let trianglePoint = CGPoint(x: 4 * sinPI_4_Radius, y: indicatorRadius)
        let centerPoint = CGPoint(x: margin + indicatorRadius, y: indicatorRadius)
        
        let bezierPath = UIBezierPath()
        bezierPath.move(to: startPoint)
        bezierPath.addArc(withCenter: centerPoint, radius: indicatorRadius, startAngle: -(CGFloat.pi/4), endAngle: CGFloat.pi/4, clockwise: false)
        bezierPath.addLine(to: trianglePoint)
        bezierPath.addLine(to: startPoint)
        bezierPath.close()
        return bezierPath
    }

    func showIndicator(with index: Int) {
        if itemNoHighlightIndexArray.contains(index) {
            return
        }
        if index < indexButtons.count {
            let btn = indexButtons[index]
            indicatorView.center = CGPoint(x: -(indicatorRightMargin + indicatorHeight/2), y: btn.center.y + containerView.frame.minY)
            indicatorView.text = indexTitles[index]
            indicatorView.alpha = 1
            indicatorView.isHidden = false
        }
    }
    
    func hideIndicator() {
        UIView.animate(withDuration: 0.15) {
            self.indicatorView.alpha = 0
        } completion: { finished in
            self.indicatorView.isHidden = true
        }
    }
    
    //MARK: Event Method
    func touchInsideAction(_ touches: Set<UITouch>) {
        if let touch = touches.first {
            let point = touch.location(in: self)
            let topMargin = (frame.height - contentHeight)/2
            var buttonTag = Int(floor((point.y - topMargin) / buttonHeight))
            buttonTag = max(min(buttonTag, indexTitles.count - 1), 0)
            showIndicator(with: buttonTag)
            delegate?.indexViewDidSelect(buttonTag)
        }
    }
    
    //MARK: System Touch Method
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchInsideAction(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchInsideAction(touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if indicatorView.isHidden {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.hideIndicator()
        }
    }
    
}

extension SSIndexView {
    
    @discardableResult
    func backgroundColor(_ color: UIColor) -> Self {
        contentBackgroundColor = color
        return self
    }
    
    
    @discardableResult
    func highlightBackgroundColor(_ color: UIColor) -> Self {
        itemHighlightColor = color
        return self
    }
    
    @discardableResult
    func titleColor(_ color: UIColor) -> Self {
        itemTitleColor = color
        return self
    }
    
    @discardableResult
    func titleFont(_ font: UIFont) -> Self {
        itemTitleFont = font
        return self
    }
    
    @discardableResult
    func showIndicator(_ flag: Bool) -> Self {
        showIndicatorView = flag
        return self
    }
    
    @discardableResult
    func highlightTitleColor(_ color: UIColor) -> Self {
        itemHighlightTitleColor = color
        return self
    }
    
    @discardableResult
    func indicatorBackgroundColor(_ color: UIColor) -> Self {
        indicatorBackgroundColor = color
        return self
    }
    
    @discardableResult
    func indicatorTextColor(_ color: UIColor) -> Self {
        indicatorTextColor = color
        return self
    }
    
    @discardableResult
    func indicatorTextFont(_ font: UIFont) -> Self {
        indicatorTextFont = font
        return self
    }
    
    @discardableResult
    func indicatorHeight(_ num: CGFloat) -> Self {
        indicatorHeight = num
        return self
    }
    
    @discardableResult
    func indicatorRightMargin(_ num: CGFloat) -> Self {
        indicatorRightMargin = num
        return self
    }
    
    @discardableResult
    func indicatorCornerRadius(_ num: CGFloat) -> Self {
        indicatorCornerRadius = num
        return self
    }
    
}
