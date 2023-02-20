//
//  MineEditViewController.swift
//  Huatao
//
//  Created on 2023/2/16.
//  
	

import UIKit
import ZLPhotoBrowser

struct MineEditModel {
    
    var title: String = ""
    
    /// 类型，0-无类型，1-头像类型，2-文本类型，3-无交互
    var type: Int = 0
    
    var content: String = ""
    
    var result: ZLResultModel?
    
}

class MineEditViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var list: [MineEditModel] = []
    
    var result: ZLResultModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        requestUserInfo()
    }

    override func buildUI() {
        view.backgroundColor = .hex("f6f6f6")
        fakeNav.title = "个人信息"
        
        tableView.tableFooterView = UIView()
        updateListView()
    }
    
    func requestUserInfo() {
        APP.updateUserInfo {
            self.updateListView()
        }
    }
    
    func updateListView() {
        list = [MineEditModel(title: "个人头像", type: 1, result: result),
                MineEditModel(title: "昵称", type: 2, content: APP.userInfo.name),
                MineEditModel(title: "登录手机号", type: 3, content: APP.userInfo.mobile),
                MineEditModel(title: "我的二维码", type: 0),
                MineEditModel(title: "职业", type: 2, content: APP.userInfo.jobName),
                MineEditModel(title: "个人签名", type: 2, content: APP.userInfo.personSign)]
        tableView.reloadData()
    }
    
    func toPickerImage() {
        let zl = ZLPhotoPreviewSheet()
        ZLPhotoConfiguration.default().allowSelectVideo(false).allowRecordVideo(false).maxSelectCount(1)
        
        zl.selectImageBlock = { images, isFull in
            self.result = images.first
            self.sendImages()
        }
        zl.showPhotoLibrary(sender: self)
    }

    func sendImages() {
        if let item = result {
            let compactName = Date().compactString
            if let data = item.image.compress(maxSize: 200*1024) {
                view.ss.showHUDProgress(0, title: "图片上传")
                HttpApi.File.uploadImage(data: data, fileName: "\(compactName).png",
                                         uploadProgress: { [weak self] progress in
                    SSMainAsync {
                        self?.view.ss.showHUDProgress(progress, title: "图片上传")
                    }
                }).done { [weak self] data in
                    let model = data.kj.model(AvatarUrl.self)
                    SSMainAsync {
                        self?.view.ss.hideHUD()
                        self?.saveAvatar(avatar: model.allUrl)
                    }
                }.catch { [weak self] error in
                    SSMainAsync {
                        self?.view.ss.hideHUD()
                        self?.toast(message: error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func saveAvatar(avatar: String) {
        HttpApi.Mine.putMyAvatar(avatar: avatar).done { [weak self] _ in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.toast(message: "更新成功")
                self?.requestUserInfo()
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.toast(message: error.localizedDescription)
            }
        }
    }
}

extension MineEditViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = list[indexPath.row]
        if item.type == 1 {
            return 92
        }
        return 52
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            toPickerImage()
        case 1:
            let vc = EditDetailViewController.from(sb: .mine)
            vc.type = .name
            vc.content = APP.userInfo.name
            vc.updateBlock = {
                self.requestUserInfo()
            }
            go(vc)
        case 3:
            let vc = MyCodeViewController.from(sb: .chat)
            go(vc)
        case 4:
            let vc = EditDetailViewController.from(sb: .mine)
            vc.type = .job
            vc.content = APP.userInfo.jobName
            vc.updateBlock = {
                self.requestUserInfo()
            }
            go(vc)
        case 5:
            let vc = EditDetailViewController.from(sb: .mine)
            vc.type = .sign
            vc.sign = APP.userInfo.personSign
            vc.updateBlock = {
                self.requestUserInfo()
            }
            go(vc)
        default:
            break
        }
    }
    
}

extension MineEditViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: MineEditItemCell.self)
        let item = list[indexPath.row]
        cell.config(item: item)
        return cell
    }
    
}
