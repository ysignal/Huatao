//
//  TurnPromoteViewController.swift
//  Huatao
//
//  Created on 2023/2/24.
//  
	

import UIKit
import ZLPhotoBrowser

class TurnPromoteViewController: BaseViewController {
    
    @IBOutlet weak var promoteCV: UICollectionView!
    
    lazy var danmuView: DanMuView = {
        return DanMuView()
    }()
    
    lazy var completeBtn: SSButton = {
        let btn = SSButton(type: .custom)
        btn.loadOption([.titleColor(.white), .font(.ss_regular(size: 14)), .backgroundColor(.ss_theme), .cornerRadius(4), .title("提交")])
        return btn
    }()
    
    var list: [MaterialDetail] = []
    
    var records: [TurnRecordListItem] = []
    
    var page: Int = 1
    
    var currentIndex: Int = 0
    
    var result: ZLResultModel?
    
    var completeBlock: NoneBlock?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    override func buildUI() {
        view.backgroundColor = .ss_f6
        fakeNav.title = "转发推广海报"
        fakeNav.leftButtonHandler = {
            self.danmuView.destroy()
            self.back()
        }
        
        fakeNav.addSubview(completeBtn)
        completeBtn.snp.makeConstraints { make in
            make.width.equalTo(50)
            make.height.equalTo(26)
            make.right.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-9)
        }
        completeBtn.addTarget(self, action: #selector(toComplete), for: .touchUpInside)
        
        promoteCV.backgroundColor = .clear
        danmuView.dataSource = self
    }
    
    func requestData() {
        view.ss.showHUDLoading()
        HttpApi.Task.getSendMaterialList(page: page).done { [weak self] data in
            guard let weakSelf = self else { return }
            let listModel = data.kj.model(ListModel<MaterialDetail>.self)
            if weakSelf.page == 1 {
                weakSelf.list = listModel.list
            } else {
                weakSelf.list.append(contentsOf: listModel.list)
            }
            SSMainAsync {
                weakSelf.view.ss.hideHUD()
                if weakSelf.list.count < listModel.total {
                    weakSelf.requestData()
                }
                weakSelf.promoteCV.reloadData()
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.toast(message: error.localizedDescription)
            }
        }
        HttpApi.Task.getTurnRecordList(page: 1).done { [weak self] data in
            guard let weakSelf = self else { return }
            let listModel = data.kj.model(ListModel<TurnRecordListItem>.self)
            weakSelf.records = listModel.list
            SSMainAsync {
                weakSelf.danmuView.show(offsetY: SS.statusWithNavBarHeight, row: 2, data: weakSelf.records, in: weakSelf.view)
            }
        }
    }
    
    func toPickerImage() {
        let zl = ZLPhotoPreviewSheet()
        ZLPhotoConfiguration.resetConfiguration()
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
        HttpApi.Task.postTaskUpload(image: avatar).done { [weak self] _ in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.toast(message: "提交成功")
                self?.completeBlock?()
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.toast(message: error.localizedDescription)
            }
        }
    }
    
    @objc func toComplete() {
        toPickerImage()
    }
    
    @IBAction func toSelectText(_ sender: Any) {
        PromoteTextSelectView.show()
    }
    
}

extension TurnPromoteViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: SS.w - 82, height: SS.h - SS.statusWithNavBarHeight - SS.safeBottomHeight)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = SS.w - 82
        var page = Int(floor(scrollView.contentOffset.x / width))
        if (scrollView.contentOffset.x - (width * CGFloat(page))) > width * 0.5 {
            page += 1
        }
        if (page != currentIndex) {
            currentIndex = page
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let width = SS.w - 82
        var page = Int(floor(targetContentOffset.pointee.x / width))
        if (targetContentOffset.pointee.x - (width * CGFloat(page))) > width * 0.5 {
            page += 1
        }
        // 限制自动滚动最多滑到下一页
        if page > currentIndex + 1 {
            page = currentIndex + 1
        }
        if page < currentIndex - 1 {
            page = currentIndex - 1
        }
        targetContentOffset.pointee = scrollView.contentOffset
        scrollView.setContentOffset(CGPoint(x: width * CGFloat(page), y: 0), animated: true)
    }
    
}

extension TurnPromoteViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(with: PromoteItemCell.self, for: indexPath)
        let item = list[indexPath.row]
        cell.config(item: item)
        return cell
    }
    
}

extension TurnPromoteViewController: DanMuViewDataSource {
    
    func danmuTouchView() -> UIView? {
        return promoteCV
    }
    
}
