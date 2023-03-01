//
//  VipJoinViewController.swift
//  Huatao
//
//  Created on 2023/2/11.
//  
	

import UIKit

class VipJoinViewController: BaseViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerViewWidth: NSLayoutConstraint!
    @IBOutlet weak var bagTV: UITableView!
    @IBOutlet weak var bagTVHeight: NSLayoutConstraint!
    @IBOutlet weak var bagTVTop: NSLayoutConstraint!
    
    var list: [ShopGiftItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        requestData()
    }
    
    override func buildUI() {
        fakeNav.title = "成为会员"
        
        containerViewWidth.constant = SS.w
        bagTVHeight.constant = 360.scale + 60
        
        bagTV.register(nibCell: ShopVipSetCell.self)
        bagTV.tableFooterView = UIView()
        bagTVTop.constant = 791.scale
    }
    
    func requestData() {
        view.ss.showHUDLoading()
        HttpApi.Shop.getGiftList().done { [weak self] data in
            let listModel = data.kj.model(ListModel<ShopGiftItem>.self)
            self?.list = listModel.list
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.bagTV.reloadData()
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.toast(message: error.localizedDescription)
            }
        }
    }

    func buyitem(_ item: ShopGiftItem) {
        PayWaySelectView.show(item) { [weak self] payType in
            guard let weakSelf = self else { return }
            if !PayManager.checkIsCanPay(payType) {
                return
            }
            SS.keyWindow?.ss.showHUDLoading()
            HttpApi.Shop.postGiftPay(giftId: item.giftId, payType: payType).done { data in
                SSMainAsync {
                    SS.keyWindow?.ss.hideHUD()
                }
                let model = data.kj.model(PayResultModel.self)
                switch payType {
                case "alipay":
                    PayManager.alipayPay(model.alipay) {
                        weakSelf.toast(message: "购买成功")
                    }
                default:
                    break
                }
            }.catch { error in
                SSMainAsync {
                    SS.keyWindow?.ss.hideHUD()
                    SS.keyWindow?.toast(message: error.localizedDescription)
                }
            }
        }
    }
}

extension VipJoinViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.scale + 12
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = list[indexPath.row]
        buyitem(item)
    }
    
}

extension VipJoinViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: ShopVipSetCell.self)
        let item = list[indexPath.row]
        cell.config(item: item)
        return cell
    }
}
