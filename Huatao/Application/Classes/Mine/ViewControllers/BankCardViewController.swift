//
//  BankCardViewController.swift
//  Huatao
//
//  Created on 2023/2/20.
//  
	

import UIKit

class BankCardViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomBtn: UIButton!
    
    private var list: [BankCardItem] = []
    
    private var isEditMode: Bool = false
    
    var completeBlock: StringBlock?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.ss.showHUDLoading()
        requestData()
    }
    
    override func buildUI() {
        fakeNav.title = "我的银行卡"
        
        fakeNav.rightButton.title = "解除绑定"
        fakeNav.rightButton.titleFont = UIFont.systemFont(ofSize: 14)
        fakeNav.rightButton.titleColor = .ss_theme
        fakeNav.rightButton.isHidden = false
        fakeNav.rightButton.snp.updateConstraints { make in
            make.width.equalTo(70)
        }
        fakeNav.rightButtonHandler = {
            self.toEditMode()
        }
        
        bottomBtn.drawThemeGradient(CGSizeMake(SS.w - 24, 40))
        // 移除绑卡说明中间页
        navRemove([CardDescriptionViewController.self, CreateCardViewController.self])
    }
    
    func requestData() {
        HttpApi.Mine.getUserBankList().done { [weak self] data in
            guard let weakSelf = self else { return }
            let listModel = data.kj.model(ListModel<BankCardItem>.self)
            weakSelf.list = listModel.list
            SSMainAsync {
                weakSelf.view.ss.hideHUD()
                weakSelf.tableView.reloadData()
                if weakSelf.list.isEmpty {
                    weakSelf.tableView.showEmpty(true)
                }
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.toast(message: error.localizedDescription)
            }
        }
    }
    
    func toEditMode() {
        isEditMode.toggle()
        if isEditMode {
            tableView.reloadData()
            fakeNav.title = "解除绑定"
            fakeNav.rightButton.title = "取消"
            bottomBtn.isHidden = true
        } else {
            tableView.reloadData()
            fakeNav.title = "我的银行卡"
            fakeNav.rightButton.title = "解除绑定"
            bottomBtn.isHidden = false
        }
    }
    
    func toDelete(_ item: BankCardItem) {
        showConfirm(title: "提示", message: "是否解除当前银行卡绑定?", buttonTitle: "确定", style: .destructive) { [weak self] in
            self?.view.ss.showHUDLoading()
            HttpApi.Mine.deleteBank(bankId: item.bankId).done { _ in
                SSMainAsync {
                    self?.view.ss.hideHUD()
                    self?.toast(message: "已解除绑定")
                    self?.requestData()
                }
            }.catch { error in
                SSMainAsync {
                    self?.view.ss.hideHUD()
                    self?.toast(message: error.localizedDescription)
                }
            }
        }
    }

    @IBAction func bottomClicked(_ sender: Any) {
        let vc = CreateCardViewController.from(sb: .mine)
        vc.completeBlock = { [weak self] in
            self?.requestData()
        }
        go(vc)
    }
    
}

extension BankCardViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 198.scale + 12
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isEditMode {
            return
        }
        let item = list[indexPath.row]
        completeBlock?(item.cardNo)
        if completeBlock != nil {
            back()
        }
    }
    
}

extension BankCardViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: BankCardItemCell.self)
        let item = list[indexPath.row]
        cell.config(item: item, isEditMode: isEditMode) {
            self.toDelete(item)
        }
        return cell
    }
    
}
