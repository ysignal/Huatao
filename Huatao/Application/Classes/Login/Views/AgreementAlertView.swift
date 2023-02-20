//
//  AgreementAlertView.swift
//  Huatao
//
//  Created on 2023/1/13.
//

import WebKit

class AgreementAlertView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var wkWeb: WKWebView!
    @IBOutlet weak var agreeBtn: UIButton!
    @IBOutlet weak var closeBtn: UIButton!
    
    private var completionBlock: BoolBlock?

    override func awakeFromNib() {
        super.awakeFromNib()
        buildUI()
    }
    
    private func buildUI() {
        backgroundColor = .white
        wkWeb.backgroundColor = .white
    }

    static func show(title: String, urlString: String, completion: @escaping BoolBlock)  {
        let view = fromNib()
        view.completionBlock = completion
        view.titleLabel.text = title
        if let url = URL(string: urlString) {
            view.wkWeb.load(URLRequest(url: url))
        }
        
        let config = OverlayConfig()
        config.name = view.named
        config.width = SS.w - 60
        config.height = 450
        config.location = .center
        config.overlayBackMode = .color(color: .black.withAlphaComponent(0.8))
        config.contentAnimation = ZoomOutAniamtion()
        SSOverlayController.show(view, config: config)
    }
    
    @IBAction func toAgree(_ sender: Any) {
        completionBlock?(true)
        SSOverlayController.dismiss(named)
    }
    
    @IBAction func toClose(_ sender: Any) {
        completionBlock?(false)
        SSOverlayController.dismiss(named)
    }

}
