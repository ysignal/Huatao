//
//  ConversationViewController.swift
//  Huatao
//
//  Created on 2023/2/20.
//  
	

import UIKit
import IQKeyboardManagerSwift

class ConversationViewController: RCConversationViewController {
    
    private let RED_PACKET_TAG: Int = 1104
    
    var fakeNav: SSNavigationBar = SSNavigationBar()
    
    lazy var moreBtn: SSButton = {
        let btn = SSButton(type: .custom)
        btn.image = UIImage(named: "ic_find_more")?.color(.hex("666666"))
        return btn
    }()
    
    lazy var disturbView: UIView = {
        let view = UIView(backgroundColor: .clear)
        
        let iv = UIImageView(image: UIImage(named: "ic_chat_disturb"))
        iv.contentMode = .scaleAspectFit
        view.addSubview(iv)
        iv.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(12)
            make.height.equalToSuperview()
        }
        
        return view
    }()
    
    lazy var background: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    var notificationLevel: RCPushNotificationLevel = .allMessage
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buildUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateBackground()
        IQKeyboardManager.shared.enable = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
    }
    
    func buildUI() {
        // 配置自定义页面
        view.backgroundColor = .ss_f6
        view.addSubview(fakeNav)
        fakeNav.snp.makeConstraints({
            $0.left.right.top.equalToSuperview()
            $0.height.equalTo(SS.statusWithNavBarHeight)
        })
        fakeNav.leftButtonHandler = {
            self.back()
        }
        fakeNav.leftImage = SSImage.back
        
        fakeNav.titleStack.addArrangedSubview(disturbView)
        disturbView.snp.makeConstraints { make in
            make.width.equalTo(18)
        }
        
        fakeNav.addSubview(moreBtn)
        moreBtn.snp.makeConstraints { make in
            make.width.equalTo(30)
            make.height.equalTo(24)
            make.right.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-10)
        }
        moreBtn.addTarget(self, action: #selector(toMore), for: .touchUpInside)
        
        view.insertSubview(background, at: 0)
        background.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(SS.statusWithNavBarHeight)
        }
        // 移除中间页面
        navigationController?.navRemove([SelectUserViewController.self])
        // 更新免打扰设置
        updateLevelView()
        // 设置聊天列表背景透明
        conversationMessageCollectionView.backgroundColor = .clear
        // 允许提示新消息
        enableNewComingMessageIcon = true
        // 修改头像大小
        RCKitConfig.default().ui.globalMessagePortraitSize = CGSize(width: 36, height: 36)
        // 私聊需要请求个人详情获取背景
        if conversationType == .ConversationType_PRIVATE {
            requestUserDetail()
        }
        // 添加添加红包控件
        chatSessionInputBarControl.pluginBoardView.insertItem(UIImage(named: "plugin_item_red"), highlightedImage: UIImage(named: "plugin_item_red_highlight"), title: "红包", at: 2, tag: RED_PACKET_TAG)
    }

    func requestUserDetail() {
        let userId = targetId.intValue
        HttpApi.Chat.getFriendDetail(userId: userId).done { [weak self] data in
            let model = data.kj.model(FriendDetailModel.self)
            IMManager.shared.updateUser(model)
            SSMainAsync {
                self?.background.ss_setImage(model.backgroundImg, placeholder: nil)
            }
        }
    }
    
    func updateBackground() {
        if conversationType == .ConversationType_PRIVATE {
            SSCacheLoader.loadIMUser(from: targetId.intValue) { [weak self] data in
                if let user = data {
                    self?.background.ss_setImage(user.backgroundImage, placeholder: nil)
                }
            }
        }
    }
    
    func updateLevelView() {
        if notificationLevel == .blocked {
            disturbView.isHidden = false
        } else {
            disturbView.isHidden = true
        }
    }
    
    override func pluginBoardView(_ pluginBoardView: RCPluginBoardView!, clickedItemWithTag tag: Int) {
        super.pluginBoardView(pluginBoardView, clickedItemWithTag: tag)
        // 工具面板点击事件
        switch tag {
        case RED_PACKET_TAG:
            // 点击了红包
            let vc = RedPacketViewController.from(sb: .chat)
            vc.targetId = targetId
            vc.conversationType = conversationType
            go(vc)
        default:
            break
        }
    }

    override func registerCustomCellsAndMessages() {
        super.registerCustomCellsAndMessages()
        
        // 注册自定义消息
        register(HTRedMessageCell.self, forMessageClass: HTRedMessage.self)
    }
    
    override func willDisplayMessageCell(_ cell: RCMessageBaseCell!, at indexPath: IndexPath!) {
        if let msgCell = cell as? RCMessageCell {
            msgCell.portraitImageView.layer.cornerRadius = 14
            msgCell.portraitImageView.contentMode = .scaleAspectFill
        }
    }
    
    override func didTapMessageCell(_ model: RCMessageModel!) {
        super.didTapMessageCell(model)
        
        if let redContent = model.content as? HTRedMessage, let m = redContent.model {
            if model.senderUserId.intValue == APP.loginData.userId {
                let vc = RedDetailViewController.from(sb: .chat)
                vc.redId = m.redid
                vc.targetId = self.targetId
                vc.conversationType = self.conversationType
                vc.messageId = model.messageId
                vc.model = m
                vc.isSender = true
                vc.isopen = model.expansionDic?["isopen"] ?? ""
                self.go(vc)
            } else {
                // 点击了红包
                RedOpenView.show(model: m) {
                    let vc = RedDetailViewController.from(sb: .chat)
                    vc.redId = m.redid
                    vc.targetId = self.targetId
                    vc.conversationType = self.conversationType
                    vc.messageId = model.messageId
                    vc.model = m
                    vc.isSender = false
                    vc.isopen = model.expansionDic?["isopen"] ?? ""
                    self.go(vc)
                }
            }

        }
    }
    
    @objc func toMore() {
        switch conversationType {
        case .ConversationType_PRIVATE:
            let vc = UserDetailViewController.from(sb: .chat)
            vc.userId = targetId.intValue
            vc.updateBlock = { [weak self] str in
                self?.fakeNav.title = str
                self?.conversationMessageCollectionView.reloadData()
            }
            vc.clearBlock = { [weak self] in
                self?.conversationDataRepository = []
                self?.conversationMessageCollectionView.reloadData()
            }
            vc.levelBlock = { [weak self] level in
                self?.notificationLevel = level
                self?.updateLevelView()
            }
            go(vc)
        case .ConversationType_DISCUSSION, .ConversationType_GROUP, .ConversationType_ULTRAGROUP:
            let vc = GroupSettingViewController.from(sb: .chat)
            vc.teamId = targetId.intValue
            vc.updateBlock = { [weak self] str in
                self?.fakeNav.title = str
            }
            vc.clearBlock = { [weak self] in
                self?.conversationDataRepository = []
                self?.conversationMessageCollectionView.reloadData()
            }
            vc.levelBlock = { [weak self] level in
                self?.notificationLevel = level
                self?.updateLevelView()
            }
            go(vc)
        default:
            break
        }
    }

}
