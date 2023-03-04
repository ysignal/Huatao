//
//  CirclePublishViewController.swift
//  Huatao
//
//  Created on 2023/1/29.
//

import UIKit
import ZLPhotoBrowser

class CirclePublishViewController: BaseViewController {
    
    @IBOutlet weak var textView: SSTextView!
    @IBOutlet weak var imageCV: UICollectionView!
    @IBOutlet weak var publishBtn: UIButton!
    
    private var maxCount: Int = 9
    
    var list: [ZLResultModel] = []
    
    var videoModel: ZLResultModel?
    
    var completeBlock: NoneBlock?
    
    var videoUrl: String = ""
    
    var uploadList: [AvatarUrl] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func buildUI() {
        fakeNav.title = "发布动态"
        
        imageCV.register(nibCell: BaseImageItemCell.self)
    }
    
    func toPickerImage() {
        let zl = ZLPhotoPreviewSheet()
        ZLPhotoConfiguration.resetConfiguration()
        ZLPhotoConfiguration.default().allowSelectVideo(false).allowRecordVideo(false).maxSelectCount(9 - list.count)
        
        zl.selectImageBlock = { images, isFull in
            self.list.append(contentsOf: images)
            self.imageCV.reloadData()
        }
        zl.showPhotoLibrary(sender: self)
    }
    
    func toPickerVideo() {
        let zl = ZLPhotoPreviewSheet()
        ZLPhotoConfiguration.resetConfiguration()
        ZLPhotoConfiguration.default().allowSelectImage(false).allowRecordVideo(true).allowEditVideo(false).maxSelectCount(1)
        
        zl.selectImageBlock = { [weak self] images, isFull in
            self?.videoModel = images.first
            self?.imageCV.reloadData()
        }
        zl.showPhotoLibrary(sender: self)
    }

    @IBAction func toPublish(_ sender: Any) {
        if let model = videoModel, videoUrl.isEmpty {
            sendVideo(model: model)
        } else if list.count > 0 {
            sendImages(list, index: 0)
        } else {
            requestPublish()
        }
    }
    
    func sendImages(_ images: [ZLResultModel], index: Int) {
        if index < images.count {
            let item = images[index]
            let compactName = Date().compactString
            let text = "\(index + 1)/\(images.count)"
            if let data = item.image.compress(maxSize: 200*1024) {
                view.ss.showHUDProgress(0, title: "图片上传", text: text)
                HttpApi.File.uploadImage(data: data, fileName: "\(compactName)_\(index+1).png",
                                         uploadProgress: { [weak self] progress in
                    SSMainAsync {
                        self?.view.ss.showHUDProgress(progress, title: "图片上传", text: text)
                    }
                }).done { [weak self] data in
                    let model = data.kj.model(AvatarUrl.self)
                    self?.uploadList.append(model)
                    SSMainAsync {
                        self?.view.ss.hideHUD()
                        self?.sendImages(images, index: index + 1)
                    }
                }.catch { [weak self] error in
                    SSMainAsync {
                        self?.view.ss.hideHUD()
                        self?.sendImages(images, index: index + 1)
                    }
                }
            }
        } else {
            requestPublish()
        }
    }
    
    func sendVideo(model: ZLResultModel) {
        SS.keyWindow?.ss.showHUDLoading(text: "视频解析中")
        _ = SSPhotoManager.fetchAVAsset(forVideo: model.asset) { [weak self] avAsset, info in
            if let urlAsset = avAsset as? AVURLAsset,
               let data = try? Data(contentsOf: urlAsset.url) {
                let suffix = urlAsset.url.pathExtension
                SS.keyWindow?.ss.showHUDProgress(0, title: "视频上传", text: "1/1")
                HttpApi.File.uploadImage(data: data, fileName: "charmVideo.\(suffix)", uploadProgress: { progress in
                    SS.keyWindow?.ss.showHUDProgress(progress, title: "视频上传", text: "1/1")
                }).done { data in
                    let model = data.kj.model(AvatarUrl.self)
                    self?.videoUrl = model.allUrl
                    SSMainAsync {
                        SS.keyWindow?.ss.hideHUD()
                        self?.requestPublish()
                    }
                }.catch { error in
                    SSMainAsync {
                        SS.keyWindow?.ss.hideHUD()
                        self?.toast(message: error.localizedDescription)
                    }
                }
            } else {
                SS.keyWindow?.ss.hideHUD()
                self?.toast(message: "视频解析失败！")
            }
        }
    }
    
    func requestPublish() {
        view.ss.showHUDLoading()
        let text = textView.text ?? ""
        if !videoUrl.isEmpty {
            HttpApi.Find.postVideoDynamic(content: text, video: videoUrl).done { [weak self] _ in
                SSMainAsync {
                    self?.view.ss.hideHUD()
                    self?.completeBlock?()
                    self?.globalToast(message: "发布成功")
                    self?.back()
                }
            }.catch { [weak self] error in
                SSMainAsync {
                    self?.view.ss.hideHUD()
                    self?.toast(message: error.localizedDescription)
                }
            }
        } else {
            HttpApi.Find.postImageDynamic(content: text, images: uploadList.compactMap({ $0.allUrl })).done { [weak self] _ in
                SSMainAsync {
                    self?.view.ss.hideHUD()
                    self?.completeBlock?()
                    self?.globalToast(message: "发布成功")
                    self?.back()
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

extension CirclePublishViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.markedTextRange == nil, let text = textView.text {
            if !text.isEmpty {
                publishBtn.drawThemeGradient(CGSize(width: SS.w - 24, height: 40))
                publishBtn.isUserInteractionEnabled = true
            } else {
                publishBtn.drawDisable(CGSize(width: SS.w - 24, height: 40))
                publishBtn.isUserInteractionEnabled = false
            }
        }
    }
    
}

extension CirclePublishViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row >= list.count {
            if let _ = videoModel {
                self.toPickerVideo()
                return
            }
            if !list.isEmpty {
                toPickerImage()
                return
            }
            BaseActionSheetView.show(list: ["添加照片", "添加视频"]) { index in
                switch index {
                case 0:
                    self.toPickerImage()
                case 1:
                    self.toPickerVideo()
                default:
                    break
                }
            }
        } else {
            let vc = PreviewViewController()
            vc.configUpload(list, index: indexPath.row) { [weak self] data in
                self?.list = data
                collectionView.reloadData()
            }
            go(vc)
        }
    }
    
}

extension CirclePublishViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let _ = videoModel {
            return 1
        }
        return list.count < maxCount ? list.count + 1 : list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(with: BaseImageItemCell.self, for: indexPath)
        if let model = videoModel {
            cell.baseImage.image = model.image
            return cell
        }
        if indexPath.row >= list.count {
            cell.baseImage.image = UIImage(named: "btn_image_add_fill")
        } else {
            let item = list[indexPath.row]
            cell.baseImage.image = item.image
        }
        return cell
    }
    
}
