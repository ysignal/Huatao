//
//  TaskViewController.swift
//  Huatao
//
//  Created by minse on 2023/1/10.
//

import UIKit
import JXSegmentedView

class TaskViewController: SSViewController {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var bannerCV: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var taskTV: UITableView!
    
    lazy var segmentedView: JXSegmentedView = {
        let segment = JXSegmentedView(frame: CGRect(x: 0, y: 0, width: 120, height: 40))
        segment.backgroundColor = .white
        segment.delegate = self
        return segment
    }()

    var segmentedDataSource = JXSegmentedTitleDataSource()
    
    var titles = ["今日任务","本月任务"]
    
    var bannerList: [MaterialDetail] = []
    
    var taskModel = TaskListModel()
    
    var currentPage: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        buildUI()
        requestData()
    }
    
    override func buildUI() {
        view.backgroundColor = .hex("f6f6f6")
        
        showFakeNavBar()
        fakeNav.backgroundColor = .clear
        fakeNav.titleLabel.font = UIFont.ss_semibold(size: 18)
        fakeNav.title = "任务大厅"
        fakeNav.titleColor = .hex("333333")
        
        background.drawGradient(start: .hex("fff1e2"), end: .hex("f6f6f6"), size: CGSize(width: SS.w, height: 358), direction: .t2b)
                
        bannerCV.register(nibCell: BaseImageItemCell.self)
        taskTV.register(nibCell: ShopVipSetCell.self)
        taskTV.tableFooterView = UIView()
        
        segmentedDataSource.titles = titles
        segmentedDataSource.titleNormalFont = .ss_regular(size: 14)
        segmentedDataSource.titleSelectedFont = .ss_semibold(size: 16)
        segmentedDataSource.titleNormalColor = .hex("333333")
        segmentedDataSource.titleSelectedColor = .ss_theme
        segmentedDataSource.isTitleColorGradientEnabled = true
        segmentedView.dataSource = segmentedDataSource
        
        let indicator = JXSegmentedIndicatorLineView()
        indicator.verticalOffset = 6
        indicator.indicatorWidth = 10
        indicator.indicatorHeight = 2
        indicator.indicatorCornerRadius = 1
        indicator.indicatorColor = UIColor.ss_theme
        segmentedView.indicators = [indicator]
                
    }
    
    func requestData() {
        view.ss.showHUDLoading()
        HttpApi.Task.getSendMaterialList().done { [weak self] data in
            let listModel = data.kj.model(ListModel<MaterialDetail>.self)
            self?.bannerList = listModel.list
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.bannerCV.reloadData()
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.toast(message: error.localizedDescription)
            }
        }
        
        HttpApi.Task.getTaskList().done { [weak self] data in
            self?.taskModel = data.kj.model(TaskListModel.self)
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.taskTV.reloadData()
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.toast(message: error.localizedDescription)
            }
        }

    }

    func itemClicked(_ item: TaskListItem) {
        
    }

}

extension TaskViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: SS.w - 24, height: 140.scale)
    }
    
}

extension TaskViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bannerList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(with: BaseImageItemCell.self, for: indexPath)
        let item = bannerList[indexPath.row]
        cell.confit(url: item.images.first ?? "", placeholder: SSImage.photoDefault, cornerRadius: 8)
        return cell
    }
    
}

extension TaskViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
}

extension TaskViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return taskModel.list.count
        case 1:
            switch currentPage {
            case 0:
                return taskModel.dayList.count
            case 1:
                return taskModel.monthList.count
            default:
                break
            }
        default:
            break
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: TaskListItemCell.self)
        let list: [TaskListItem] = {
            switch indexPath.row {
            case 0:
                return taskModel.list
            case 1:
                switch currentPage {
                case 0:
                    return taskModel.dayList
                case 1:
                    return taskModel.monthList
                default:
                    break
                }
            default:
                break
            }
            return []
        }()
        let item = list[indexPath.row]
        cell.config(item: item)
        cell.completionBlock = {
            self.itemClicked(item)
        }
        return cell
    }
    
}

extension TaskViewController: JXSegmentedViewDelegate {
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        currentPage = index
    }
}
