//
//  UserDetailViewController.swift
//  Huatao
//
//  Created on 2023/2/17.
//  
	

import UIKit

class UserDetailViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var headerView: UIView!

    @IBOutlet weak var userIcon: UIImageView!
    
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var signLabel: UILabel!

    
    var list: [UserFriendItem] = []
    
    var userId: Int = 0
    
    var model = FriendDetailModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        requestData()
    }
    
    override func buildUI() {
        view.backgroundColor = .hex("f6f6f6")
        
        list = [UserFriendItem(type: 1, title: "查找聊天内容"),
                UserFriendItem(type: 2, title: "消息免打扰"),
                UserFriendItem(type: 1, title: "设置备注"),
                UserFriendItem(type: 2, title: "设为星标"),
                UserFriendItem(type: 1, title: "下级关系"),
                UserFriendItem(type: 1, title: "设置当前聊天背景"),
                UserFriendItem(type: 1, title: "清空聊天记录")]
        
        tableView.backgroundColor = .hex("f6f6f6")
        tableView.tableFooterView = UIView()
        tableView.register(nibCell: UserCircleCell.self)
        tableView.register(nibCell: UserFriendItemCell.self)
        
        tableView.reloadData()
    }
    
    func requestData() {
        view.ss.showHUDLoading()
        HttpApi.Chat.getFriendDetail(userId: userId).done { [weak self] data in
            self?.model = data.kj.model(FriendDetailModel.self)
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.updateViews()
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.toast(message: error.localizedDescription)
            }
        }
    }
    
    func updateViews() {
        userIcon.ss_setImage(model.avatar, placeholder: SSImage.userDefault)
        userName.text = model.name
        signLabel.text = model.personSign
        
        let signHeight = model.personSign.height(from: .systemFont(ofSize: 14), width: SS.w - 40)
        headerView.ex_height = 150 + signHeight
        
        tableView.reloadData()
    }

}

extension UserDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 74
        case 1:
            return 54
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
        
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView(backgroundColor: .hex("f6f6f6"))
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}

extension UserDetailViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return list.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(with: UserCircleCell.self)
            cell.config(images: model.images)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(with: UserFriendItemCell.self)
            let item = list[indexPath.row]
            cell.config(item: item)
            return cell
        default:
            break
        }
        return UITableViewCell()
    }
    
}
