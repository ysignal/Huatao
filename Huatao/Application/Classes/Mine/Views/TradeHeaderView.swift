//
//  TradeHeaderView.swift
//  Huatao
//
//  Created by minse on 2023/1/21.
//

import UIKit
import JXSegmentedView
import AAInfographics

class TradeHeaderView: UIView {
    
    @IBOutlet weak var tradePrice: UILabel!
    @IBOutlet weak var tradeTotal: UILabel!
    @IBOutlet weak var waitTotal: UILabel!
    @IBOutlet weak var saleTotal: UILabel!
    @IBOutlet weak var buyTotal: UILabel!
    @IBOutlet weak var scrapTotal: UILabel!
    
    @IBOutlet weak var sectionView: UIView!
    @IBOutlet weak var chartBackground: UIView!
    
    lazy var chartView: AAChartView = {
        return AAChartView()
    }()
    
    private lazy var segmentedView: JXSegmentedView = {
        let segment = JXSegmentedView(frame: CGRect(x: 0, y: 0, width: 120, height: 40))
        segment.backgroundColor = .clear
        segment.delegate = self
        return segment
    }()
    
    private var segmentedDataSource = JXSegmentedTitleDataSource()
    
    /// 组头标题数组
    private var titles = ["近7天","近14天","近30天"]
    
    private var currentPage: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        segmentedDataSource.titles = titles
        segmentedDataSource.titleNormalFont = .ss_regular(size: 14)
        segmentedDataSource.titleSelectedFont = .ss_semibold(size: 14)
        segmentedDataSource.titleNormalColor = .hex("999999")
        segmentedDataSource.titleSelectedColor = .ss_theme
        segmentedDataSource.itemSpacing = 20
        segmentedDataSource.itemWidthIncrement = 0
        segmentedDataSource.widthForTitleClosure = { title in
            title.width(from: .ss_regular(size: 14), height: 20)
        }
        segmentedDataSource.isItemSpacingAverageEnabled = false
        segmentedView.dataSource = segmentedDataSource
        
        let indicator = JXSegmentedIndicatorLineView()
        indicator.verticalOffset = 3
        indicator.indicatorWidth = 10
        indicator.indicatorHeight = 2
        indicator.indicatorCornerRadius = 1
        indicator.indicatorColor = UIColor.ss_theme
        segmentedView.indicators = [indicator]
        
        sectionView.addSubview(segmentedView)
        segmentedView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.width.equalTo(250)
        }
        
        chartBackground.addSubview(chartView)
        chartView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        requestLineData()
    }
    
    func configData(model: TradeHallModel) {
        tradePrice.text = "\(model.startPrice)"
        saleTotal.text = "\(model.canSaleTotal)"
        buyTotal.text = "\(model.canBuyTotal)"
        scrapTotal.text = "\(model.destructeTotal)"
        //TODO: 测试数据
        tradeTotal.text = "\(model.canSaleTotal + DataManager.randomTotal)"
        waitTotal.text = "\(DataManager.randomRelease)"
    }
    
    func configChart(list: [TradeHallLineItem]) {
        let categories = list.compactMap({
            if let date = Date($0.time, format: "MM-dd") {
                return "\(date.month).\(date.day)"
            }
            return $0.time
        })
        let data = list.compactMap({ $0.startPrice.floatValue })
        let chartModel = AAChartModel().chartType(.line).yAxisVisible(true).inverted(false).legendEnabled(false).tooltipValueSuffix("元").categories(categories).colorsTheme(["#ff8200"]).series([AASeriesElement().name("交易价格").borderColor("#ff8200").data(data)])
        chartView.aa_drawChartWithChartModel(chartModel)
    }
    
    func requestLineData() {
        HttpApi.Mine.getTradingHallLine(type: currentPage).done { [weak self] data in
            let listModel = data.kj.model(ListModel<TradeHallLineItem>.self)
            SSMainAsync {
                self?.configChart(list: listModel.list)
            }
        }
        
    }
}

extension TradeHeaderView: JXSegmentedViewDelegate {
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        currentPage = index
        requestLineData()
    }
}
