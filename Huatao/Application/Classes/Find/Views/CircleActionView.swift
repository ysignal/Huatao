//
//  CircleActionView.swift
//  Huatao
//
//  Created by minse on 2023/1/29.
//

import UIKit

class CircleActionView: UIView {
    
    lazy var likeView: UIView = {
        return buildLikeView()
    }()
    
    lazy var commentView: UIView = {
        return buildCommentView()
    }()

    lazy var stackView: UIStackView = {
        let sk = UIStackView(arrangedSubviews: [likeView, commentView])
        sk.axis = .horizontal
        sk.spacing = 0
        sk.distribution = .fillEqually
        return sk
    }()
    
    var selectedBlock: IntBlock?
    
    init(size: CGSize) {
        super.init(frame: CGRect(origin: .zero, size: size))
        buildUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        buildUI()
    }
    
    func buildUI() {
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let line = UIView()
        line.backgroundColor = .hex("373636")
        addSubview(line)
        line.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalTo(18)
        }
        
        likeView.addGesture(.tap) { tap in
            if tap.state == .ended {
                self.selectedBlock?(1)
            }
        }
        
        commentView.addGesture(.tap) { tap in
            if tap.state == .ended {
                self.selectedBlock?(2)
            }
        }
    }
    
    func buildLikeView() -> UIView {
        let view = UIView()
        
        let lb = UILabel().loadOption([.font(.ss_regular(size: 12)), .textColor(.white), .text("赞")])
        view.addSubview(lb)
        lb.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview().offset(10)
        }
        
        let iv = UIImageView(image: UIImage(named: "ic_find_like_white"))
        view.addSubview(iv)
        iv.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(lb.snp.left).offset(-4)
        }
        
        return view
    }
    
    func buildCommentView() -> UIView {
        let view = UIView()
        
        let lb = UILabel().loadOption([.font(.ss_regular(size: 12)), .textColor(.white), .text("评论")])
        view.addSubview(lb)
        lb.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview().offset(10)
        }
        
        let iv = UIImageView(image: UIImage(named: "ic_find_comment_white"))
        view.addSubview(iv)
        iv.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(lb.snp.left).offset(-4)
        }
        
        return view
    }
    
}
