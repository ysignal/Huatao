//
//  PayWaySelectView.swift
//  Huatao
//
//  Created on 2023/2/24.
//  
	

import UIKit

fileprivate struct PayWayItem {
    
    var icon: String = ""
    
    var title: String = ""
    
    var tag: String = ""
    
}

class PayWaySelectView: UIView {
    
    private lazy var descLabel: UILabel = {
        return UILabel(text: "待支付金额", textColor: .ss_99, textFont: .ss_regular(size: 14))
    }()
    
    private lazy var moneyLabel: UILabel = {
        return UILabel(text: "", textColor: .ss_theme, textFont: .ss_semibold(size: 14))
    }()

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: bounds, style: .plain)
        tv.delegate = self
        tv.dataSource = self
        tv.separatorInset = .zero
        tv.tableFooterView = UIView()
        tv.backgroundColor = .clear
        tv.separatorColor = .ss_ee
        tv.isScrollEnabled = false
        tv.register(PayWayItemCell.self, forCellReuseIdentifier: "cell")
        return tv
    }()
    
    lazy var payBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.title = "支付"
        btn.titleFont = .ss_regular(size: 16)
        btn.titleColor = .white
        btn.addTarget(self, action: #selector(toPay), for: .touchUpInside)
        btn.cornerRadius = 20
        btn.backgroundColor = .ss_dd
        return btn
    }()
    
    private var list: [PayWayItem] = [PayWayItem(icon: "ic_pay_alipay", title: "支付宝", tag: "alipay"),
                                      PayWayItem(icon: "ic_pay_wechat", title: "微信", tag: "wechat")]
    
    var completionBlock: StringBlock?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        buildUI()
    }
    
    func buildUI() {
        backgroundColor = .white
        ex_width = SS.w
        loadOption([.cornerCut(8, [.topLeft, .topRight], CGSize(width: SS.w, height: 204 + (CGFloat(list.count)*44) + SS.safeBottomHeight))])
        
        addSubview(descLabel)
        descLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.centerX.equalToSuperview()
            make.height.equalTo(20)
        }
        
        addSubview(moneyLabel)
        moneyLabel.snp.makeConstraints { make in
            make.top.equalTo(descLabel.snp.bottom).offset(10)
            make.height.equalTo(56)
            make.centerX.equalToSuperview()
        }
        
        let tableHeight = CGFloat(list.count) * 44
        addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(120)
            make.height.equalTo(tableHeight)
        }
        
        let line = UIView(backgroundColor: .ss_ee)
        addSubview(line)
        line.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(tableView.snp.top)
            make.height.equalTo(0.5)
        }
        
        addSubview(payBtn)
        payBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.top.equalTo(tableView.snp.bottom).offset(20)
            make.height.equalTo(40)
        }
        payBtn.isEnabled = false
    }
    
    static func show(_ item: ShopGiftItem, completion: StringBlock? = nil)  {
        let view = PayWaySelectView(frame: .zero)
        view.completionBlock = completion
        view.config(item: item)
        
        let config = OverlayConfig()
        config.name = view.named
        config.width = SS.w
        config.height = 204 + (CGFloat(view.list.count)*44) + SS.safeBottomHeight
        config.location = .bottom
        config.statusBarStyle = .lightContent
        config.overlayBackMode = .color(color: .black.withAlphaComponent(0.8))
        config.contentAnimation = TranslationAnimation(direction: .bottom)
        SSOverlayController.show(view, config: config)
    }

    func config(item: ShopGiftItem) {
        let mulStr = NSMutableAttributedString()
        mulStr.append(NSAttributedString(string: "¥ ", attributes: [.font: UIFont.ss_semibold(size: 14), .foregroundColor: UIColor.ss_theme]))
        mulStr.append(NSAttributedString(string: item.money.fixedZero(), attributes: [.font: UIFont.ss_semibold(size: 40), .foregroundColor: UIColor.ss_theme]))
        moneyLabel.attributedText = mulStr
        tableView.reloadData()
    }
    
    @objc func toPay() {
        if let path = tableView.indexPathForSelectedRow {
            let item = list[path.row]
            completionBlock?(item.tag)
        }
        SSOverlayController.dismiss(named)
    }
    
}

extension PayWaySelectView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        payBtn.isEnabled = true
        payBtn.drawThemeGradient(CGSize(width: SS.w - 24, height: 40))
    }
    
}

extension PayWaySelectView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: PayWayItemCell.self)
        let item = list[indexPath.row]
        cell.iconIV.image = UIImage(named: item.icon)
        cell.lblTitle.text = item.title
        return cell
    }
    
}

fileprivate class PayWayItemCell: UITableViewCell {
    
    lazy var iconIV: UIImageView = {
        return UIImageView()
    }()

    lazy var lblTitle: UILabel = {
        let lb = UILabel()
        lb.textColor = .black
        lb.textAlignment = .center
        lb.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return lb
    }()
    
    lazy var radioIV: UIImageView = {
        return UIImageView()
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        radioIV.image = selected ? SSImage.radioOn : SSImage.radioOff
    }
    
    func buildUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        contentView.addSubview(iconIV)
        iconIV.snp.makeConstraints {
            $0.width.height.equalTo(20)
            $0.leading.equalToSuperview().offset(12)
            $0.centerY.equalToSuperview()
        }
        
        contentView.addSubview(radioIV)
        radioIV.snp.makeConstraints {
            $0.width.height.equalTo(18)
            $0.trailing.equalToSuperview().offset(-12)
            $0.centerY.equalToSuperview()
        }
        
        contentView.addSubview(lblTitle)
        lblTitle.snp.makeConstraints {
            $0.leading.equalTo(iconIV.snp.trailing).offset(8)
            $0.centerY.equalToSuperview()
        }
    }

}
