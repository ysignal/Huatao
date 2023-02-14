//
//  AddressBookViewController.swift
//  Huatao
//
//  Created by lgvae on 2023/2/11.
//

import UIKit
import ZHXIndexView

class AddressBookViewController: BaseViewController{
    
    var sectionIndexArray = ["A","B","C","D","E","F","G"]
    
    lazy var tableView: UITableView = {
        
        let tableView = UITableView(frame: CGRect(x: 0, y: SS.navBarHeight + SS.statusBarHeight, width: SS.w, height: SS.h - SS.navBarHeight - SS.statusBarHeight - SS.safeBottomHeight),style: .plain)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = .hex("F6F6F6")
        tableView.showsVerticalScrollIndicator = false
        
        
        return tableView
    }()
    
    lazy var indexView: ZHXIndexView = {
        
        
        let indexView = ZHXIndexView(indexViewWithFrame: CGRect(x: Int(SS.w) - 24, y: 0, width: 12, height: sectionIndexArray.count * 25))
        
        indexView.center.y = view.center.y
        
        indexView.delegate = self
        
        indexView.itemTitleColor = .hex("646566")
        
        indexView.itemHighlightTitleColor = .hex("FF8100")
        
        indexView.itemHighlightColor = UIColor.clear
        
        indexView.itemTitleFont = UIFont.systemFont(ofSize: 12)
        
        return indexView
        
    }()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func buildUI() {
        
        view.addSubview(tableView)
        
        view.addSubview(indexView)
        
        indexView.indexTitles = sectionIndexArray
        
        fakeNav.title = "通讯录"
        
        fakeNav.rightButton.title = "添加好友"
        fakeNav.rightButton.titleColor = .ss_theme
        fakeNav.rightButton.isHidden = false
        fakeNav.rightButton.snp.updateConstraints { make in
            make.width.equalTo(70)
        }
        fakeNav.rightButtonHandler = { [weak self] in
            print("点击:AddressBookViewController - \(String(describing: self?.fakeNav.rightButton.title))")
        }
        
    }
    
}

extension AddressBookViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension AddressBookViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 5
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionIndexArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = AddressBookCell(style: .default, reuseIdentifier: "AddressBookCell")
        
        cell.selectionStyle = .none
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 62
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let sectionHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: SS.w, height: 32))

        sectionHeaderView.backgroundColor = .hex("F6F6F6")

        let indexNum = UILabel(text: sectionIndexArray[section], textColor: .hex("999999"), textFont: UIFont.systemFont(ofSize: 17))
        indexNum.frame = CGRect(x: 16, y: 0, width: 100, height: 32)

        sectionHeaderView.addSubview(indexNum)

        return sectionHeaderView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        return 32
    }
    
}

extension AddressBookViewController: UIScrollViewDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.isDragging {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){

                self.indexView.updateItemHighlightWhenScrollStop(withDispalyView: scrollView)

            }
        }
        
    }
}

extension AddressBookViewController: ZHXIndexViewDelegate{
    
    
    func indexViewDidSelect(_ index: Int) {
        
        tableView.scrollToRow(at: IndexPath(row: 0, section: index), at: .top, animated: false)
    }
    
}


