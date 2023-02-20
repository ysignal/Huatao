//
//  AddFriendViewController.swift
//  Huatao
//
//  Created on 2023/2/17.
//  
	

import UIKit

class AddFriendViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var userIcon: UIImageView!
    
    @IBOutlet weak var userName: UILabel!
    
    var userId: Int = 0
    
    private var model = FriendDetailModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestData()
    }
    
    override func buildUI() {
        tableView.backgroundColor = .hex("f6f6f6")
        tableView.tableFooterView = UIView()
        tableView.register(nibCell: UserCircleCell.self)
        tableView.register(nibCell: UserAddFriendCell.self)

        tableView.reloadData()
    }
    
    func requestData() {
        view.ss.showHUDLoading()
        HttpApi.Chat.getFriendDetail(userId: userId).done { [weak self] data in
            self?.model = data.kj.model(FriendDetailModel.self)
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.updateListView()
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.toast(message: error.localizedDescription)
            }
        }
    }
    
    func updateListView() {
        userIcon.ss_setImage(model.avatar, placeholder: SSImage.userDefault)
        userName.text = model.name
        
        tableView.reloadData()
    }

}

extension AddFriendViewController: UITableViewDelegate {
    
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
        switch indexPath.section {
        case 0:
            SS.log("点击了朋友圈")
        case 1:
            if model.isFriend == 1 {
                // 发送消息
                let vc = ConversationViewController()
                vc.conversationType = .ConversationType_PRIVATE
                vc.targetId = "\(model.userId)"
                vc.fakeNav.title = model.name
                go(vc)
            } else {
                let vc = ApplyFriendViewController.from(sb: .chat)
                vc.name = model.name
                vc.userId = model.userId
                go(vc)
            }
        default:
            break
        }
    }
    
}

extension AddFriendViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return model.userId > 0 ? 1 : 0
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
            let cell = tableView.dequeueReusableCell(with: UserAddFriendCell.self)
            cell.config(isFriend: model.isFriend)
            return cell
        default:
            break
        }
        return UITableViewCell()
    }
    
}
