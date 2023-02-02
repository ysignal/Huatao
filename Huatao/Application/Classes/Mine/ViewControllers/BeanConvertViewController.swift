//
//  BeanConvertViewController.swift
//  Huatao
//
//  Created by minse on 2023/1/26.
//

import UIKit

class BeanConvertViewController: BaseViewController {
    
    @IBOutlet weak var convertCV: UICollectionView!
    @IBOutlet weak var convertCVHeight: NSLayoutConstraint!
    @IBOutlet weak var convertBtn: UIButton!
    @IBOutlet weak var numberView: UIView!
    @IBOutlet weak var numberTF: UITextField!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var containerViewWidth: NSLayoutConstraint!
    
    var model = ConversionGoldModel()
    
    var changedBlock: NoneBlock?

    override func viewDidLoad() {
        super.viewDidLoad()

        requestData()
    }
    
    override func buildUI() {
        fakeNav.title = "兑换"
        fakeNav.rightButton.title = "兑换记录"
        fakeNav.rightButton.titleColor = .ss_theme
        fakeNav.rightButton.isHidden = false
        fakeNav.rightButton.snp.updateConstraints { make in
            make.width.equalTo(70)
        }
        fakeNav.rightButtonHandler = { [weak self] in
            self?.toHistory()
        }
        // 关闭多选
        convertCV.allowsMultipleSelection = false
        // 约束可滚动区域宽度
        containerViewWidth.constant = SS.w
        // 绘制渐变
        convertBtn.drawThemeGradient(CGSize(width: SS.w - 24, height: 40))
        // 初始化按钮状态
        checkButtonStatus()
    }
    
    private func requestData() {
        view.ss.showHUDLoading()
        HttpApi.Mine.getConversionGold().done { [weak self] data in
            self?.model = data.kj.model(ConversionGoldModel.self)
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.updateListViews()
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.toast(message: error.localizedDescription)
            }
        }
    }
    
    private func updateListViews() {
        let line = model.moneyList.count / 3
        let rem = model.moneyList.count % 3
        let height = ((60 + 6) * CGFloat(rem > 0 ? line + 1 : line)) - 6
        convertCVHeight.constant = height
        containerViewHeight.constant = height + 168
        
        convertCV.reloadData()
        
        ConvertRateTipView.show(name: model.name, rate: model.rate)
    }
    
    private func checkButtonStatus() {
        var isEnabled = false
        if let _ = convertCV.indexPathsForSelectedItems?.first {
            isEnabled = true
        } else if let num = numberTF.text?.intValue, num > 0 {
            isEnabled = true
        }
        if isEnabled {
            convertBtn.drawThemeGradient(CGSize(width: SS.w - 24, height: 40))
            convertBtn.isUserInteractionEnabled = true
        } else {
            convertBtn.drawGradient(start: .hex("dddddd"), end: .hex("dddddd"), size: CGSize(width: SS.w - 24, height: 40))
            convertBtn.isUserInteractionEnabled = false
        }
    }
    
    private func toHistory() {
        let vc = ConvertHistoryViewController.from(sb: .mine)
        go(vc)
    }
    
    @IBAction func numberDidChanged(_ sender: Any) {
        if numberTF.markedTextRange == nil {
            checkButtonStatus()
            // 刷新兑换列表选中状态
            convertCV.reloadData()
        }
    }
    
    @IBAction func toConvert(_ sender: Any) {
        view.endEditing(true)
        
        var money: Int = 0
        
        if let selectIdx = convertCV.indexPathsForSelectedItems?.first {
            money = model.moneyList[selectIdx.row]
        } else if let num = numberTF.text?.intValue {
            money = num
        }
        
        if money <= 0 {
            toast(message: "兑换数量错误")
            return
        }
        
        view.ss.showHUDLoading()
        HttpApi.Mine.putConversionGold(money: money).done { [weak self] _ in
            SSMainAsync {
                self?.view.ss.hideHUD()
                let vc = ConvertResultViewController.from(sb: .mine)
                vc.changedBlock = self?.changedBlock
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

extension BeanConvertViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (SS.w - 36)/3
        return CGSize(width: width, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        checkButtonStatus()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        checkButtonStatus()
    }
    
}

extension BeanConvertViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.moneyList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(with: ConvertListItemCell.self, for: indexPath)
        let item = model.moneyList[indexPath.row]
        cell.titleLabel.text = "\(item)金豆"
        return cell
    }
    
}
