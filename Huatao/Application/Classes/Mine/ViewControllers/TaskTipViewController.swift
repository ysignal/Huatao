//
//  TaskTipViewController.swift
//  Huatao
//
//  Created on 2023/2/13.
//  
	

import UIKit
import JXSegmentedView

class TaskTipViewController: BaseViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var footerView: UIView!
    
    @IBOutlet weak var tipBtn: UIButton!
    
    private lazy var segmentedView: JXSegmentedView = {
        let segment = JXSegmentedView(frame: CGRect(x: 0, y: 0, width: 120, height: 40))
        segment.backgroundColor = .clear
        segment.delegate = self
        return segment
    }()
    
    private var segmentedDataSource = JXSegmentedTitleDataSource()
    
    /// 组头标题数组
    private var titles = ["直推","间推"]
    
    private var list: [TaskNoticeItem] = []
    
    private var page: Int = 0
    
    private var type: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.ss.showHUDLoading()
        requestData()
    }
    
    override func buildUI() {
        fakeNav.title = "任务提醒"
        
        headerView.loadOption([.cornerCut(8, [.topLeft, .topRight], CGSize(width: SS.w - 24, height: 10))])
        footerView.loadOption([.cornerCut(8, [.bottomLeft, .bottomRight], CGSize(width: SS.w - 24, height: 10))])
        tableView.addRefresh(type: .headerAndFooter, delegate: self)
        
        segmentedDataSource.titles = titles
        segmentedDataSource.titleNormalFont = .ss_regular(size: 14)
        segmentedDataSource.titleSelectedFont = .ss_regular(size: 14)
        segmentedDataSource.titleNormalColor = .hex("333333")
        segmentedDataSource.titleSelectedColor = .hex("ff8700")
        segmentedDataSource.itemSpacing = 0
        segmentedDataSource.itemWidth = SS.w/2
        segmentedView.dataSource = segmentedDataSource
        
        let indicator = JXSegmentedIndicatorLineView()
        indicator.verticalOffset = 6
        indicator.indicatorWidth = 28
        indicator.indicatorHeight = 2
        indicator.indicatorColor = UIColor.ss_theme
        segmentedView.indicators = [indicator]
        
        containerView.addSubview(segmentedView)
        segmentedView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        tipBtn.drawThemeGradient(CGSize(width: SS.w - 24, height: 40))
    }
    
    func requestData() {
        HttpApi.Mine.getTaskNotice(page: page, type: type).done { [weak self] data in
            guard let weakSelf = self else { return }
            let listModel = data.kj.model(ListModel<TaskNoticeItem>.self)
            if weakSelf.page == 1 {
                weakSelf.list = listModel.list
            } else {
                weakSelf.list.append(contentsOf: listModel.list)
            }
            SSMainAsync {
                weakSelf.tableView.mj_header?.endRefreshing()
                weakSelf.view.ss.hideHUD()
                if weakSelf.list.count >= listModel.total {
                    weakSelf.tableView.mj_footer?.endRefreshingWithNoMoreData()
                } else {
                    weakSelf.tableView.mj_footer?.resetNoMoreData()
                }
                weakSelf.tableView.reloadData()
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.tableView.endRefresh()
                self?.toast(message: error.localizedDescription)
            }
        }
    }

    @IBAction func toAllTip(_ sender: Any) {
        view.ss.showHUDLoading()
        let ids = list.compactMap({ $0.todayTask != 1 ? $0.userId : nil })
        HttpApi.Mine.putTaskSendNotice(userIds: ids).done { [weak self] _ in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.toast(message: "提醒成功")
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.toast(message: error.localizedDescription)
            }
        }
    }
    
    func toTip(_ item: TaskNoticeItem) {
        view.ss.showHUDLoading()
        HttpApi.Mine.putTaskSendNotice(userIds: [item.userId]).done { [weak self] _ in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.toast(message: "提醒成功")
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.toast(message: error.localizedDescription)
            }
        }
    }
    
}

extension TaskTipViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 62
    }
        
}

extension TaskTipViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: TaskTipItemCell.self)
        let item = list[indexPath.row]
        cell.config(item: item) {
            self.toTip(item)
        }
        return cell
    }
    
}

extension TaskTipViewController: UIScrollViewRefreshDelegate {
    
    func scrollViewHeaderRefreshData(_ scrollView: UIScrollView) {
        page = 1
        requestData()
    }
    
    func scrollViewFooterRefreshData(_ scrollView: UIScrollView) {
        page += 1
        requestData()
    }
    
}

extension TaskTipViewController: JXSegmentedViewDelegate {
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        type = index
        page = 1
        requestData()
    }
}

