//
//  HomePlaceViewController.swift
//  Huatao
//
//  Created on 2023/2/28.
//  
	

import UIKit

class HomePlaceViewController: BaseViewController {
    
    @IBOutlet weak var cityView: UIView!
    @IBOutlet weak var cityTF: UITextField!
    @IBOutlet weak var submitBtn: UIButton!
    
    var result = SelectCityResult() {
        didSet {
            updateCityView()
            submitBtn.isUserInteractionEnabled = true
            submitBtn.drawThemeGradient(CGSize(width: SS.w - 24, height: 40))
        }
    }
    
    var completeBlock: NoneBlock?

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func buildUI() {
        fakeNav.title = "设置归属地"
        
        submitBtn.isUserInteractionEnabled = false

        cityView.addGesture(.tap) { tap in
            if tap.state == .ended {
                self.view.endEditing(true)
                CityPickerView.show { result in
                    self.result = result
                }
            }
        }
    }
    
    func updateCityView() {
        cityTF.text = "\(result.province) \(result.city)"
    }
    
    @IBAction func toSubmit(_ sender: Any) {
        view.ss.showHUDLoading()
        HttpApi.Task.putSetLocation(provinceCode: result.provinceCode, cityCode: result.cityCode).done { [weak self] _ in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.globalToast(message: "设置成功")
                self?.completeBlock?()
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
