//
//  MineViewController.swift
//  Huatao
//
//  Created on 2023/1/10.
//

import UIKit

class MineViewController: SSViewController {

    @IBOutlet weak var tableView: UITableView!
    
    lazy var background: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: SS.w, height: 262))
        view.drawGradient(start: .hex("ffeedb"), end: .hex("f6f6f6"), size: view.frame.size, direction: .t2b)
        return view
    }()
    
    lazy var headerView: MineHeaderView = {
        let view = MineHeaderView.fromNib()
        view.delegate = self
        return view
    }()
    
    lazy var settingBtn: SSButton = {
        let btn = SSButton(type: .custom)
        btn.image = UIImage(named: "ic_mine_setting")
        return btn
    }()
    
    lazy var messageBtn: SSButton = {
        let btn = SSButton(type: .custom)
        btn.image = UIImage(named: "ic_mine_message")
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestUserInfo()
    }
    
    override func buildUI() {
        view.backgroundColor = .hex("f6f6f6")
        view.insertSubview(background, belowSubview: tableView)
        
        showFakeNavBar()
        fakeNav.backgroundColor = .clear
        fakeNav.titleLabel.font = .ss_semibold(size: 18)
        fakeNav.title = "个人中心"
        fakeNav.titleColor = .hex("333333")
        
        fakeNav.addSubview(settingBtn)
        settingBtn.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.right.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-10)
        }
        settingBtn.addTarget(self, action: #selector(toSetting), for: .touchUpInside)
        
        fakeNav.addSubview(messageBtn)
        messageBtn.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.right.equalTo(settingBtn.snp.left).offset(-16)
            make.bottom.equalToSuperview().offset(-10)
        }
        messageBtn.addTarget(self, action: #selector(toMessage), for: .touchUpInside)
        messageBtn.isHidden = true
        
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = UIView()
        
        tableView.reloadData()
        
    }
    
    func requestUserInfo() {
        APP.updateUserInfo {
            self.updateViews()
        }
    }
    
    func updateViews() {
        headerView.config()
    }
    
    func itemClicked(_ item: MineMenuItem) {
        let vc = item.vcType.from(sb: .mine)
        go(vc)
    }
    
    @objc func toMessage() {
        
    }
    
    @objc func toSetting() {
        let vc = SettingViewController.from(sb: .mine)
        go(vc)
    }
}

extension MineViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var line = MineModel.menuList.count / 4
        if MineModel.menuList.count % 4 > 0 {
            line += 1
        }
        return CGFloat(line) * 100 + 46
    }
    
}

extension MineViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: MineMemuListCell.self)
        cell.config(delegate: self)
        return cell
    }
    
}

extension MineViewController: MineMemuListCellDelegate {
    
    func cellClickedItem(_ item: MineMenuItem) {
        itemClicked(item)
    }
    
}

extension MineViewController: MineHeaderViewDelegate {

    func headerViewWillStartAction(_ action: MineHeaderView.HeaderAction) {
        switch action {
        case .edit:
            let vc = MineEditViewController.from(sb: .mine)
            go(vc)
        case .vip:
            let vc = VipRuleViewController.from(sb: .mine)
            go(vc)
        case .card:
            let vc = CardBagViewController.from(sb: .mine)
            go(vc)
        case .bean:
            let vc = MyWalletViewController.from(sb: .mine)
            go(vc)
        case .ticket:
            let vc = MyTicketViewController.from(sb: .mine)
            go(vc)
        case .money:
            let vc = MyMoneyViewController.from(sb: .mine)
            go(vc)
        }
    }

}
