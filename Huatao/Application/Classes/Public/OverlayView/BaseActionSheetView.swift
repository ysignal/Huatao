//
//  BaseActionSheetView.swift
//  Huatao
//
//  Created on 2023/3/2.
//  
	

import UIKit

class BaseActionSheetView: UIView {

    @IBOutlet weak var actionTV: UITableView!
    @IBOutlet weak var cancelBtn: UIButton!
    
    private var list: [String] = []

    private var completionBlock: IntBlock?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        buildUI()
    }

    private func buildUI() {
        ex_width = SS.w
        loadOption([.cornerCut(16, [.topLeft, .topRight])])
        
        actionTV.register(nibCell: BaseActionItemCell.self)
    }

    static func show(list: [String], completion: IntBlock? = nil)  {
        let view = fromNib()
        view.config(list: list)
        view.completionBlock = completion
        
        let config = OverlayConfig()
        config.name = view.named
        config.width = SS.w
        // 列表最多显示8个
        config.height = CGFloat(min(8, list.count)) * 50 + 60 + SS.safeBottomHeight
        config.location = .bottom
        config.statusBarStyle = .lightContent
        config.overlayBackMode = .color(color: .black.withAlphaComponent(0.8))
        config.contentAnimation = TranslationAnimation(direction: .bottom)
        SSOverlayController.show(view, config: config)
    }

    func config(list: [String]) {
        self.list = list
        actionTV.reloadData()
        actionTV.isScrollEnabled = list.count > 8
    }
    
    @IBAction func toCancel(_ sender: Any) {
        SSOverlayController.dismiss(named)
    }
    
}

extension BaseActionSheetView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        completionBlock?(indexPath.row)
        SSOverlayController.dismiss(named)
    }

}

extension BaseActionSheetView: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: BaseActionItemCell.self)
        cell.titleLabel.text = list[indexPath.row]
        return cell
    }

}
