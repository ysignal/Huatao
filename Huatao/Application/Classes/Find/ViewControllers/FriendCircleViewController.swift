//
//  FriendCircleViewController.swift
//  Huatao
//
//  Created by minse on 2023/1/29.
//

import UIKit

class FriendCircleViewController: BaseViewController {
    
    @IBOutlet weak var circleTV: UITableView!
    
    lazy var sendBtn: SSButton = {
        let btn = SSButton().loadOption([.cornerRadius(4), .border(1, .hex("ffb300")), .font(.ss_regular(size: 14)), .title("发布"), .titleColor(.white)])
        btn.drawGradient(start: .hex("ffa300"), end: .hex("ff8100"), size: CGSize(width: 50, height: 26))
        return btn
    }()
    
    var list: [DynamicListItem] = []
    
    var page: Int = 1

    override func viewDidLoad() {
        super.viewDidLoad()

        view.ss.showHUDLoading()
        requestData()
    }
    
    override func buildUI() {
        fakeNav.title = "朋友圈"
        
        fakeNav.addSubview(sendBtn)
        sendBtn.snp.makeConstraints { make in
            make.width.equalTo(50)
            make.height.equalTo(26)
            make.right.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-9)
        }
        sendBtn.addTarget(self, action: #selector(toSend), for: .touchUpInside)
        
        circleTV.addRefresh(type: .headerAndFooter, delegate: self)
        circleTV.register(nibCell: DynamicListItemCell.self)
        circleTV.tableFooterView = UIView()
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
    
}

extension FriendCircleViewController: UITableViewDataSource {

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
