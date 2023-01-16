//
//  SSCaptionView.swift
//  Huatao
//
//  Created by minse on 2023/1/16.
//

import UIKit

class SSCaptionView: UIToolbar {
    
    private let labelPadding: CGFloat = 10
    
    var photo: SSPhoto?
    
    lazy var label: UILabel = {
        let lb = UILabel()
        lb.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        lb.isOpaque = false
        lb.backgroundColor = .clear
        lb.textAlignment = .center
        lb.lineBreakMode = .byWordWrapping
        
        lb.numberOfLines = 0
        lb.textColor = .white
        lb.font = .systemFont(ofSize: 17)
        return lb
    }()
    
    init(photo: SSPhoto) {
        super.init(frame: CGRect(x: 0, y: 0, width: SS.w, height: 44))
        isUserInteractionEnabled = false
        tintColor = nil
        barTintColor = nil
        barStyle = .blackTranslucent
        setBackgroundImage(nil, forToolbarPosition: .any, barMetrics: .default)
        autoresizingMask = [.flexibleWidth, .flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin]
        self.photo = photo
        setupCaption()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var maxHeight: CGFloat = 9999
        if label.numberOfLines > 0 {
            maxHeight = label.font.leading * CGFloat(label.numberOfLines)
        }
        if let textSize = (label.text as? NSString)?.boundingRect(with: CGSize(width: size.width - labelPadding*2, height: maxHeight), options: .usesLineFragmentOrigin, attributes: [.font: UIFont.systemFont(ofSize: 17)], context: nil).size {
            return CGSize(width: size.width, height: textSize.height + labelPadding * 2)
        }
        return size
    }

    func setupCaption() {
        label.frame = CGRectIntegral(CGRectMake(labelPadding, 0,
                                                self.bounds.size.width-labelPadding*2,
                                                self.bounds.size.height))
        if let p = photo {
            label.text = p.caption
        }
        
        addSubview(label)
    }
}
