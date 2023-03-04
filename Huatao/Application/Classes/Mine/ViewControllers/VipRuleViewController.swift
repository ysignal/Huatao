//
//  VipRuleViewController.swift
//  Huatao
//
//  Created on 2023/1/21.
//

import UIKit

class VipRuleViewController: BaseViewController {
    
    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userMobile: UILabel!
    @IBOutlet weak var userId: UILabel!
    @IBOutlet weak var vipRate: UILabel!
    @IBOutlet weak var vipBtn: UIButton!
    
    @IBOutlet weak var curView: UIView!
    @IBOutlet weak var curIcon: UIImageView!
    @IBOutlet weak var curLabel: UILabel!
    @IBOutlet weak var nextView: UIView!
    @IBOutlet weak var nextIcon: UIImageView!
    @IBOutlet weak var nextLabel: UILabel!
    
    @IBOutlet weak var curLevel: UILabel!
    @IBOutlet weak var curTitle: UILabel!
    @IBOutlet weak var nextTitle: UILabel!
    
    @IBOutlet weak var curAArea: UILabel!
    @IBOutlet weak var nextAArea: UILabel!
    @IBOutlet weak var curBArea: UILabel!
    @IBOutlet weak var nextBArea: UILabel!
    @IBOutlet weak var curActive: UILabel!
    @IBOutlet weak var nextActive: UILabel!
    @IBOutlet weak var curCard: UILabel!
    @IBOutlet weak var nextCard: UILabel!
    
    @IBOutlet weak var rewardLabel: UILabel!
    @IBOutlet weak var remarkLabel: LineHeightLabel!
    @IBOutlet weak var upgradeBtn: UIButton!
    
    @IBOutlet weak var ruleViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var containerViewWidth: NSLayoutConstraint!
    
    private var model = UpgradeRuleModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.ss.showHUDLoading()
        requestData()
    }
    
    override func buildUI() {
        fakeNav.title = "升级规则"
        
        containerViewWidth.constant = SS.w
        
        curTitle.loadOption([.cornerCut(8, [.topLeft, .topRight])])
        nextTitle.loadOption([.cornerCut(8, [.topLeft, .topRight])])
        
        userIcon.ss_setImage(APP.userInfo.avatar, placeholder: SSImage.userDefault)
        userName.text = APP.userInfo.name
        userMobile.text = APP.userInfo.mobile
        userId.text = "ID:\(APP.loginData.userId)"
        vipRate.text = "费率:\(APP.userInfo.rate.fixedZero())%"
        
        upgradeBtn.drawThemeGradient(CGSize(width: SS.w - 24, height: 40))
        vipBtn.isHidden = true
    }
    
    func requestData() {
        HttpApi.Mine.getUpgradeRule().done { [weak self] data in
            self?.model = data.kj.model(UpgradeRuleModel.self)
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.updateViews()
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.toast(message: error.localizedDescription)
            }
        }
    }
    
    func updateViews() {
        let level = DataManager.vipList.firstIndex(of: model.currentLevel) ?? 0
        vipBtn.image = UIImage(named: "ic_mine_vip_\(level + 1)")
        vipBtn.isHidden = false
        
        curLevel.text = model.currentLevel
        curLabel.text = model.currentLevel
        curAArea.text = model.myAPerformance.fixedZero()
        curBArea.text = model.myBPerformance.fixedZero()
        curActive.text = "\(model.activeNum)"
        curCard.text = model.isHaveCard == 1 ? "已持有" : "暂无"

        nextLabel.text = model.nextLevel
        nextAArea.text = model.needAPerformance.fixedZero()
        nextBArea.text = model.needBPerformance.fixedZero()
        nextActive.text = "\(model.needActiveNum)"
        nextCard.text = model.haveCardName.isEmpty ? "暂无" : model.haveCardName

        rewardLabel.text = model.giveCardName.isEmpty ? "暂无" : model.giveCardName

        remarkLabel.text = model.remark
        let remarkHeight = model.remark.height(from: .ss_regular(size: 14), width: SS.w - 48, lineHeight: 17)
        ruleViewHeight.constant = 415 + remarkHeight
    }
    
    @IBAction func toUpgrade(_ sender: Any) {
        
    }
    
}
