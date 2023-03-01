//
//  SelectBackgroundViewController.swift
//  Huatao
//
//  Created on 2023/2/22.
//  
	

import UIKit
import ZLPhotoBrowser

class SelectBackgroundViewController: BaseViewController, UINavigationControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    private lazy var imagePicker: UIImagePickerController = {
        let ip = UIImagePickerController()
        //设置代理
        ip.delegate = self
        //允许编辑
        ip.allowsEditing = false
        //设置资源类型
        ip.sourceType = .camera
        return ip
    }()
    
    var list: [UserFriendItem] = [UserFriendItem(type: 1, title: "从手机相册选择", action: "library"),
                                  UserFriendItem(type: 1, title: "拍一张", action: "camera")]
    
    var userId: Int = 0
        
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func buildUI() {
        fakeNav.title = "聊天背景"

        
        tableView.backgroundColor = .hex("f6f6f6")
        tableView.tableFooterView = UIView()
        tableView.register(nibCell: UserFriendItemCell.self)
    }
    
    func toSystemCamera() {
        // 判断是否支持相机功能
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            self.present(imagePicker, animated: true, completion: nil)
        }
    }

}

extension SelectBackgroundViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }

}

extension SelectBackgroundViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: UserFriendItemCell.self)
        let item = list[indexPath.row]
        cell.config(item: item)
        cell.delegate = self
        return cell
    }
    
}

extension SelectBackgroundViewController: UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let originalImage = info[.originalImage] as? UIImage {
            let vc = ConfirmBackgroundViewController()
            vc.userId = self.userId
            vc.image = originalImage
            self.go(vc)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

extension SelectBackgroundViewController: UserFriendItemCellDelegate {
    
    func cellDidTap(_ item: UserFriendItem) {
        switch item.action {
        case "library":
            let zl = ZLPhotoPreviewSheet()
            ZLPhotoConfiguration.resetConfiguration()
            ZLPhotoConfiguration.default().allowSelectVideo(false).allowRecordVideo(false).maxSelectCount(1).allowEditImage(false)
            zl.selectImageBlock = { images, isFull in
                let vc = ConfirmBackgroundViewController()
                vc.userId = self.userId
                vc.image = images.first?.image
                self.go(vc)
            }
            zl.showPhotoLibrary(sender: self)
        case "camera":
            toSystemCamera()
        default:
            break
        }
    }
    
}
