//
//  TradeCenterViewController.swift
//  Huatao
//
//  Created on 2023/1/21.
//

import UIKit

class TradeCenterViewController: BaseViewController {
    
    @IBOutlet weak var tradeTV: UITableView!
    @IBOutlet weak var saleBtn: UIButton!
    @IBOutlet weak var buyBtn: UIButton!
    
    private lazy var headerView: TradeHeaderView = {
        return TradeHeaderView.fromNib()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.ss.showHUDLoading()
        requestData()
    }
    
    override func buildUI() {
        fakeNav.title = "交易大厅"
        fakeNav.rightButton.title = "交易信息"
        fakeNav.rightButton.titleColor = .ss_theme
        fakeNav.rightButton.isHidden = false
        fakeNav.rightButton.snp.updateConstraints { make in
            make.width.equalTo(70)
        }
        fakeNav.rightButtonHandler = { [weak self] in
            self?.toHistory()
        }
        
        headerView.ex_height = 263 + 62.scale + 205.scale
        tradeTV.tableHeaderView = headerView
        buyBtn.drawThemeGradient(CGSize(width: 220, height: 40))
    }
    
    func requestData() {
        HttpApi.Mine.getTradingHall().done { [weak self] data in
            let model = data.kj.model(TradeHallModel.self)
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.headerView.configData(model: model)
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.toast(message: error.localizedDescription)
            }
        }        
    }
    
    func toHistory() {
        let vc = TradeHistoryViewController.from(sb: .mine)
        go(vc)
    }
    
    @IBAction func toSale(_ sender: Any) {
        let vc = TradeSaleViewController.from(sb: .mine)
        go(vc)
    }

    @IBAction func toBuy(_ sender: Any) {
        let vc = TradeBuyViewController.from(sb: .mine)
        go(vc)
    }
    
}
