//
//  ConvertRateTipView.swift
//  Huatao
//
//  Created on 2023/1/29.
//

import UIKit

class ConvertRateTipView: UIView {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var doneBtn: UIButton!
    
    var completeBlock: NoneBlock?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        doneBtn.drawGradient(start: .hex("ffa300"), end: .hex("ff8100"), size: CGSize(width: 220, height: 40), direction: .l2r)
    }
    
    static func show(name: String, rate: String, complete: NoneBlock? = nil)  {
        let view = fromNib()
        view.completeBlock = complete
        view.config(name: name, rate: rate)

        let config = OverlayConfig()
        config.name = view.named
        config.width = 280
        config.height = 220
        config.location = .center
        config.overlayBackMode = .color(color: .black.withAlphaComponent(0.6))
        config.contentAnimation = ZoomOutAniamtion()
        SSOverlayController.show(view, config: config)
    }
    
    func config(name: String, rate: String) {
        nameLabel.text = "您是\(name)银豆转换金豆费率为"
        rateLabel.text = rate.fixedZero() + "%"
    }
    
    @IBAction func toDone(_ sender: Any) {
        completeBlock?()
        SSOverlayController.dismiss(named)
    }
    
}
