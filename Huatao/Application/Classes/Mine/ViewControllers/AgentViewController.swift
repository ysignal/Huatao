//
//  AgentViewController.swift
//  Huatao
//
//  Created on 2023/2/13.
//  
	

import UIKit

class AgentViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var mobileTF: UITextField!
    @IBOutlet weak var areaLabel: UILabel!
    
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var sectionHeader: UIView!
    @IBOutlet weak var sectionFooter: UIView!
    
    var list: [AgentListItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.ss.showHUDLoading()
        requestData()
    }
    
    override func buildUI() {
        fakeNav.title = "成为代理商"
        
        tableView.estimatedSectionFooterHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        sectionHeader.loadOption([.cornerCut(8, [.topLeft, .topRight], CGSize(width: SS.w - 24, height: 44))])
        sectionFooter.loadOption([.cornerCut(8, [.bottomLeft, .bottomRight], CGSize(width: SS.w - 24, height: 16))])
    }
    
    func requestData() {
        HttpApi.Mine.getAgentList().done { [weak self] data in
            let listModel = data.kj.model(ListModel<AgentListItem>.self)
            self?.list = listModel.list
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.tableView.reloadData()
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.toast(message: error.localizedDescription)
            }
        }
    }

}

extension AgentViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(backgroundColor: .hex("f6f6f6"))
        
        let mainView = UIView(backgroundColor: .white)
        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.top.bottom.equalToSuperview()
        }
        
        let item = list[section]

        let lb = UILabel(text: item.name, textColor: .hex("333333"), textFont: .systemFont(ofSize: 12))
        mainView.addSubview(lb)
        lb.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
        }
        
        view.addGesture(.tap) { tap in
            if tap.state == .ended {
                self.list[section].isOpen.toggle()
                tableView.reloadData()
            }
        }
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
}

extension AgentViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let item = list[section]
        return item.isOpen ? item.children.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: AgentUserItemCell.self)
        let section = list[indexPath.section]
        let item = section.children[indexPath.row]
        cell.config(item: item)
        return cell
    }
    
}
