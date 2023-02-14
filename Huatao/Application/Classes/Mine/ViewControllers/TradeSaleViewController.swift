//
//  TradeSaleViewController.swift
//  Huatao
//
//  Created on 2023/1/23.
//

import UIKit
import ZLPhotoBrowser

class TradeSaleViewController: BaseViewController {
    
    @IBOutlet weak var saleTV: UITableView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var numberTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    @IBOutlet weak var wxBtn: SSButton!
    @IBOutlet weak var alipayBtn: SSButton!
    @IBOutlet weak var cardBtn: SSButton!
    
    @IBOutlet weak var payBtn: UIButton!
    @IBOutlet weak var payImage: UIImageView!
    @IBOutlet weak var payTip: UILabel!
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var accountTF: UITextField!
    @IBOutlet weak var cardTF: UITextField!
    @IBOutlet weak var bankTF: UITextField!
    
    @IBOutlet weak var confirmBtn: UIButton!
    
    private var wxImage: UIImage?
    private var alipayImage: UIImage?
    private var defaultPay = UIImage(named: "btn_image_add_solid")
    private var tradeType: Int = 0
    private var tradeImage: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func buildUI() {
        view.backgroundColor = .hex("f6f6f6")
        fakeNav.title = "卖出金豆"
        
        cardView.isHidden = true
        
        wxBtn.image = UIImage(named: "ic_radio_off")
        wxBtn.selectedImage = UIImage(named: "ic_radio_on")
        alipayBtn.image = UIImage(named: "ic_radio_off")
        alipayBtn.selectedImage = UIImage(named: "ic_radio_on")
        cardBtn.image = UIImage(named: "ic_radio_off")
        cardBtn.selectedImage = UIImage(named: "ic_radio_on")
        
        wxBtn.isSelected = true
    }
    
    @IBAction func toPickImage(_ sender: Any) {
        let zl = ZLPhotoPreviewSheet()
        ZLPhotoConfiguration.default().allowRecordVideo(false).maxSelectCount(1)
        
        zl.selectImageBlock = { images, isFull in
            if let model = images.first {
                if self.wxBtn.isSelected {
                    self.wxImage = model.image
                    self.payImage.image = model.image
                } else {
                    self.alipayImage = model.image
                    self.payImage.image = model.image
                }
            }
        }
        zl.showPhotoLibrary(sender: self)
    }
    
    @IBAction func toWX(_ sender: Any) {
        tradeType = 0
        cardView.isHidden = true
        resetButtons()
        wxBtn.isSelected = true
        payTip.text = "上传微信收款码"
        payImage.image = wxImage ?? defaultPay
    }
    
    @IBAction func toAlipay(_ sender: Any) {
        tradeType = 1
        cardView.isHidden = true
        resetButtons()
        alipayBtn.isSelected = true
        payTip.text = "上传支付宝收款码"
        payImage.image = alipayImage ?? defaultPay
        checkButtonStatus()
    }
    
    @IBAction func toCard(_ sender: Any) {
        tradeType = 2
        cardView.isHidden = false
        resetButtons()
        cardBtn.isSelected = true
        checkButtonStatus()
    }
    
    func resetButtons() {
        wxBtn.isSelected = false
        alipayBtn.isSelected = false
        cardBtn.isSelected = false
        checkButtonStatus()
    }
    
    func checkButtonStatus() {
        var isEnabled = true
        if numberTF.text == nil || numberTF.text?.isEmpty == true {
            isEnabled = false
        }
        if passwordTF.text == nil || passwordTF.text?.isEmpty == true {
            isEnabled = false
        }
        if wxBtn.isSelected {
            if wxImage == nil {
                isEnabled = false
            }
        } else if alipayBtn.isSelected {
            if alipayImage == nil {
                isEnabled = false
            }
        } else {
            if accountTF.text == nil || accountTF.text?.isEmpty == true || cardTF.text == nil || cardTF.text?.isEmpty == true || bankTF.text == nil || bankTF.text?.isEmpty == true {
                isEnabled = false
            }
        }
        if isEnabled {
            confirmBtn.drawThemeGradient(CGSize(width: SS.w - 24, height: 40))
            confirmBtn.isUserInteractionEnabled = true
        } else {
            confirmBtn.drawGradient(start: .hex("dddddd"), end: .hex("dddddd"), size: CGSize(width: SS.w - 24, height: 40))
            confirmBtn.isUserInteractionEnabled = false
        }
    }
    
    @IBAction func textFieldEditingChanged(_ sender: Any) {
        if let tf = sender as? UITextField, tf.markedTextRange == nil {
            checkButtonStatus()
        }
    }
    
    @IBAction func toConfirm(_ sender: Any) {
        guard let number = numberTF.text?.floatValue, number > 0 else {
            toast(message: "请输入正确的金豆数量")
            return
        }
        if wxBtn.isSelected || alipayBtn.isSelected {
            let image: UIImage? = wxBtn.isSelected ? wxImage : alipayImage
            if let data = image?.jpegData(compressionQuality: 0.7) {
                view.ss.showHUDProgress(0, title: "图片上传")
                HttpApi.File.uploadImage(data: data, fileName: "\(UUID().uuidString).jpg") { [weak self] progress in
                    SSMainAsync {
                        self?.view.ss.showHUDProgress(progress, title: "图片上传")
                    }
                }.done { [weak self] data in
                    let model = data.kj.model(AvatarUrl.self)
                    self?.tradeImage = model.allUrl
                    SSMainAsync {
                        self?.view.ss.hideHUD()
                        self?.sendRequest()
                    }
                }.catch { [weak self] error in
                    SSMainAsync {
                        self?.tradeImage = ""
                        self?.view.ss.hideHUD()
                        self?.toast(message: error.localizedDescription)
                    }
                }
            } else {
                toast(message: "\(wxBtn.isSelected ? "微信" : "支付宝")收款码图片获取失败，请重新尝试")
            }
        } else {
            tradeImage = ""
            sendRequest()
        }
    }
    
    func sendRequest() {
        view.ss.showHUDLoading()
        HttpApi.Mine.postGoldSale(total: numberTF.text?.floatValue ?? 0,
                                  tradeType: tradeType,
                                  name: accountTF.text ?? "",
                                  card: cardTF.text ?? "",
                                  bankAddress: bankTF.text ?? "",
                                  tradeImage: tradeImage,
                                  tradePassword: passwordTF.text ?? "").done { [weak self] _ in
            SSMainAsync {
                self?.view.ss.hideHUD()
                SS.keyWindow?.toast(message: "发布成功")
                self?.back()
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.tradeImage = ""
                self?.view.ss.hideHUD()
                self?.toast(message: error.localizedDescription)
            }
        }
    }
}
