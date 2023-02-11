//
//  FindViewController.swift
//  Huatao
//
//  Created on 2023/1/10.
//

import UIKit

class FindViewController: SSViewController {
    
    lazy var background: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: SS.w, height: 262))
        view.drawGradient(start: .hex("fff1e2"), end: .white, size: view.frame.size, direction: .t2b)
        return view
    }()
    
    @IBOutlet weak var menuStack: UIStackView!
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var travelView: UIView!
    @IBOutlet weak var shopView: UIView!
    @IBOutlet weak var clubView: UIView!
    
    @IBOutlet weak var findTV: UITableView!
    
    var list: [DynamicListItem] = []
    
    var page: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.ss.showHUDLoading()
        requestData()
    }
    
    override func buildUI() {
        view.insertSubview(background, belowSubview: menuStack)
        
        showFakeNavBar()
        fakeNav.backgroundColor = .clear
        fakeNav.titleLabel.font = .ss_semibold(size: 18)
        fakeNav.title = "发现"
        fakeNav.titleColor = .hex("333333")
        
        circleView.addGesture(.tap) { tap in
            if tap.state == .ended {
                let vc = FriendCircleViewController.from(sb: .find)
                self.go(vc)
            }
        }
        
        findTV.addRefresh(type: .headerAndFooter, delegate: self)
        findTV.register(nibCell: DynamicListItemCell.self)
        findTV.tableFooterView = UIView()
    }
    
    func requestData() {
        HttpApi.Find.getDynamicList(isMy: 0, page: page).done { [weak self] data in
            guard let weakSelf = self else { return }
            let listModel = data.kj.model(ListModel<DynamicListItem>.self)
            if weakSelf.page == 1 {
                weakSelf.list = listModel.list
            } else {
                weakSelf.list.append(contentsOf: listModel.list)
            }
            SSMainAsync {
                weakSelf.findTV.mj_header?.endRefreshing()
                weakSelf.view.ss.hideHUD()
                if weakSelf.list.count >= listModel.total {
                    weakSelf.findTV.mj_footer?.endRefreshingWithNoMoreData()
                } else {
                    weakSelf.findTV.mj_footer?.resetNoMoreData()
                }
                weakSelf.findTV.reloadData()
            }
        }.catch { [weak self] error in
            guard let weakSelf = self else { return }
            SSMainAsync {
                weakSelf.view.ss.hideHUD()
                weakSelf.findTV.endRefresh()
                weakSelf.toast(message: error.localizedDescription)
            }
        }
    }
    
    
}

extension FindViewController: UIScrollViewRefreshDelegate {
    
    func scrollViewHeaderRefreshData(_ scrollView: UIScrollView) {
        page = 1
        requestData()
    }
    
    func scrollViewFooterRefreshData(_ scrollView: UIScrollView) {
        page += 1
        requestData()
    }
    
}

extension FindViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = list[indexPath.row]
        return APP.dynamicHeight(for: item)
    }
    
}

extension FindViewController: UITableViewDataSource {

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
