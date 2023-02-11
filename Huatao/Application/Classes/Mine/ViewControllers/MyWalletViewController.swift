//
//  MyWalletViewController.swift
//  Huatao
//
//  Created on 2023/1/24.
//

import UIKit

struct WalletTabItem {
    
    var title: String = ""
    
    var value: Int = 0
    
}

class MyWalletViewController: BaseViewController {
    
    lazy var background: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: SS.w, height: 262))
        view.drawGradient(start: .hex("fff1e2"), end: .hex("f6f6f6"), size: view.frame.size, direction: .t2b)
        return view
    }()
    
    @IBOutlet weak var walletTV: UITableView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var convertBtn: SSButton!
    
    @IBOutlet weak var sliverLabel: UILabel!
    @IBOutlet weak var goldenLabel: UILabel!
    @IBOutlet weak var coinLabel: UILabel!
    @IBOutlet weak var moneyLabel: UILabel!
    
    @IBOutlet weak var sectionCV: UICollectionView!
    @IBOutlet weak var typeCV: UICollectionView!
    
    private var model = MyBagModel()
    
    private var wayList: [WalletTabItem] = [WalletTabItem(title: "银豆", value: 1),
                                    WalletTabItem(title: "金豆", value: 2),
                                    WalletTabItem(title: "贡献值", value: 3),
                                    WalletTabItem(title: "余额", value: 0)]
    private var typeList: [WalletTabItem] = [WalletTabItem(title: "收入", value: 1),
                                     WalletTabItem(title: "支出", value: 0)]
    
    private var list: [WalletRecordItem] = []
    
    private var page: Int = 1
    
    private var way: Int = 1
    
    private var type: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        requestData()
    }
    
    override func buildUI() {
        view.backgroundColor = .hex("f6f6f6")
        fakeNav.backgroundColor = .clear
        fakeNav.title = "我的钱包"
        view.insertSubview(background, belowSubview: walletTV)
        
        convertBtn.drawGradient(start: .hex("FFA300"), end: .hex("FF8100"), size: CGSize(width: 44, height: 20))
        
        walletTV.addRefresh(type: .headerAndFooter, delegate: self)
        sectionCV.register(nibCell: WalletTabCell.self)
        typeCV.register(nibCell: WalletTabCell.self)
        
        sectionCV.reloadData()
        typeCV.reloadData()
        SSMainAsync {
            UIView.performWithoutAnimation {
                self.sectionCV.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .centeredHorizontally)
                self.typeCV.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .centeredHorizontally)
            }
        }
    }
    
    func requestData() {
        view.ss.showHUDLoading()
        requestMyBag()
        requestRecordList()
    }
    
    func requestMyBag() {
        HttpApi.Mine.getMyBag().done { [weak self] data in
            self?.model = data.kj.model(MyBagModel.self)
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.updateHeaderView()
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.toast(message: error.localizedDescription)
            }
        }
    }
    
    func updateHeaderView() {
        sliverLabel.text = model.silverBean.fixedZero()
        goldenLabel.text = model.goldBean.fixedZero()
        moneyLabel.text = model.money.fixedZero()
        coinLabel.text = model.contributionValue.fixedZero()
    }
    
    func requestRecordList() {
        HttpApi.Mine.getRecordList(way: way, type: type, page: page).done { [weak self] data in
            guard let weakSelf = self else { return }
            let listModel = data.kj.model(ListModel<WalletRecordItem>.self)
            if weakSelf.page == 1 {
                weakSelf.list = listModel.list
            } else {
                weakSelf.list.append(contentsOf: listModel.list)
            }
            SSMainAsync {
                weakSelf.walletTV.mj_header?.endRefreshing()
                weakSelf.view.ss.hideHUD()
                if weakSelf.list.count >= listModel.total {
                    weakSelf.walletTV.mj_footer?.endRefreshingWithNoMoreData()
                } else {
                    weakSelf.walletTV.mj_footer?.resetNoMoreData()
                }
                weakSelf.walletTV.reloadData()
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.walletTV.endRefresh()
                self?.toast(message: error.localizedDescription)
            }
        }
    }
    
    @IBAction func toConvert(_ sender: Any) {
        let vc = BeanConvertViewController.from(sb: .mine)
        vc.changedBlock = { [weak self] in
            self?.requestMyBag()
            self?.page = 1
            self?.requestRecordList()
        }
        go(vc)
    }
    
}

extension MyWalletViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(list.count)*32 + 36
    }
    
}

extension MyWalletViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.isEmpty ? 0 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: WalletListCell.self)
        cell.config(data: list)
        return cell
    }
    
}

extension MyWalletViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == sectionCV {
            return CGSize(width: (SS.w - 24)/4, height: 54)
        }
        return CGSize(width: (SS.w - 24)/2, height: 36)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == sectionCV {
            let item = wayList[indexPath.row]
            if way == item.value {
                return
            }
            way = item.value
            page = 1
            view.ss.showHUDLoading()
            requestRecordList()
        } else {
            let item = typeList[indexPath.row]
            if type == item.value {
                return
            }
            type = item.value
            page = 1
            view.ss.showHUDLoading()
            requestRecordList()
        }
    }
    
}

extension MyWalletViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == sectionCV {
            return wayList.count
        }
        return typeList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(with: WalletTabCell.self, for: indexPath)
        let tabList = collectionView == sectionCV ? wayList : typeList
        let item = tabList[indexPath.row]
        cell.config(item: item)
        return cell
    }
    
}

extension MyWalletViewController: UIScrollViewRefreshDelegate {
    
    func scrollViewHeaderRefreshData(_ scrollView: UIScrollView) {
        page = 1
        requestRecordList()
    }
    
    func scrollViewFooterRefreshData(_ scrollView: UIScrollView) {
        page += 1
        requestRecordList()
    }
    
}

