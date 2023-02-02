//
//  ForwardPosterViewController.swift
//  Huatao
//
//  Created by minse on 2023/1/25.
//

import UIKit

class ForwardPosterViewController: BaseViewController {
    
    @IBOutlet weak var posterCV: UICollectionView!
    
    var list: [MaterialDetail] = []
    
    var page: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        requestData()
    }
    
    override func buildUI() {
        fakeNav.title = "转发推广海报"
        
        posterCV.register(nibCell: BaseImageItemCell.self)
        posterCV.addRefresh(type: .headerAndFooter, delegate: self)
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
                weakSelf.posterCV.mj_header?.endRefreshing()
                weakSelf.view.ss.hideHUD()
                if weakSelf.list.count >= listModel.total {
                    weakSelf.posterCV.mj_footer?.endRefreshingWithNoMoreData()
                } else {
                    weakSelf.posterCV.mj_footer?.resetNoMoreData()
                }
                weakSelf.posterCV.reloadData()
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.toast(message: error.localizedDescription)
            }
        }
    }

}

extension ForwardPosterViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (SS.w - 36)/2, height: 225)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = list[indexPath.row]
        let vc = PosterDetailViewController.from(sb: .mine)
        vc.model = item
        go(vc)
    }
}

extension ForwardPosterViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(with: BaseImageItemCell.self, for: indexPath)
        let item = list[indexPath.row]
        let url = item.images.first ?? ""
        cell.baseImage.contentMode = url.isEmpty ? .scaleAspectFit : .scaleAspectFill
        cell.config(url: url, placeholder: SSImage.photoDefaultWhite, cornerRadius: 8)
        return cell
    }
    
}

extension ForwardPosterViewController: UIScrollViewRefreshDelegate {
    
    func scrollViewHeaderRefreshData(_ scrollView: UIScrollView) {
        page = 1
        requestData()
    }
    
    func scrollViewFooterRefreshData(_ scrollView: UIScrollView) {
        page += 1
        requestData()
    }
    
}
