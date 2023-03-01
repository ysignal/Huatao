//
//  PopoverMenuView.swift
//  Huatao
//
//  Created on 2023/2/23.
//  
	

import UIKit

class PopoverMenuView: UIView {

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: bounds, style: .plain)
        tv.delegate = self
        tv.dataSource = self
        tv.rowHeight = rowHeight
        tv.separatorInset = .zero
        tv.tableFooterView = UIView()
        tv.backgroundColor = .clear
        tv.separatorColor = .hex("eeeeee")
        tv.register(PopoverMenuViewCell.self, forCellReuseIdentifier: "cell")
        return tv
    }()
    
    var dataSource: [String] = []
    var didSelectBlock: ((_ index: Int) -> Void)?
    var textColor: UIColor = .white
    var textAlignment: NSTextAlignment = .left
    private let rowHeight: CGFloat = 44

    // MARK: - Init
    init(dataSource: [String], width: CGFloat = 110, color: UIColor = .white, textAlignment: NSTextAlignment = .left, didSelectBlock: @escaping ((_ index: Int) -> Void)) {
        self.textColor = color
        self.dataSource = dataSource
        self.didSelectBlock = didSelectBlock
        self.textAlignment = textAlignment
        let viewHeight: CGFloat = rowHeight * CGFloat(min(dataSource.count, 6))
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: viewHeight))
        initSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubviews() {

        addSubview(tableView)
    }
}

extension PopoverMenuView: UITableViewDataSource, UITableViewDelegate {
    // MARK: - UITableView
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        didSelectBlock?(indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PopoverMenuViewCell
        cell.lblTitle.text = dataSource[indexPath.row]
        cell.lblTitle.textColor = textColor
        cell.lblTitle.textAlignment = .left
        cell.separatorInset = indexPath.row == dataSource.count - 1 ? UIEdgeInsets(top: 0, left: frame.width, bottom: 0, right: 0) : .zero
        return cell
    }
}


fileprivate class PopoverMenuViewCell: UITableViewCell {

    lazy var lblTitle: UILabel = {
        let lb = UILabel()
        lb.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        lb.textAlignment = .center
        lb.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return lb
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buildUI() {
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        backgroundColor = .clear

        contentView.addSubview(lblTitle)
        lblTitle.snp.makeConstraints {
            $0.leading.equalTo(15)
            $0.trailing.equalTo(-15)
            $0.centerY.equalToSuperview()
        }
    }

}
