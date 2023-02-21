//
//  MoneyHistoryViewController.swift
//  Huatao
//
//  Created on 2023/2/21.
//  
	

import UIKit
import JXSegmentedView

class MoneyHistoryViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var noDataImage: UIImageView!
    
    lazy var segmentedView: JXSegmentedView = {
        let segment = JXSegmentedView(frame: CGRect(x: 0, y: 0, width: 120, height: 40))
        segment.backgroundColor = .clear
        segment.delegate = self
        return segment
    }()
    
    var segmentedDataSource = JXSegmentedTitleDataSource()
    
    /// 组头标题数组
    var titles = ["全部", "入账", "提现"]

    /// 组头
    var currentPage: Int = 0
    
    var list: [MoneyHistoryItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        requestData()
    }
    
    override func buildUI() {
        fakeNav.title = "可提现余额明细"
    
        topView.addSubview(segmentedView)
        segmentedView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        segmentedDataSource.titles = titles
        segmentedDataSource.titleNormalFont = .ss_regular(size: 14)
        segmentedDataSource.titleSelectedFont = .ss_semibold(size: 14)
        segmentedDataSource.titleNormalColor = .hex("999999")
        segmentedDataSource.titleSelectedColor = .ss_theme
        segmentedDataSource.itemSpacing = 0
        segmentedDataSource.itemWidth = SS.w/3
        segmentedView.dataSource = segmentedDataSource
        
        let indicator = JXSegmentedIndicatorLineView()
        indicator.verticalOffset = 2
        indicator.indicatorWidth = 20
        indicator.indicatorHeight = 2
        indicator.indicatorColor = UIColor.ss_theme
        segmentedView.indicators = [indicator]
    }
    
    func requestData() {
        
    }

}

extension MoneyHistoryViewController: JXSegmentedViewDelegate {
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        currentPage = index
        
    }
}

extension MoneyHistoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
}

extension MoneyHistoryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: MoneyHistoryCell.self)
        let item = list[indexPath.row]
        cell.config(item: item)
        return cell
    }
    
}
