//
//  CircleDetailViewController.swift
//  Huatao
//
//  Created on 2023/2/16.
//  
	

import UIKit
import IQKeyboardManagerSwift

class CircleDetailViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var headerView: CircleDetailHeaderView = {
        return CircleDetailHeaderView.fromNib()
    }()
    @IBOutlet weak var toolbarView: UIView!
    @IBOutlet weak var toolbarStack: UIStackView!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var likeView: UIView!
    @IBOutlet weak var likeImage: UIImageView!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var shareView: UIView!
    
    @IBOutlet weak var toolbarBottom: NSLayoutConstraint!
    @IBOutlet weak var toolbarTFTrailing: NSLayoutConstraint!
    @IBOutlet weak var commentTF: UITextField!
    @IBOutlet weak var sendBtn: UIButton!
    
    private var defaultPlaseholder: String = "走心，说点好听的..."
    
    private var model = DynamicDetailModel()
        
    private var toUserId: Int = 0
    
    private var topPid: Int = 0
    
    private var openDict: [Int: Bool] = [:]
    
    var dynamicItem = DynamicListItem()
    
    var dynamicId: Int = 0

    var updateBlock: NoneBlock?

    override func viewDidLoad() {
        super.viewDidLoad()

        requestData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = false
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillChange(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    override func buildUI() {
        fakeNav.title = "详情"
        
        sendBtn.drawGradient(start: .hex("ffa300"), end: .hex("ff8100"), size: CGSize(width: 50, height: 26), direction: .l2r)
        sendBtn.alpha = 0
        
        tableView.register(nibCell: CommentListCell.self)
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = UIView()
        
        likeView.addGesture(.tap) { tap in
            if tap.state == .ended {
                self.toLike()
            }
        }
        
        commentView.addGesture(.tap) { tap in
            if tap.state == .ended {
                self.commentTF.becomeFirstResponder()
            }
        }
        
        shareView.addGesture(.tap) { tap in
            if tap.state == .ended {
                self.toShare()
            }
        }
    }
    
    func requestData() {
        view.ss.showHUDLoading()
        HttpApi.Find.getDynamicDetail(dynamicId: dynamicId).done { [weak self] data in
            self?.model = data.kj.model(DynamicDetailModel.self)
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.updateListView()
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.toast(message: error.localizedDescription)
            }
        }
    }

    func updateListView() {
        headerView.config(item: model, delegate: self)
        
        for item in model.commnetArray {
            if !openDict.has(key: item.commentId) {
                openDict[item.commentId] = false
            }
        }
        tableView.reloadData()
        
        likeLabel.text = "\(model.likeCount)"
        commentLabel.text = "\(model.dynamicCommentCount)"
        updateLikeImage()
    }
    
    func updateLikeImage() {
        likeImage.image = dynamicItem.isLike == 1 ? UIImage(named: "ic_like_on") : UIImage(named: "ic_like_off")
    }
    
    //MARK: - KeyBoard

    @objc func keyBoardWillChange(_ note: Notification) {
        let userInfo = note.userInfo
        // 获取键盘高度
        guard let keyboardRect = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyBoardHeight = SS.h - keyboardRect.origin.y
        var duration: TimeInterval = 0.25
        if let d = userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval {
            duration = d
        }
        var offset = tableView.contentOffset
        if keyBoardHeight > 0 {
            offset.y += keyBoardHeight
        }
        DispatchQueue.main.async {
            self.updateViewConstraints()
            UIView.animate(withDuration: duration) {
                self.toolbarBottom.constant = max(0, keyBoardHeight - SS.safeBottomHeight)
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func toLike() {
        let isLike = dynamicItem.isLike == 1
        HttpApi.Find.putDynamicLike(dynamicId: dynamicId).done { [weak self] _ in
            guard let weakSelf = self else { return }
            SSMainAsync {
                weakSelf.dynamicItem.isLike = isLike ? 0 : 1
                if isLike {
                    SS.keyWindow?.toast(message: "取消点赞成功！")
                } else {
                    SS.keyWindow?.toast(message: "点赞成功！")
                }
                weakSelf.requestData()
                weakSelf.updateBlock?()
            }
        }.catch { error in
            SSMainAsync {
                SS.keyWindow?.toast(message: error.localizedDescription)
            }
        }
    }
    
    func toShare() {
        toast(message: "分享功能正在开发中...")
    }
    
    func toSendComment(toUserId: Int, topPid: Int) {
        commentTF.resignFirstResponder()
        guard let content = commentTF.text, !content.isEmpty else { toast(message: "评论内容不能为空"); return }
        
        view.ss.showHUDLoading()
        HttpApi.Find.postDynamicComment(dynamicId: dynamicId, content: content, toUserId: toUserId, topPid: topPid).done { [weak self] _ in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.toast(message: "评论成功")
                self?.commentTF.text = ""
                self?.requestData()
                self?.updateBlock?()
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.toast(message: error.localizedDescription)
            }
        }
    }
    
    @IBAction func toSend(_ sender: Any) {
        toSendComment(toUserId: self.toUserId, topPid: self.topPid)
    }
    
    func toCommentLike(_ commentId: Int) {
        view.ss.showHUDLoading()
        HttpApi.Find.putCommentLike(commentId: commentId).done { [weak self] _ in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.requestData()
                self?.updateBlock?()
            }
        }.catch { [weak self] error in
            SSMainAsync {
                self?.view.ss.hideHUD()
                self?.toast(message: error.localizedDescription)
            }
        }
    }
    
}

extension CircleDetailViewController: CircleDetailHeaderViewDelegate {
    
    func headerViewStartPlayVideo(_ url: String, image: UIImage?) {
        let vc = VideoPlayViewController()
        vc.urlString = url
        vc.videoImage = image
        present(vc, animated: true)
    }
    
    func headerViewPreviewImages(_ images: [String], index: Int) {
        let vc = PreviewViewController()
        vc.configPreview(images, index: index)
        go(vc)
    }
    
    func headerViewClickedAddFriend() {
        let vc = UserDetailViewController.from(sb: .chat)
        vc.userId = dynamicItem.userId
        go(vc)
    }
    
    func headerViewDidDeleteDynamic() {
        self.updateBlock?()
        self.back()
    }
    
}

extension CircleDetailViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        toSendComment(toUserId: self.toUserId, topPid: self.topPid)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.25) {
            self.toolbarTFTrailing.constant = 74
            self.toolbarStack.alpha = 0
            self.sendBtn.alpha = 1
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.25) {
            self.toolbarTFTrailing.constant = 200
            self.toolbarStack.alpha = 1
            self.sendBtn.alpha = 0
        }
        // 结束编辑状态，初始化数据
        topPid = 0
        toUserId = 0
        textField.placeholder = defaultPlaseholder
    }
    
}

extension CircleDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = model.commnetArray[indexPath.row]
        let contentHeight = item.content.height(from: .ss_semibold(size: 14), width: SS.w - 68, lineHeight: 20)
        if openDict.has(key: item.commentId) && openDict[item.commentId] == true {
            let childrenHeight: CGFloat = item.children.compactMap({ $0.content.height(from: .ss_semibold(size: 14), width: SS.w - 96, lineHeight: 20) + 56 }).reduce(0, +)
            return 70 + contentHeight + childrenHeight
        } else {
            if item.children.isEmpty {
                return 70 + contentHeight
            }
        }
        return 100 + contentHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        
        let lb = UILabel(text: "评论 \(model.dynamicCommentCount)", textColor: .hex("333333"), textFont: .ss_semibold(size: 14))
        view.addSubview(lb)
        lb.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
        }
        
        return view
    }
    
}

extension CircleDetailViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.commnetArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: CommentListCell.self)
        let item = model.commnetArray[indexPath.row]
        cell.config(item: item, isOpen: openDict[item.commentId] ?? false, delegate: self)
        return cell
    }
    
}

extension CircleDetailViewController: CommentListCellDelegate {
    
    func cellChildrenOpen(_ item: CommentListItem) {
        openDict[item.commentId] = true
        tableView.reloadData()
    }
    
    func cellComment(_ item: CommentListItem) {
        topPid = item.commentId
        toUserId = item.sendUserId
        commentTF.placeholder = "回复 \(item.sendUser):"
        commentTF.becomeFirstResponder()
    }
    
    func cellCommentChildren(_ item: CommentListItem, children: CommentChildrenItem) {
        topPid = item.commentId
        toUserId = children.sendUserId
        commentTF.placeholder = "回复 \(children.sendUser):"
        commentTF.becomeFirstResponder()
    }
    
    func cellLike(_ item: CommentListItem) {
        toCommentLike(item.commentId)
    }
    
    func cellChildrenLike(_ item: CommentChildrenItem) {
        toCommentLike(item.commentId)
    }
    
}
