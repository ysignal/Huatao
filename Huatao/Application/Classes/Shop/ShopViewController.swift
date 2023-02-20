//
//  ShopViewController.swift
//  Huatao
//
//  Created on 2023/1/10.
//

import UIKit

class ShopViewController: SSViewController {
    
    lazy var background: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: SS.w, height: 358))
        view.drawGradient(start: .hex("ffeedb"), end: .hex("f6f6f6"), size: view.frame.size, direction: .t2b)
        return view
    }()
    
    @IBOutlet weak var shopTV: UITableView!
    
    var list: [ShopGiftItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        requestData()
    }
    
    override func buildUI() {
        view.backgroundColor = .hex("f6f6f6")
        view.insertSubview(background, belowSubview: shopTV)
        
        showFakeNavBar()
        fakeNav.backgroundColor = .clear
        fakeNav.titleLabel.font = .ss_semibold(size: 18)
        fakeNav.title = "商城"
        fakeNav.titleColor = .hex("333333")
                        
        shopTV.register(nibCell: ShopVipSetCell.self)
        shopTV.tableFooterView = UIView()
    }
    
    func requestData() {
        view.ss.showHUDLoading()
        HttpApi.Shop.getGiftList().done { [weak self] data in
            let listModel = data.kj.model(ListModel<ShopGiftItem>.self)
            self?.list = listModel.list
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.shopTV.reloadData()
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.toast(message: error.localizedDescription)
            }
        }
    }

}

extension ShopViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.scale + 12
    }
    
}

extension ShopViewController: UITableViewDataSource {
    
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
