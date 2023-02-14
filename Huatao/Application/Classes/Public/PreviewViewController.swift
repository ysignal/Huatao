//
//  PreviewViewController.swift
//  Huatao
//
//  Created on 2023/2/11.
//  
	

import UIKit
import ZLPhotoBrowser

class PreviewViewController: BaseViewController {
    
    lazy var previewCV: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        cv.isPagingEnabled = true
        cv.backgroundColor = .black
        cv.contentInsetAdjustmentBehavior = .never
        cv.register(nibCell: BaseImageItemCell.self)
        return cv
    }()
    
    private var isUpload: Bool = false
    private var list: [String] = []
    private var uploadList: [ZLResultModel] = []
    private var currentPage: Int = 0
    var completeBlock: (([ZLResultModel]) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func buildUI() {
        view.backgroundColor = .black
        fakeNav.backgroundColor = .black
        fakeNav.leftImage = SSImage.backWhite
        fakeNav.titleColor = .white
        
        if isUpload {
            fakeNav.rightButton.title = "删除"
            fakeNav.rightButton.titleFont = UIFont.systemFont(ofSize: 16)
            fakeNav.rightButton.titleColor = .white
            fakeNav.rightButton.isHidden = false
            fakeNav.rightButton.snp.updateConstraints { make in
                make.width.equalTo(40)
            }
            fakeNav.rightButtonHandler = {
                self.toDelete()
            }
            fakeNav.title = "\(currentPage + 1)/\(uploadList.count)"
        } else {
            fakeNav.title = "\(currentPage + 1)/\(list.count)"
        }
        
        view.addSubview(previewCV)
        previewCV.snp.makeConstraints { make in
            make.top.equalTo(SS.statusWithNavBarHeight)
            make.left.right.bottom.equalToSuperview()
        }
        
        previewCV.performBatchUpdates {
            self.previewCV.reloadData()
        } completion: { finished in
            self.previewCV.setContentOffset(CGPoint(x: SS.w * CGFloat(self.currentPage), y: 0), animated: false)
        }
    }
    
    func configPreview(_ data: [String], index: Int) {
        isUpload = false
        list = data
        currentPage = index
    }
    
    func configUpload(_ data: [ZLResultModel], index: Int, complete: (([ZLResultModel]) -> Void)?) {
        completeBlock = complete
        isUpload = true
        uploadList = data
        currentPage = index
    }
    
    func toDelete() {
        guard currentPage < uploadList.count else {
            toast(message: "没有照片可以删除了")
            return
        }
        uploadList.remove(at: currentPage)
        completeBlock?(uploadList)
        previewCV.reloadData()
        
        if currentPage >= list.count {
            currentPage -= 1
        }
        if currentPage < 0 {
            back()
        } else {
            fakeNav.title = "\(currentPage + 1)/\(uploadList.count)"
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension PreviewViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: SS.w, height: SS.h - SS.statusWithNavBarHeight)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == previewCV {
            var page = Int(scrollView.contentOffset.x / SS.w)
            if (scrollView.contentOffset.x - (scrollView.frame.width * CGFloat(page))) > scrollView.frame.width * 0.5 {
                page += 1
            }
            if page != currentPage {
                currentPage = page
                fakeNav.title = "\(page + 1)/\(isUpload ? uploadList.count : list.count)"
            }
        }
    }
}

extension PreviewViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isUpload ? uploadList.count : list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(with: BaseImageItemCell.self, for: indexPath)
        cell.baseImage.contentMode = .scaleAspectFit
        if isUpload {
            let item = uploadList[indexPath.row]
            cell.baseImage.image = item.image
        } else {
            cell.config(url: list[indexPath.row], placeholder: SSImage.photoDefault)
        }
        return cell
    }
    
}
