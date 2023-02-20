//
//  ChatMoreView.swift
//  Huatao
//
//  Created on 2023/2/17.
//  
	

import UIKit

class ChatMoreView: UIView {
    
    lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.isScrollEnabled = false
        tv.delegate = self
        tv.dataSource = self
        tv.separatorColor = .hex("666666")
        tv.backgroundColor = .clear
        return tv
    }()

    var actionBlock: IntBlock?

    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func buildUI() {
        backgroundColor = .clear
        
        addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.bottom.right.equalToSuperview()
        }
        tableView.register(cell: ChatMoreCell.self)
        tableView.tableFooterView = UIView()
        
        tableView.reloadData()
    }
        
}

extension ChatMoreView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        actionBlock?(indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 2 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: SS.w, bottom: 0, right: 0)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
    
}

extension ChatMoreView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: ChatMoreCell.self)
        switch indexPath.row {
        case 0:
            cell.config(icon: "ic_chat_menu_group", title: "发起群聊")
        case 1:
            cell.config(icon: "ic_chat_menu_add", title: "添加朋友")
        case 2:
            cell.config(icon: "ic_chat_menu_scan", title: "扫一扫")
        default:
            break
        }
        return cell
    }
    
}

class ChatMoreCell: UITableViewCell {
    
    lazy var actionIcon: UIImageView = {
        return UIImageView()
    }()
    
    lazy var actionLabel: UILabel = {
        return UILabel(text: nil, textColor: .white, textFont: .ss_regular(size: 14))
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        buildUI()
    }
    
    func buildUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(actionIcon)
        actionIcon.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        contentView.addSubview(actionLabel)
        actionLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(39)
            make.centerY.equalToSuperview()
        }
    }
    
    func config(icon: String, title: String) {
        actionIcon.image = UIImage(named: icon)
        actionLabel.text = title
    }
    
}
