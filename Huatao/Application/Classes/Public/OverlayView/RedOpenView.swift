//
//  RedOpenView.swift
//  Huatao
//
//  Created on 2023/3/3.
//  
	

import UIKit

class RedOpenView: UIView {
    
    @IBOutlet weak var closeBtn: SSButton!
    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var redDesc: UILabel!
    @IBOutlet weak var redMessage: UILabel!
    @IBOutlet weak var openBtn: UIButton!
    
    private var completionBlock: NoneBlock?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        buildUI()
    }

    private func buildUI() {
        backgroundColor = .clear
    }

    static func show(model: RCRedModel, completion: NoneBlock? = nil)  {
        let view = fromNib()
        view.config(model: model)
        view.completionBlock = completion
        
        let config = OverlayConfig()
        config.name = view.named
        config.width = 240
        // 列表最多显示8个
        config.height = 300
        config.location = .center
        config.statusBarStyle = .lightContent
        config.overlayBackBehavior = .none
        config.overlayBackMode = .color(color: .black.withAlphaComponent(0.6))
        config.contentAnimation = ZoomOutAniamtion()
        SSOverlayController.show(view, config: config)
    }
    
    func config(model: RCRedModel) {
        userIcon.ss_setImage(model.avatar, placeholder: SSImage.userDefault)
        userName.text = model.name
        let typeStr = model.type == 1 ? "现金" : "银豆"
        redDesc.text = "给你发了一个\(typeStr)红包"
        redMessage.text = model.message
        
    }
    
    @IBAction func toClose(_ sender: Any) {
        SSOverlayController.dismiss(named)
    }
    
    @IBAction func toOpen(_ sender: Any) {
        SSOverlayController.dismiss(named)
        completionBlock?()
    }
    
}
