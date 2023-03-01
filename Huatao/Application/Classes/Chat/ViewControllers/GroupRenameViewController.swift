//
//  GroupRenameViewController.swift
//  Huatao
//
//  Created on 2023/2/21.
//  
	

import UIKit

class GroupRenameViewController: BaseViewController {
    
    enum RenameType {
        case group
        case user
        case friend
    }
    
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    var oldName: String = ""
    
    var name: String = ""
    
    var targetId: Int = 0
    
    var completeBlock: StringBlock?
    
    var maxLength: Int = 8
    
    var type: RenameType = .group

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func buildUI() {
        switch type {
        case .group:
            fakeNav.title = "修改群名"
            descLabel.text = "修改群名称后，将会在群内通知其他成员"
        case .user:
            fakeNav.title = "修改群昵称"
            descLabel.text = "昵称修改后，只会在群组内部显示，群内成员都可以看到"
        case .friend:
            fakeNav.title = "设置昵称备注"
            descLabel.text = "昵称备注修改后，仅自己可见"
            nameTF.placeholder = oldName
            if name.isEmpty {
                name = oldName
            }
        }
        
        countLabel.text = "\(min(name.count, maxLength))/\(maxLength)"
        nameTF.text = name
        nameTF.maxLength = maxLength
    }
    
    func toSave() {
        nameTF.resignFirstResponder()
        let name = nameTF.text ?? ""
        if name.isEmpty {
            switch type {
            case .group:
                toast(message: "群名称不能为空")
                return
            case .user:
                toast(message: "群昵称不能为空")
                return
            case .friend:
                break
            }
        }
        
        switch type {
        case .group:
            toUpdateGroupName(name)
        case .user:
            toUpdateGroupUserName(name)
        case .friend:
            toUpdateUserRemark(name.isEmpty ? oldName : name)
        }
    }
    
    func toUpdateUserRemark(_ name: String) {
        view.ss.showHUDLoading()
        HttpApi.Chat.putFriendDetail(userId: targetId, name: name).done { [weak self] _ in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.completeBlock?(name)
                self?.back()
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.toast(message: error.localizedDescription)
            }
        }
    }
    
    func toUpdateGroupUserName(_ name: String) {
        view.ss.showHUDLoading()
        HttpApi.Chat.putTeamRename(teamId: targetId, rename: name).done { [weak self] _ in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.completeBlock?(name)
                self?.back()
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.toast(message: error.localizedDescription)
            }
        }
    }
    
    func toUpdateGroupName(_ name: String) {
        view.ss.showHUDLoading()
        HttpApi.Chat.putTeamEdit(title: name, teamId: targetId).done { [weak self] _ in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.completeBlock?(name)
                self?.back()
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.toast(message: error.localizedDescription)
            }
        }
    }
    
    @IBAction func textFieldChange(_ sender: UITextField) {
        if sender.markedTextRange == nil, let text = sender.text {
            name = text
            countLabel.text = "\(min(text.count, maxLength))/\(maxLength)"
        }
    }

}

extension GroupRenameViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        toSave()
        return true
    }
    
}
