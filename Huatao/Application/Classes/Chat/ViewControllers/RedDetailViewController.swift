//
//  RedDetailViewController.swift
//  Huatao
//
//  Created on 2023/3/3.
//  
	

import UIKit

class RedDetailViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var redMessage: UILabel!
    @IBOutlet weak var redMoney: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    var conversationType: RCConversationType = .ConversationType_PRIVATE
    
    var redId: Int = 0
    
    var targetId: String = ""
    
    var messageId: Int = 0
    
    var isopen: String = ""
    
    var unit: String = ""
    
    var model = RCRedModel()
    
    var detailModel = RedDetailModel()
    
    /// 是否发送者
    var isSender: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func buildUI() {
        fakeNav.leftImage = SSImage.backWhite
        fakeNav.backgroundColor = .hex("c8453d")
        fakeNav.titleColor = .white
        fakeNav.title = "红包"
        
        userIcon.ss_setImage(model.avatar, placeholder: SSImage.userDefault)
        userName.text = model.name
        redMessage.text = model.message
        
        unit = model.type == 0 ? "银豆" : "元"
        unitLabel.text = unit
        redMoney.text = String(format: "%.02f", model.money.floatValue).fixedZero()
    
        unitLabel.isHidden = true
        redMoney.isHidden = true
        
        if isSender {
            headerView.ex_height = 280
            if isopen == "1" {
                descLabel.text = "1个红包共\(String(format: "%.02f", model.money.floatValue).fixedZero())\(unit)"
            } else {
                descLabel.text = "红包金额\(String(format: "%.02f", model.money.floatValue).fixedZero())\(unit)，等待对方领取"
            }
        } else {
            if conversationType == .ConversationType_PRIVATE {
                requestUserRed()
                unitLabel.isHidden = false
                redMoney.isHidden = false
            } else {
                requestTeamRed()
            }
        }
        
        tableView.tableFooterView = UIView()
    }
    
    func updateListViews() {
        
    }
    
    func requestUserRed() {
        view.ss.showHUDLoading()
        HttpApi.Chat.putGetUserRed(sendRedId: redId).done { [weak self] data in
            self?.detailModel = data.kj.model(RedDetailModel.self)
            guard let weakSelf = self else { return }
            SSMainAsync {
                weakSelf.view.ss.hideHUD()
                weakSelf.unitLabel.isHidden = false
                weakSelf.redMoney.isHidden = false
                RCIMClient.shared().updateMessageExpansion(["isopen": "1"], messageUId: "\(weakSelf.messageId)", success: nil)
                weakSelf.tableView.reloadData()
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.toast(message: error.localizedDescription)
            }
        }
    }
    
    func requestTeamRed() {
        
    }
    
}

extension RedDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
}

extension RedDetailViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailModel.redDetail.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: RedDetailUserCell.self)
        let item = detailModel.redDetail.list[indexPath.row]
        cell.config(item: item, unit: unit)
        return cell
    }
    
}
