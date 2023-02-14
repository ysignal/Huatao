//
//  ConvertHistoryViewController.swift
//  Huatao
//
//  Created on 2023/1/29.
//

import UIKit

class ConvertHistoryViewController: BaseViewController {
    
    @IBOutlet weak var historyTV: UITableView!
    
    var list: [WalletRecordItem] = []
    
    var page: Int = 1

    override func viewDidLoad() {
        super.viewDidLoad()

        view.ss.showHUDLoading()
        requestData()
    }
    
    override func buildUI() {
        fakeNav.title = "兑换记录"
        
        historyTV.addRefresh(type: .headerAndFooter, delegate: self)
    }
    
    func requestData() {
        HttpApi.Mine.getConversionList(page: page).done { [weak self] data in
            guard let weakSelf = self else { return }
            let listModel = data.kj.model(ListModel<WalletRecordItem>.self)
            if weakSelf.page == 1 {
                weakSelf.list = listModel.list
            } else {
                weakSelf.list.append(contentsOf: listModel.list)
            }
            SSMainAsync {
                weakSelf.historyTV.mj_header?.endRefreshing()
                weakSelf.view.ss.hideHUD()
                if weakSelf.list.count >= listModel.total {
                    weakSelf.historyTV.mj_footer?.endRefreshingWithNoMoreData()
                } else {
                    weakSelf.historyTV.mj_footer?.resetNoMoreData()
                }
                weakSelf.historyTV.reloadData()
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.historyTV.endRefresh()
                self?.toast(message: error.localizedDescription)
            }
        }
    }

}

extension ConvertHistoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 32
    }
    
}

extension ConvertHistoryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: ConvertHistoryItemCell.self)
        let item = list[indexPath.row]
        cell.config(item: item)
        return cell
    }
    
}

extension ConvertHistoryViewController: UIScrollViewRefreshDelegate {
    
    func scrollViewHeaderRefreshData(_ scrollView: UIScrollView) {
        page = 1
        requestData()
    }
    
    func scrollViewFooterRefreshData(_ scrollView: UIScrollView) {
        page += 1
        requestData()
    }
    
}
