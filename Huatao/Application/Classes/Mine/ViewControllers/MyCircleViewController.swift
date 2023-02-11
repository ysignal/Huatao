//
//  MyCircleViewController.swift
//  Huatao
//
//  Created on 2023/1/24.
//

import UIKit

class MyCircleViewController: BaseViewController {
    
    @IBOutlet weak var circleTV: UITableView!
    
    var list: [DynamicListItem] = []
    
    var page: Int = 1

    override func viewDidLoad() {
        super.viewDidLoad()

        view.ss.showHUDLoading()
        requestData()
    }
    
    override func buildUI() {
        fakeNav.title = "我的朋友圈"
        
        circleTV.register(nibCell: DynamicListItemCell.self)
        circleTV.addRefresh(type: .headerAndFooter, delegate: self)
        circleTV.tableFooterView = UIView()
    }
    
    func requestData() {
        HttpApi.Find.getDynamicList(isMy: 1, page: page).done { [weak self] data in
            guard let weakSelf = self else { return }
            let listModel = data.kj.model(ListModel<DynamicListItem>.self)
            if weakSelf.page == 1 {
                weakSelf.list = listModel.list
            } else {
                weakSelf.list.append(contentsOf: listModel.list)
            }
            SSMainAsync {
                weakSelf.circleTV.mj_header?.endRefreshing()
                weakSelf.view.ss.hideHUD()
                if weakSelf.list.count >= listModel.total {
                    weakSelf.circleTV.mj_footer?.endRefreshingWithNoMoreData()
                } else {
                    weakSelf.circleTV.mj_footer?.resetNoMoreData()
                }
                weakSelf.circleTV.reloadData()
            }
        }.catch { [weak self] error in
            guard let weakSelf = self else { return }
            SSMainAsync {
                weakSelf.view.ss.hideHUD()
                weakSelf.circleTV.endRefreshing()
                weakSelf.toast(message: error.localizedDescription)
            }
        }
    }

}

extension MyCircleViewController: UIScrollViewRefreshDelegate {
    
    func scrollViewHeaderRefreshData(_ scrollView: UIScrollView) {
        page = 1
        requestData()
    }
    
    func scrollViewFooterRefreshData(_ scrollView: UIScrollView) {
        page += 1
        requestData()
    }
    
}

extension MyCircleViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = list[indexPath.row]
        return APP.dynamicHeight(for: item)
    }
    
}

extension MyCircleViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: DynamicListItemCell.self)
        let item = list[indexPath.row]
        cell.config(item: item)
        return cell
    }
    
}
