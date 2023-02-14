//
//  TaskViewController.swift
//  Huatao
//
//  Created on 2023/1/10.
//

import UIKit
import JXSegmentedView

class TaskViewController: SSViewController {

    lazy var background: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: SS.w, height: 262))
        view.drawGradient(start: .hex("fff1e2"), end: .hex("f6f6f6"), size: view.frame.size, direction: .t2b)
        return view
    }()
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var bannerCV: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var taskTV: UITableView!
    
    lazy var segmentedView: JXSegmentedView = {
        let segment = JXSegmentedView(frame: CGRect(x: 0, y: 0, width: 120, height: 40))
        segment.backgroundColor = .clear
        segment.delegate = self
        return segment
    }()
    
    var segmentedDataSource = JXSegmentedTitleDataSource()
    
    /// 组头标题数组
    var titles = ["今日任务","本月任务"]
    
    /// 轮播图数据
    var banners: [BannerImageItem] = []
    
    /// 任务数据
    var taskModel = TaskListModel()
    
    /// 组头
    var currentPage: Int = 0
    
    /// banner当前滚动页
    var currentIndex: Int = 0
    
    /// 计时器
    var timer: Timer?
    
    /// 计时器计数
    var timerCount: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        buildUI()
        requestData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        timer?.start()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.stop()
    }

    
    override func buildUI() {
        view.backgroundColor = .hex("f6f6f6")
        view.insertSubview(background, belowSubview: taskTV)

        showFakeNavBar()
        fakeNav.backgroundColor = .clear
        fakeNav.titleLabel.font = .ss_semibold(size: 18)
        fakeNav.title = "任务大厅"
        fakeNav.titleColor = .hex("333333")
        
        headerView.ex_height = 66 + 140.scale
        pageControl.isHidden = true
        pageControl.isUserInteractionEnabled = false
        
        bannerCV.register(nibCell: BaseImageItemCell.self)
        taskTV.register(nibCell: ShopVipSetCell.self)
        let footer = UIView().loadOption([.backgroundColor(.clear)])
        footer.ex_height = 6
        taskTV.tableFooterView = footer
        
        segmentedDataSource.titles = titles
        segmentedDataSource.titleNormalFont = .ss_regular(size: 16)
        segmentedDataSource.titleSelectedFont = .ss_semibold(size: 18)
        segmentedDataSource.titleNormalColor = .hex("333333")
        segmentedDataSource.titleSelectedColor = .ss_theme
        segmentedDataSource.itemSpacing = 16
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
        
        HttpApi.Task.getBannerList(sign: "task").done { [weak self] data in
            guard let weakSelf = self else { return }
            self?.banners = data.kj.modelArray(BannerImageItem.self)
            SSMainAsync {
                weakSelf.bannerCV.reloadData()
                weakSelf.addTimer()
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.toast(message: error.localizedDescription)
            }
        }

        HttpApi.Task.getTaskList().done { [weak self] data in
            guard let weakSelf = self else { return }
            weakSelf.taskModel = data.kj.model(TaskListModel.self)
            SSMainAsync {
                weakSelf.view.ss.hideHUD()
                weakSelf.taskTV.reloadData()
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.toast(message: error.localizedDescription)
            }
        }
    }
    
    func addTimer() {
        if banners.count < 2 {
            return
        }
        pageControl.isHidden = false
        pageControl.numberOfPages = banners.count
        
        timer?.invalidate()
        timer = nil
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(nextImage), userInfo: nil, repeats: true)
    }

    @objc func nextImage() {
        timerCount += 1
        if timerCount >= 3 {
            currentIndex += 1
            if currentIndex >= banners.count {
                currentIndex = 0
                bannerCV.scrollToItem(at: IndexPath(row: 0, section: 0), at: .left, animated: true)
            } else {
                bannerCV.scrollToItem(at: IndexPath(row: currentIndex, section: 0), at: .left, animated: true)
            }
            pageControl.currentPage = currentIndex
            timerCount = 0
        }
    }

    func itemClicked(_ item: TaskListItem) {
        
    }

}

extension TaskViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == bannerCV {
            timerCount = 0
            timer?.stop()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == bannerCV {
            timer?.start()
        }
    }
}

extension TaskViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: SS.w - 24, height: 140.scale)
    }
    
}

extension TaskViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return banners.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(with: BaseImageItemCell.self, for: indexPath)
        let item = banners[indexPath.row]
        cell.config(url: item.image, placeholder: SSImage.photoDefault, cornerRadius: 8)
        return cell
    }
    
}

extension TaskViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 50
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let view = UIView().loadOption([.backgroundColor(.clear)])
            view.addSubview(segmentedView)
            segmentedView.snp.makeConstraints { make in
                make.left.bottom.equalToSuperview()
                make.width.equalTo(180)
                make.height.equalTo(40)
            }
            return view
        }
        return nil
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
            switch indexPath.section {
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
        UIView.performWithoutAnimation {
            self.taskTV.reloadSections(IndexSet(integer: 1), with: .none)
        }
    }
}
