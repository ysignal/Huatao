//
//  SSGenericCollectionViewController.swift
//  Huatao
//
//  Created on 2023/1/13.
//

import UIKit
import MJRefresh

/// 泛型的CollectionViewController
/// 适合单层数据结构的列表
/// 只需要定义api, model, cell就能完成页面
/// 能自动完成网络请求, 模型解析, 数据加载, 上下拉刷新, 空行占位等操作
/// M: 遵循Codable协议的数据类型
/// C: 含有一个M类型data的UICollectionViewCell
class GenericCollectionViewController<M: Codable, C: GenericCollectionViewCell<M>>: UICollectionViewController, UIScrollViewRefreshDelegate {
    
    
    /// 网络请求API
//    var api: NetApi {
//        return CommonApi.none
//    }
    
    /// 刷新类型(头/尾/头尾)
    var refreshType: UIScrollViewRefreshType {
        return .headerAndFooter
    }
    
    /// 当前分页
    var page = 0
    /// 数据源
    var dataArray = [M]()
    /// 网络请求对象
//    weak var request: NetRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        collectionView.placeholderView.backgroundColor = .white
//        collectionView.placeholderView.delegate = self
        collectionView.addRefresh(type: refreshType, delegate: self)
    }
    
    func reloadDataFormNet() {
        dataArray = []
        page = 0
        loadDataFromNet()
    }
    
    // MARK: - load list data from net
    func loadDataFromNet() {
//        request?.cancel()
//        if dataArray.count == 0 {
//            showLoadingPlaceHolder()
//        }
//        SCLog(api.desc)
//        request = NetTool.loadObject(api: api) { [weak self] (result: NetResult<[M]>) in
//            switch result {
//            case let .success(list):
//                self?.loadDataSuccess(list)
//            case let .failure(error):
//                self?.loadDataFailure(error)
//            }
//        }
    }
    
    func loadDataSuccess(_ list: [M]) {
        if page == 0 {
            dataArray.removeAll()
        }
        dataArray.append(contentsOf: list)
        if dataArray.count == 0 {
//            showNoDataPlaceHolder()
        }else {
            page += 1
//            removePlaceHolder()
        }
        if list.count < 10 {
            collectionView.mj_header?.endRefreshing()
            collectionView.mj_footer?.endRefreshingWithNoMoreData()
        }else {
            collectionView.endRefresh()
        }
        collectionView.reloadData()
    }
    
//    func loadDataFailure(_ error: NetError) {
//        collectionView.endRefresh()
//        if dataArray.count == 0 {
//            switch error {
//            case .disconnect:
//                showNoConnectionPlaceholder()
//            case .failure:
//                showNetErrorPlaceHolder()
//            }
//        }else {
//            removePlaceHolder()
//        }
//    }
    
    
    // MARK: - Collection view data source
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: C.named, for: indexPath) as! C
        cell.data = dataArray[indexPath.row]
        return cell
    }
    
    //MARK: - header and footer refresh action
    func scrollViewHeaderRefreshData(_ scrollView: UIScrollView) {
        page = 0
        loadDataFromNet()
    }
    
    func scrollViewFooterRefreshData(_ scrollView: UIScrollView) {
        loadDataFromNet()
    }
    
    //MARK: - PlaceHolders
//    func placeholderView(_ view: PlaceholderView, actionButtonTappedFor placeholder: Placeholder) {
//        if placeholder == .loading {
//            request?.cancel()
//        }else {
//            loadDataFromNet()
//        }
//    }
//
//    func placeholderView(_ view: PlaceholderView, backgroundTappedFor placeholder: Placeholder) {
//        if placeholder == .loading {
//            request?.cancel()
//        }else {
//            loadDataFromNet()
//        }
//    }
    
//    func showNoConnectionPlaceholder() {
//        collectionView.showNoConnectionPlaceholder()
//    }
    
//    func showLoadingPlaceHolder() {
//        collectionView.showLoadingPlaceholder()
//    }
//
//    func showNoDataPlaceHolder() {
//        collectionView.showNodataPlaceholder()
//    }
//
//    func showNetErrorPlaceHolder() {
//        collectionView.showErrorPlaceholder()
//    }
//
//    func removePlaceHolder() {
//        collectionView.removePlaceholder()
//    }
    
}

class GenericCollectionViewCell<M: Codable>: UICollectionViewCell {
    
    var data: M!
    
}




