//
//  NextListViewController.swift
//  Huatao
//
//  Created on 2023/2/23.
//  
	

import UIKit

class NextListViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var list: [ChildrenListItem] = [ChildrenListItem(), ChildrenListItem(), ChildrenListItem(), ChildrenListItem()]
    
    var userId: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.reloadData()
//        requestData()
    }
    
    override func buildUI() {
        fakeNav.title = "下级关系"
        view.backgroundColor = .ss_f6
        
        tableView.tableFooterView = UIView()
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
    }
    
    func requestData() {
        view.ss.showHUDLoading()
        HttpApi.Chat.getChildrenList(userId: userId).done { [weak self] data in
            let listModel = data.kj.model(ListModel<ChildrenListItem>.self)
            self?.list = listModel.list
            SSMainAsync {
                self?.view.ss.hideHUD()
                
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.toast(message: error.localizedDescription)
            }
        }
    }

}

extension NextListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(backgroundColor: .clear)
        let item = list[section]
        
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.cornerRadius = 14
        view.addSubview(iv)
        iv.snp.makeConstraints { make in
            make.width.height.equalTo(38)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(12)
        }
        iv.ss_setImage(item.avatar, placeholder: SSImage.userDefault)
        
        let text = item.name + " (\(item.children.count)人)"
        let lb = UILabel(text: text, textColor: .ss_33, textFont: .ss_regular(size: 16))
        view.addSubview(lb)
        lb.snp.makeConstraints { make in
            make.left.equalTo(iv.snp.right).offset(8)
            make.centerY.equalToSuperview()
            make.right.lessThanOrEqualTo(view).offset(-34)
        }
        
        let image = UIImage(named: "ic_arrow_fill_gray")
        let arrow = UIImageView(image: item.isOpen ? image?.color(.ss_theme) : image)
        view.addSubview(arrow)
        arrow.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-12)
        }
        
        view.addGesture(.tap) { tap in
            if tap.state == .ended {
                self.list[section].isOpen.toggle()
                self.tableView.reloadSections(IndexSet(integer: section), with: .fade)
            }
        }
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
}

extension NextListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let item = list[section]
        return item.isOpen ? item.children.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: NextChildrenItemCell.self)
        let section = list[indexPath.section]
        let item = section.children[indexPath.row]
        cell.config(item: item)
        return cell
    }
    
}
