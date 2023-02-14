//
//  VipBagViewController.swift
//  Huatao
//
//  Created on 2023/2/11.
//  
	

import UIKit

class VipBagViewController: BaseViewController {
    
    @IBOutlet weak var bagTV: UITableView!
    
    var list: [ShopGiftItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestData()

    }
    
    override func buildUI() {
        fakeNav.title = "会员礼包"
        
        bagTV.register(nibCell: ShopVipSetCell.self)
        bagTV.tableFooterView = UIView()
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

}

extension VipBagViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.scale + 12
    }
    
}

extension VipBagViewController: UITableViewDataSource {
    
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
