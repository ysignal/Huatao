//
//  CityPickerView.swift
//  Huatao
//
//  Created on 2023/2/15.
//  
	

import UIKit
import JXSegmentedView
import JXPagingView

class CityPickerView: UIView {
    
    enum SelectType {
    case city, area
    }
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var pickerView: UIView!
    @IBOutlet weak var closeBtn: SSButton!
    
    lazy var listContainerView: JXSegmentedListContainerView = {
        return JXSegmentedListContainerView(dataSource: self)
    }()

    lazy var segmentedView: JXSegmentedView = {
        let segment = JXSegmentedView(frame: CGRect(x: 0, y: 0, width: 160, height: 52))
        segment.backgroundColor = .clear
        segment.delegate = self
        return segment
    }()
    
    lazy var provinceTV: CityPagingView = {
        let v = CityPagingView(frame: .zero, style: .plain)
        v.separatorStyle = .none
        v.delegate = self
        v.dataSource = self
        v.tableHeaderView = UIView()
        v.tableFooterView = UIView()
        v.register(nibCell: CityPickerItemCell.self)
        return v
    }()
    
    lazy var cityTV: CityPagingView = {
        let v = CityPagingView(frame: .zero, style: .plain)
        v.separatorStyle = .none
        v.delegate = self
        v.dataSource = self
        v.tableHeaderView = UIView()
        v.tableFooterView = UIView()
        v.register(nibCell: CityPickerItemCell.self)
        return v
    }()
    
    lazy var areaTV: CityPagingView = {
        let v = CityPagingView(frame: .zero, style: .plain)
        v.separatorStyle = .none
        v.delegate = self
        v.dataSource = self
        v.tableHeaderView = UIView()
        v.tableFooterView = UIView()
        v.register(nibCell: CityPickerItemCell.self)
        return v
    }()
    
    var viewList: [CityPagingView] {
        return [provinceTV, cityTV, areaTV]
    }
    
    var segmentedDataSource = JXSegmentedTitleDataSource()
    
    var currentPage: Int = 0
    
    var result = SelectCityResult()
    
    var titles: [String] = ["请选择"]
    
    var provinceList: [ProvinceModel] = []
    var cityList: [CityModel] = []
    var areaList: [AreaModel] = []
    
    var selectType: SelectType = .city
    
    var completionBlock: ((SelectCityResult) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        buildUI()
    }
    
    private func buildUI() {
        backgroundColor = .white
        ex_width = SS.w
        
        provinceList = DataManager.provinceList
            
        loadOption([.cornerCut(16, [.topLeft, .topRight])])
        
        containerView.addSubview(segmentedView)
        segmentedView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        pickerView.addSubview(listContainerView)
        listContainerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        segmentedDataSource.titles = titles
        segmentedDataSource.titleNormalFont = .ss_regular(size: 14)
        segmentedDataSource.titleSelectedFont = .ss_semibold(size: 14)
        segmentedDataSource.titleNormalColor = .hex("333333")
        segmentedDataSource.titleSelectedColor = .hex("999999")
        segmentedDataSource.itemSpacing = 10
        segmentedDataSource.isTitleColorGradientEnabled = true
        segmentedDataSource.isItemSpacingAverageEnabled = false
        
        segmentedView.listContainer = listContainerView
        segmentedView.dataSource = segmentedDataSource
        segmentedView.defaultSelectedIndex = currentPage
        
        let indicator = JXSegmentedIndicatorLineView()
        indicator.verticalOffset = 2
        indicator.indicatorHeight = 3
        indicator.indicatorColor = .hex("ff8100")
        indicator.lineStyle = .lengthenOffset
        segmentedView.indicators = [indicator]
    }

    static func show(type: SelectType = .city, completion: ((SelectCityResult) -> Void)? = nil)  {
        let view = fromNib()
        view.selectType = type
        view.completionBlock = completion
        
        let config = OverlayConfig()
        config.name = view.named
        config.width = SS.w
        config.height = 480 + SS.safeBottomHeight
        config.location = .bottom
        config.overlayBackMode = .color(color: .black.withAlphaComponent(0.8))
        config.contentAnimation = TranslationAnimation(direction: .bottom)
        SSOverlayController.show(view, config: config)
    }
    
    func createPagingView() -> CityPagingView {
        let v = CityPagingView(frame: .zero, style: .plain)
        v.separatorStyle = .none
        v.delegate = self
        v.dataSource = self
        v.tableHeaderView = UIView()
        v.tableFooterView = UIView()
        v.register(nibCell: CityPickerItemCell.self)
        return v
    }
    
    @IBAction func toClose(_ sender: Any) {
        SSOverlayController.dismiss(named)
    }
    
}

extension CityPickerView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch currentPage {
        case 0:
            let item = provinceList[indexPath.row]
            result.province = item.name
            result.provinceCode = item.code
            currentPage = 1
            cityList = item.cityList
            segmentedDataSource.titles = [item.name, "请选择"]
            segmentedDataSource.reloadData(selectedIndex: 1)
            segmentedView.reloadData()
            segmentedView.selectItemAt(index: 1)
            cityTV.reloadData()
        case 1:
            let item = cityList[indexPath.row]
            result.city = item.name
            result.cityCode = item.code
            if selectType == .city {
                completionBlock?(result)
                SSOverlayController.dismiss(named)
                return
            }
            currentPage = 2
            areaList = item.areaList
            segmentedDataSource.titles = [result.province, item.name, "请选择"]
            segmentedDataSource.reloadData(selectedIndex: 2)
            segmentedView.reloadData()
            segmentedView.selectItemAt(index: 2)
            areaTV.reloadData()
        case 2:
            let item = areaList[indexPath.row]
            result.area = item.name
            result.areaCode = item.code
            completionBlock?(result)
            SSOverlayController.dismiss(named)
        default:
            break
        }
    }
    
}

extension CityPickerView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentPage {
        case 0:
            return provinceList.count
        case 1:
            return cityList.count
        case 2:
            return areaList.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: CityPickerItemCell.self)
        switch currentPage {
        case 0:
            cell.config(text: provinceList[indexPath.row].name)
        case 1:
            cell.config(text: cityList[indexPath.row].name)
        case 2:
            cell.config(text: areaList[indexPath.row].name)
        default:
            break
        }
        return cell
    }
    
}

extension CityPickerView: JXSegmentedViewDelegate {
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        currentPage = index
    }
}

extension CityPickerView: JXSegmentedListContainerViewDataSource {
    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        return viewList[index]
    }
    
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        return segmentedDataSource.titles.count
    }
}

extension JXPagingListContainerView: JXSegmentedViewListContainer {}

class CityPagingView: UITableView, JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        self
    }
}

struct SelectCityResult {
    var province: String = ""
    var provinceCode: String = ""
    var city: String = ""
    var cityCode: String = ""
    var area: String = ""
    var areaCode: String = ""
}
