//
//  CardBagViewController.swift
//  Huatao
//
//  Created on 2023/2/13.
//  
	

import UIKit

class CardBagViewController: BaseViewController {
    
    @IBOutlet weak var sectionCV: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    var sections: [WalletTabItem] = [WalletTabItem(title: "兑换卡包"), WalletTabItem(title: "返还中"), WalletTabItem(title: "完成")]
    
    var cardList: [CardListItem] = []
    
    var completeList: [CardListItem] = []
    
    var model = CardReturnModel()
    
    /// 当前所在分页
    var currentPage: Int = 0
    
    /// 卡包数据分页
    var cardPage: Int = 1
    
    /// 已完成卡包数据分页
    var completePage: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        requestData()
    }
    
    override func buildUI() {
        fakeNav.title = "卡包"
        
        tableView.addRefresh(type: .headerAndFooter, delegate: self)
        sectionCV.register(nibCell: WalletTabCell.self)
        
        sectionCV.reloadData()
        SSMainAsync {
            UIView.performWithoutAnimation {
                self.sectionCV.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .centeredHorizontally)
            }
        }
    }
    
    func requestData() {
        requestCardList()
        requestReturnModel()
        requestCompleteList()
    }
    
    func reloadData() {
        if currentPage == 0 {
            cardPage = 1
            requestCardList()
        } else if currentPage == 2 {
            completePage = 1
            requestCompleteList()
        } else {
            requestReturnModel()
        }
    }

    func requestCardList() {
        HttpApi.Mine.getCardList(page: cardPage).done { [weak self] data in
            guard let weakSelf = self else { return }
            let listModel = data.kj.model(ListModel<CardListItem>.self)
            if weakSelf.cardPage == 1 {
                weakSelf.cardList = listModel.list
            } else {
                weakSelf.cardList.append(contentsOf: listModel.list)
            }
            weakSelf.cardList.sort(by: { $0.silverNum.floatValue < $1.silverNum.floatValue })
            SSMainAsync {
                weakSelf.tableView.mj_header?.endRefreshing()
                weakSelf.view.ss.hideHUD()
                if weakSelf.cardList.count >= listModel.total {
                    weakSelf.tableView.mj_footer?.endRefreshingWithNoMoreData()
                } else {
                    weakSelf.tableView.mj_footer?.resetNoMoreData()
                }
                if weakSelf.currentPage == 0 {
                    weakSelf.tableView.reloadData()
                }
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.tableView.endRefresh()
                self?.toast(message: error.localizedDescription)
            }
        }
    }
    
    func requestReturnModel() {
        HttpApi.Mine.getCardReturn().done { [weak self] data in
            self?.model = data.kj.model(CardReturnModel.self)
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.tableView.endRefresh()
                if self?.currentPage == 1 {
                    self?.tableView.reloadData()
                }
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.tableView.endRefresh()
                self?.toast(message: error.localizedDescription)
            }
        }
    }
    
    func requestCompleteList() {
        HttpApi.Mine.getCompleteCardList(page: completePage).done { [weak self] data in
            guard let weakSelf = self else { return }
            let listModel = data.kj.model(ListModel<CardListItem>.self)
            if weakSelf.completePage == 1 {
                weakSelf.completeList = listModel.list
            } else {
                weakSelf.completeList.append(contentsOf: listModel.list)
            }
            SSMainAsync {
                weakSelf.tableView.mj_header?.endRefreshing()
                weakSelf.view.ss.hideHUD()
                if weakSelf.completeList.count >= listModel.total {
                    weakSelf.tableView.mj_footer?.endRefreshingWithNoMoreData()
                } else {
                    weakSelf.tableView.mj_footer?.resetNoMoreData()
                }
                if weakSelf.currentPage == 2 {
                    weakSelf.tableView.reloadData()
                }
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.tableView.endRefresh()
                self?.toast(message: error.localizedDescription)
            }
        }
    }

    func toConversionCard(_ item: CardListItem) {
        view.ss.showHUDLoading()
        HttpApi.Mine.putConversionCard(cardId: item.cardId).done { [weak self] _ in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.toast(message: "兑换成功")
                self?.reloadData()
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.toast(message: error.localizedDescription)
            }
        }
    }
}

extension CardBagViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (SS.w - 24)/3, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentPage = indexPath.row
        tableView.reloadData()
    }
    
}

extension CardBagViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(with: WalletTabCell.self, for: indexPath)
        cell.config(item: sections[indexPath.row])
        return cell
    }
    
}

extension CardBagViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if currentPage == 1 {
            return 85
        }
        return 78 + 104.scale
    }
    
}

extension CardBagViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentPage {
        case 0:
            return cardList.count
        case 1:
            return 1
        case 2:
            return completeList.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch currentPage {
        case 0:
            let cell = tableView.dequeueReusableCell(with: CardListItemCell.self)
            let item = cardList[indexPath.row]
            cell.config(item: item, isComplete: false) {
                self.toConversionCard(item)
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(with: CardRecordItemCell.self)
            cell.config(item: model)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(with: CardListItemCell.self)
            let item = completeList[indexPath.row]
            cell.config(item: item, isComplete: true)
            return cell
        default:
            return UITableViewCell()
        }
    }
}

extension CardBagViewController: UIScrollViewRefreshDelegate {
    
    func scrollViewHeaderRefreshData(_ scrollView: UIScrollView) {
        reloadData()
    }
    
    func scrollViewFooterRefreshData(_ scrollView: UIScrollView) {
        if currentPage == 0 {
            cardPage += 1
            requestCardList()
        } else if currentPage == 2 {
            completePage += 1
            requestCompleteList()
        } else {
            requestReturnModel()
        }
    }
    
}


