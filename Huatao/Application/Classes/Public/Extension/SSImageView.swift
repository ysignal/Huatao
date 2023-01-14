//
//  SSImageView.swift
//  Huatao
//
//  Created by minse on 2023/1/13.
//

import KingfisherWebP

extension UIImageView {
    
    func ss_setImage(_ path: String, placeholder: UIImage?) {
        if path.hasPrefix("http") {
            self.kf.setImage(with: URL(string: path), placeholder: placeholder, options: [.processor(WebPProcessor.default), .cacheSerializer(WebPSerializer.default), .transition(.fade(0.25))])
        } else if !path.isEmpty, let img = UIImage(named: path) {
            self.image = img
        } else {
            self.image = placeholder
        }
    }
    
}
