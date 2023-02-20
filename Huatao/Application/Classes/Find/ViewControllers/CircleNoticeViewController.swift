//
//  CircleNoticeViewController.swift
//  Huatao
//
//  Created on 2023/2/16.
//  
	

import UIKit

class CircleNoticeViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var list: [InteractMessageListItem] = []
    
    var page: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        requestData()
    }
    
    override func buildUI() {
        fakeNav.title = "消息"
        
        tableView.addRefresh(type: .headerAndFooter, delegate: self)
    }
    
    func requestData() {
        view.ss.showHUDLoading()
        HttpApi.Find.getInteractMessageList().done { [weak self] data in
            guard let weakSelf = self else { return }
            let listModel = data.kj.model(ListModel<InteractMessageListItem>.self)
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
                self?.tableView.endRefreshing()
                self?.toast(message: error.localizedDescription)
            }
        }
    }

}

extension CircleNoticeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
}

extension CircleNoticeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: CircleNoticeItemCell.self)
        let item = list[indexPath.row]
        cell.config(item: item)
        return cell
    }
    
}

extension CircleNoticeViewController: UIScrollViewRefreshDelegate {
    
    func scrollViewHeaderRefreshData(_ scrollView: UIScrollView) {
        page = 1
        requestData()
    }
    
    func scrollViewFooterRefreshData(_ scrollView: UIScrollView) {
        page += 1
        requestData()
    }
    
}
