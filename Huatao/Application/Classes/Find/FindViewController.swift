//
//  FindViewController.swift
//  Huatao
//
//  Created on 2023/1/10.
//

import UIKit

class FindViewController: SSViewController {
    
    @IBOutlet weak var menuStack: UIStackView!
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var travelView: UIView!
    @IBOutlet weak var shopView: UIView!
    @IBOutlet weak var clubView: UIView!
    
    @IBOutlet weak var findTV: UITableView!
    
    lazy var background: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: SS.w, height: 262))
        view.drawGradient(start: .hex("ffeedb"), end: .white, size: view.frame.size, direction: .t2b)
        return view
    }()
    
    lazy var tipBtn: SSButton = {
        let btn = SSButton(type: .custom)
        btn.image = UIImage(named: "ic_notice_fill")
        
        btn.addSubview(countLabel)
        countLabel.snp.makeConstraints { make in
            make.width.height.equalTo(16)
            make.right.equalToSuperview().offset(6)
            make.top.equalToSuperview().offset(-6)
        }
        
        return btn
    }()
    
    lazy var countLabel: UILabel = {
        let lb = UILabel(text: "1", textColor: .white, textFont: .ss_regular(size: 10))
        lb.backgroundColor = .hex("eb2020")
        lb.textAlignment = .center
        lb.loadOption([.cornerRadius(8)])
        lb.isHidden = true
        return lb
    }()
    
    var list: [DynamicListItem] = []
    
    var page: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.ss.showHUDLoading()
        requestData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestNotice()
    }
    
    override func buildUI() {
        view.insertSubview(background, belowSubview: menuStack)
        
        showFakeNavBar()
        fakeNav.backgroundColor = .clear
        fakeNav.titleLabel.font = .ss_semibold(size: 18)
        fakeNav.title = "发现"
        fakeNav.titleColor = .hex("333333")
        
        fakeNav.addSubview(tipBtn)
        tipBtn.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-10)
            make.right.equalToSuperview().offset(-12)
            make.width.height.equalTo(24)
        }
        
        tipBtn.addGesture(.tap) { tap in
            if tap.state == .ended {
                let vc = CircleNoticeViewController.from(sb: .find)
                self.go(vc)
            }
        }
        
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
    
    func requestNotice() {
        HttpApi.Find.getDynamicRedNotice().done { [weak self] data in
            let model = data.kj.model(DynamicRedNoticeModel.self)
            SSMainAsync {
                self?.updateNotice(model.total)
            }
        }
    }
    
    func updateNotice(_ count: Int) {
        countLabel.isHidden = count <= 0
        countLabel.text = "\(min(count, 99))"
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
