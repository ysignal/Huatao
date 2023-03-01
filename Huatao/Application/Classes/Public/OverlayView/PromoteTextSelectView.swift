//
//  PromoteTextSelectView.swift
//  Huatao
//
//  Created on 2023/2/28.
//  
	

import UIKit

class PromoteTextSelectView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var closeBtn: SSButton!
    @IBOutlet weak var copyBtn: UIButton!
    
    var list: [SendTextListItem] = []
    
    var selectItem: SendTextListItem? {
        didSet {
            copyBtn.drawThemeGradient(CGSize(width: SS.w - 24, height: 40))
        }
    }
    
    var page: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        buildUI()
        requestData()
    }
    
    private func buildUI() {
        backgroundColor = .white
        ex_width = SS.w
        
        copyBtn.backgroundColor = .hex("dddddd")

        loadOption([.cornerCut(16, [.topLeft, .topRight])])
        tableView.addRefresh(type: .footer, delegate: self)
        tableView.register(nibCell: PromoteTextItemCell.self)
    }

    static func show(completion: ((String) -> Void)? = nil)  {
        let view = fromNib()
        
        let config = OverlayConfig()
        config.name = view.named
        config.width = SS.w
        config.height = 450 + SS.safeBottomHeight
        config.location = .bottom
        config.overlayBackMode = .color(color: .black.withAlphaComponent(0.8))
        config.contentAnimation = TranslationAnimation(direction: .bottom)
        SSOverlayController.show(view, config: config)
    }
    
    func requestData() {
        HttpApi.Task.getSendTextList(page: page).done { [weak self] data in
            guard let weakSelf = self else { return }
            let listModel = data.kj.model(ListModel<SendTextListItem>.self)
            if weakSelf.page == 1 {
                weakSelf.list = listModel.list
            } else {
                weakSelf.list.append(contentsOf: listModel.list)
            }
            SSMainAsync {
                if weakSelf.list.count < listModel.total {
                    weakSelf.tableView.mj_footer?.resetNoMoreData()
                } else {
                    weakSelf.tableView.mj_footer?.endRefreshingWithNoMoreData()
                }
                weakSelf.ss.hideHUD()
                weakSelf.tableView.reloadData()
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.ss.hideHUD()
                self?.tableView.endRefreshing()
                self?.toast(message: error.localizedDescription)
            }
        }
    }

    @IBAction func toClose(_ sender: Any) {
        SSOverlayController.dismiss(named)
    }
    
    @IBAction func toCopy(_ sender: Any) {
        if let item = selectItem {
            UIPasteboard.general.string = item.content
            globalToast(message: "复制成功")
            SSOverlayController.dismiss(named)
        }
    }
    
}

extension PromoteTextSelectView: UIScrollViewRefreshDelegate {
    
    func scrollViewFooterRefreshData(_ scrollView: UIScrollView) {
        page += 1
        requestData()
    }
    
}

extension PromoteTextSelectView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = list[indexPath.row]
        let textHeight = item.content.height(from: .systemFont(ofSize: 14), width: SS.w - 48)
        return textHeight + 36
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectItem = list[indexPath.row]
    }
    
}

extension PromoteTextSelectView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: PromoteTextItemCell.self)
        let item = list[indexPath.row]
        cell.config(item: item)
        return cell
    }
    
}
