//
//  AgentViewController.swift
//  Huatao
//
//  Created on 2023/2/13.
//  
	

import UIKit

class AgentViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var mobileTF: UITextField!
    @IBOutlet weak var areaView: UIView!
    @IBOutlet weak var areaTF: UITextField!
    
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var sectionHeader: UIView!
    @IBOutlet weak var sectionFooter: UIView!
    
    var list: [AgentListItem] = []

    var result = SelectCityResult()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.ss.showHUDLoading()
        requestData()
    }
    
    override func buildUI() {
        fakeNav.title = "成为代理商"
        
        tableView.estimatedSectionFooterHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        sectionHeader.loadOption([.cornerCut(8, [.topLeft, .topRight], CGSize(width: SS.w - 24, height: 44))])
        sectionFooter.loadOption([.cornerCut(8, [.bottomLeft, .bottomRight], CGSize(width: SS.w - 24, height: 16))])
        
        areaView.addGesture(.tap) { tap in
            if tap.state == .ended {
                self.view.endEditing(true)
                CityPickerView.show { result in
                    self.result = result
                    self.updateCityView()
                }
            }
        }
    }
    
    func requestData() {
        HttpApi.Mine.getAgentList().done { [weak self] data in
            let listModel = data.kj.model(ListModel<AgentListItem>.self)
            self?.list = listModel.list
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.tableView.reloadData()
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.toast(message: error.localizedDescription)
            }
        }
    }
    
    @IBAction func textFieldChanged(_ sender: Any) {
        if let tf = sender as? UITextField, tf.markedTextRange == nil {
            checkButtonState()
        }
    }
    
    func updateCityView() {
        if result.provinceCode == result.cityCode {
            areaTF.text = result.city
        } else {
            areaTF.text = "\(result.province) \(result.city)"
        }
        checkButtonState()
    }
    
    func checkButtonState() {
        var isEnabled: Bool = true
        if nameTF.text == nil || nameTF.text!.isEmpty {
            isEnabled = false
        }
        if mobileTF.text == nil || mobileTF.text!.isEmpty {
            isEnabled = false
        }
        if areaTF.text == nil || areaTF.text!.isEmpty {
            isEnabled = false
        }
        if isEnabled {
            submitBtn.isUserInteractionEnabled = true
            submitBtn.drawThemeGradient(CGSize(width: SS.w - 24, height: 40))
        } else {
            submitBtn.isUserInteractionEnabled = false
            submitBtn.drawGradient(start: .hex("dddddd"), end: .hex("dddddd"), size: CGSize(width: SS.w - 24, height: 40), direction: .t2b)
        }
    }
    
    @IBAction func toSubmit(_ sender: Any) {
        view.ss.showHUDLoading()
        HttpApi.Mine.putBecomeAgent(mobile: mobileTF.text ?? "", name: nameTF.text ?? "", provinceCode: result.provinceCode, cityCode: result.cityCode).done { [weak self] _ in
            SSMainAsync {
                self?.view.ss.hideHUD()
                let vc = AgentResultViewController.from(sb: .mine)
                self?.go(vc)
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.toast(message: error.localizedDescription)
            }
        }
    }

}

extension AgentViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(backgroundColor: .hex("f6f6f6"))
        
        let mainView = UIView(backgroundColor: .white)
        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.top.bottom.equalToSuperview()
        }
        
        let item = list[section]

        let lb = UILabel(text: item.name, textColor: .hex("333333"), textFont: .systemFont(ofSize: 12))
        mainView.addSubview(lb)
        lb.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
        }
        
        let iv = UIImageView(image: UIImage(named: "ic_arrow_gray_12"))
        mainView.addSubview(iv)
        iv.snp.makeConstraints { make in
            make.left.equalTo(lb.snp.right).offset(4)
            make.width.height.equalTo(12)
            make.centerY.equalToSuperview()
        }
        
        if item.isOpen {
            // 关闭
            iv.transform = CGAffineTransform(rotationAngle: 90*CGFloat.pi/180)
        } else {
            // 展开
            iv.transform = .identity
        }
        
        view.addGesture(.tap) { tap in
            if tap.state == .ended {
                self.view.endEditing(true)
                self.list[section].isOpen.toggle()
                tableView.reloadSections(IndexSet(integer: section), with: .automatic)
            }
        }
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
}

extension AgentViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let item = list[section]
        return item.isOpen ? item.children.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: AgentUserItemCell.self)
        let section = list[indexPath.section]
        let item = section.children[indexPath.row]
        cell.config(item: item)
        return cell
    }
    
}

extension AgentViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nameTF:
            mobileTF.becomeFirstResponder()
        case mobileTF:
            mobileTF.resignFirstResponder()
        default: break
        }
        return true
    }
    
}
