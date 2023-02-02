//
//  TradeHistoryViewController.swift
//  Huatao
//
//  Created by minse on 2023/1/21.
//

import UIKit
import JXSegmentedView

class TradeHistoryViewController: BaseViewController {
    
    @IBOutlet weak var sectionView: UIView!
    @IBOutlet weak var historyTV: UITableView!
    
    private lazy var segmentedView: JXSegmentedView = {
        let segment = JXSegmentedView(frame: CGRect(x: 0, y: 0, width: 120, height: 40))
        segment.backgroundColor = .clear
        segment.delegate = self
        return segment
    }()
    
    private var segmentedDataSource = JXSegmentedTitleDataSource()
    
    /// 组头标题数组
    private var titles = ["买入", "售出"]
    
    private var currentPage: Int = 0
    
    var buyList: [TradeBuyListItem] = []
    
    var saleList: [TradeSaleListItem] = []
    
    var page: Int = 1

    override func viewDidLoad() {
        super.viewDidLoad()

        requestData()
    }
    
    override func buildUI() {
        fakeNav.title = "交易信息"
        
        segmentedDataSource.titles = titles
        segmentedDataSource.titleNormalFont = .ss_regular(size: 14)
        segmentedDataSource.titleSelectedFont = .ss_semibold(size: 14)
        segmentedDataSource.titleNormalColor = .hex("333333")
        segmentedDataSource.titleSelectedColor = .ss_theme
        segmentedDataSource.itemSpacing = 0
        segmentedDataSource.widthForTitleClosure = { title in
            SS.w/2
        }
        segmentedDataSource.isItemSpacingAverageEnabled = false
        segmentedView.dataSource = segmentedDataSource
        
        let indicator = JXSegmentedIndicatorLineView()
        indicator.verticalOffset = 6
        indicator.indicatorWidth = 28
        indicator.indicatorHeight = 2
        indicator.indicatorCornerRadius = 1
        indicator.indicatorColor = UIColor.ss_theme
        segmentedView.indicators = [indicator]
        
        sectionView.addSubview(segmentedView)
        segmentedView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        historyTV.addRefresh(type: .headerAndFooter, delegate: self)
    }
    
    func requestData() {
        if currentPage == 0 {
            HttpApi.Mine.getTradeBuyList(page: page).done { [weak self] data in
                guard let weakSelf = self else { return }
                let listModel = data.kj.model(ListModel<TradeBuyListItem>.self)
                if weakSelf.page == 1 {
                    weakSelf.buyList = listModel.list
                } else {
                    weakSelf.buyList.append(contentsOf: listModel.list)
                }
                SSMainAsync {
                    weakSelf.historyTV.mj_header?.endRefreshing()
                    weakSelf.view.ss.hideHUD()
                    if weakSelf.buyList.count >= listModel.total {
                        weakSelf.historyTV.mj_footer?.endRefreshingWithNoMoreData()
                    } else {
                        weakSelf.historyTV.mj_footer?.resetNoMoreData()
                    }
                    weakSelf.historyTV.reloadData()
                }
            }.catch { [weak self] error in
                SSMainAsync {
                    self?.view.ss.hideHUD()
                    self?.toast(message: error.localizedDescription)
                }
            }
        } else {
            HttpApi.Mine.getTradeSaleList(page: page).done { [weak self] data in
                guard let weakSelf = self else { return }
                let listModel = data.kj.model(ListModel<TradeSaleListItem>.self)
                if weakSelf.page == 1 {
                    weakSelf.saleList = listModel.list
                } else {
                    weakSelf.saleList.append(contentsOf: listModel.list)
                }
                SSMainAsync {
                    weakSelf.historyTV.mj_header?.endRefreshing()
                    weakSelf.view.ss.hideHUD()
                    if weakSelf.saleList.count >= listModel.total {
                        weakSelf.historyTV.mj_footer?.endRefreshingWithNoMoreData()
                    } else {
                        weakSelf.historyTV.mj_footer?.resetNoMoreData()
                    }
                    weakSelf.historyTV.reloadData()
                }
            }.catch { [weak self] error in
                SSMainAsync {
                    self?.view.ss.hideHUD()
                    self?.toast(message: error.localizedDescription)
                }
            }
        }
    }

}

extension TradeHistoryViewController: UIScrollViewRefreshDelegate {
    
    func scrollViewHeaderRefreshData(_ scrollView: UIScrollView) {
        page = 1
        requestData()
    }
    
    func scrollViewFooterRefreshData(_ scrollView: UIScrollView) {
        page += 1
        requestData()
    }
    
}

extension TradeHistoryViewController: JXSegmentedViewDelegate {
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        currentPage = index
        page = 1
        view.ss.showHUDLoading()
        requestData()
    }
}

extension TradeHistoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if currentPage == 1 {
            let item = saleList[indexPath.row]
            return item.buyList.isEmpty ? 102 : (CGFloat(item.buyList.count) * 40) + 62
        }
        return 102
    }
    
}

extension TradeHistoryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentPage == 0 ? buyList.count : saleList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if currentPage == 0 {
            let cell = tableView.dequeueReusableCell(with: TradeHistoryBuyCell.self)
            let item = buyList[indexPath.row]
            cell.config(item: item)
            return cell
        }
        let cell = tableView.dequeueReusableCell(with: TradeHistorySaleCell.self)
        let item = saleList[indexPath.row]
        cell.config(item: item)
        return cell
    }
    
}
