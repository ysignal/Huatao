//
//  FindViewController.swift
//  Huatao
//
//  Created by minse on 2023/1/10.
//

import UIKit

class FindViewController: SSViewController {
    
    lazy var background: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: SS.w, height: 262))
        view.drawGradient(start: .hex("fff1e2"), end: .hex("f6f6f6"), size: view.frame.size, direction: .t2b)
        return view
    }()
    
    @IBOutlet weak var menuStack: UIStackView!
    @IBOutlet weak var findTV: UITableView!
    
    var list: [DynamicListItem] = []
    
    var page: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        buildUI()
        view.ss.showHUDLoading()
        requestData()
    }
    
    override func buildUI() {
        view.backgroundColor = .hex("f6f6f6")
        view.insertSubview(background, belowSubview: menuStack)
        
        showFakeNavBar()
        fakeNav.backgroundColor = .clear
        fakeNav.titleLabel.font = .ss_semibold(size: 18)
        fakeNav.title = "发现"
        fakeNav.titleColor = .hex("333333")
        
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
                weakSelf.findTV.endRefreshing()
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
        
        let baseHeight: CGFloat = 122
        let contentHeight = item.content.height(from: .ss_regular(size: 14), width: SS.w - 24, lineHeight: 20)
        let mediaHeight: CGFloat = {
            if item.type == 0 {
                return APP.imageHeight(total: item.images.count, lineMax: 3, lineHeight: 86, lineSpace: 2)
            } else if item.type == 1 && !item.video.isEmpty {
                return 150
            }
            return 0
        }()
        let likeText = item.likeArray.compactMap({ $0.userName }).joined(separator: "，")
        let likeHeight = item.likeArray.isEmpty ? 0 : likeText.height(from: .ss_regular(size: 14), width: SS.w - 24, lineHeight: 22, headIndent: 15)
        let commentHeight = CGFloat(item.commentArray.count) * 22
        
        return baseHeight + contentHeight + mediaHeight + likeHeight + commentHeight
    }
    
}

extension FindViewController: UITableViewDataSource {

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
