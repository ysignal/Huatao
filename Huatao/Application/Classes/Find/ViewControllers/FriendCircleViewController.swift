//
//  FriendCircleViewController.swift
//  Huatao
//
//  Created on 2023/1/29.
//

import UIKit

class FriendCircleViewController: BaseViewController {
    
    @IBOutlet weak var circleTV: UITableView!

    var list: [DynamicListItem] = []
    
    var page: Int = 1
    
    var userId: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        view.ss.showHUDLoading()
        requestData()
    }
    
    override func buildUI() {
        fakeNav.title = "朋友圈"

        circleTV.addRefresh(type: .headerAndFooter, delegate: self)
        circleTV.register(nibCell: DynamicListItemCell.self)
        circleTV.tableFooterView = UIView()
    }
    
    func requestData() {
        HttpApi.Find.getDynamicList(isMy: 0, page: page, userId: userId).done { [weak self] data in
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
                weakSelf.circleTV.endRefresh()
                weakSelf.toast(message: error.localizedDescription)
            }
        }
    }
    
    @objc func toSend() {
        let vc = CirclePublishViewController.from(sb: .find)
        vc.completeBlock = { [weak self] in
            self?.page = 1
            self?.requestData()
        }
        go(vc)
    }

}

extension FriendCircleViewController: UIScrollViewRefreshDelegate {
    
    func scrollViewHeaderRefreshData(_ scrollView: UIScrollView) {
        page = 1
        requestData()
    }
    
    func scrollViewFooterRefreshData(_ scrollView: UIScrollView) {
        page += 1
        requestData()
    }
    
}

extension FriendCircleViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = list[indexPath.row]
        return APP.dynamicHeight(for: item)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = list[indexPath.row]
        let vc = CircleDetailViewController.from(sb: .find)
        vc.dynamicId = item.dynamicId
        vc.dynamicItem = item
        vc.updateBlock = {
            self.page = 1
            self.requestData()
        }
        go(vc)
    }
}

extension FriendCircleViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: DynamicListItemCell.self)
        let item = list[indexPath.row]
        cell.config(item: item, target: self)
        cell.updateBlock = { index in
            switch index {
            case 0:
                // 删除
                self.list.remove(at: indexPath.row)
                // iOS 11以后支持，动画删除cell之后调用回调
                tableView.performBatchUpdates {
                    tableView.deleteRows(at: [indexPath], with: .fade)
                } completion: { finished in
                    tableView.reloadData()
                }
            case 1:
                // 点赞
                UIView.performWithoutAnimation {
                    tableView.reloadRows(at: [indexPath], with: .none)
                }
            default:
                break
            }
        }
        return cell
    }
    
}
