//
//  MyTeamViewController.swift
//  Huatao
//
//  Created by minse on 2023/1/18.
//

import UIKit

class MyTeamViewController: BaseViewController {
    
    @IBOutlet weak var teamTV: UITableView!
    
    lazy var headerView: TeamHeaderView = {
        let view = TeamHeaderView.fromNib()
        return view
    }()
    
    var model = MineTeamListModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        requestData()
    }
    
    override func buildUI() {
        fakeNav.title = "我的团队"
        
        headerView.ex_height = 170
        teamTV.tableHeaderView = headerView
        
    }
    
    func requestData() {
        view.ss.showHUDLoading()
        HttpApi.Mine.getMyTeam().done { [weak self] data in
            self?.model = data.kj.model(MineTeamListModel.self)
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.configViews()
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.toast(message: error.localizedDescription)
            }
        }
    }
    
    func configViews() {
        headerView.config(model: model)
        teamTV.reloadData()
    }
    
}

extension MyTeamViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 184
    }
    
}

extension MyTeamViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: TeamMemberCell.self)
        let item = model.list[indexPath.row]
        cell.config(item: item)
        return cell
    }
    
}
