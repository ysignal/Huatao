//
//  ChatViewController.swift
//  Huatao
//
//  Created on 2023/1/10.
//

import UIKit
import Popover
import JXSegmentedView
import swiftScan

class ChatViewController: SSViewController {
    
    @IBOutlet weak var containerView: UIView!
    
    lazy var addressBookVC: AddressBookViewController = {
        return AddressBookViewController.from(sb: .chat)
    }()
    
    lazy var conversationVC: ConversationListViewController = {
        return ConversationListViewController(displayConversationTypes: [RCConversationType.ConversationType_PRIVATE.rawValue,
                                                                         RCConversationType.ConversationType_GROUP.rawValue,
                                                                         RCConversationType.ConversationType_DISCUSSION.rawValue,
                                                                         RCConversationType.ConversationType_ULTRAGROUP.rawValue],
                                              collectionConversationType: [RCConversationType.ConversationType_SYSTEM.rawValue])
    }()
    
    lazy var background: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: SS.w, height: 262))
        view.drawGradient(start: .hex("ffeedb"), end: .hex("f6f6f6"), size: view.frame.size, direction: .t2b)
        return view
    }()
    
    lazy var segmentedView: JXSegmentedView = {
        let segment = JXSegmentedView(frame: CGRect(x: 0, y: 0, width: 120, height: 44))
        segment.backgroundColor = .clear
        segment.delegate = self
        return segment
    }()
    
    var segmentedDataSource = JXSegmentedTitleDataSource()
    
    /// 组头标题数组
    var titles = ["通讯录","聊天"]
    
    /// 组头
    var currentPage: Int = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 加载通讯录数据
        DataManager.realoadAddressBook()
    }
    
    override func buildUI() {
        view.backgroundColor = .hex("f6f6f6")
        view.insertSubview(background, belowSubview: containerView)
        
        showFakeNavBar()
        
        addChild(addressBookVC)
        addChild(conversationVC)
        
        fakeNav.backgroundColor = .clear
        fakeNav.rightButton.image = UIImage(named: "ic_chat_add")
        fakeNav.rightButton.isHidden = false
        fakeNav.rightButton.snp.updateConstraints { make in
            make.width.height.equalTo(24)
        }
        
        fakeNav.rightButtonHandler = {
            self.showMore()
        }
        
        segmentedDataSource.titles = titles
        segmentedDataSource.titleNormalFont = .ss_regular(size: 16)
        segmentedDataSource.titleSelectedFont = .ss_semibold(size: 18)
        segmentedDataSource.titleNormalColor = .hex("333333")
        segmentedDataSource.titleSelectedColor = .ss_theme
        segmentedDataSource.itemSpacing = 0
        segmentedDataSource.itemWidth = 60
        
        segmentedView.defaultSelectedIndex = 1
        segmentedView.dataSource = segmentedDataSource
        
        let indicator = JXSegmentedIndicatorLineView()
        indicator.verticalOffset = 6
        indicator.indicatorWidth = 20
        indicator.indicatorHeight = 1
        indicator.indicatorColor = UIColor.ss_theme
        segmentedView.indicators = [indicator]
        
        fakeNav.addSubview(segmentedView)
        segmentedView.snp.makeConstraints { make in
            make.width.equalTo(120)
            make.height.equalTo(44)
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
        }
                
        updateContainerView()
    }
    
    func updateContainerView() {
        containerView.removeAllSubviews()
        if currentPage == 0 {
            containerView.addSubview(addressBookVC.view)
            addressBookVC.view.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        } else {
            containerView.addSubview(conversationVC.view)
            conversationVC.view.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
    
    func showMore() {
        let view = ChatMoreView(frame: CGRect(origin: .zero, size: CGSize(width: 128, height: 138)))
        let popover = Popover(options: [.color(.hex("333333")),
                                        .blackOverlayColor(.clear),
                                        .arrowSize(CGSize(width: 12, height: 6)),
                                        .cornerRadius(8),
                                        .sideEdge(12)])
        view.actionBlock = { index in
            popover.dismiss()
            switch index {
            case 0:
                // 发起群聊
                let vc = SelectUserViewController.from(sb: .chat)
                self.go(vc)
            case 1:
                let vc = SearchFriendViewController.from(sb: .chat)
                self.go(vc)
            case 2:
                let vc = LBXScanViewController()
                vc.scanResultDelegate = self
                self.go(vc)
            default:
                break
            }
        }
        popover.popoverType = .down
        popover.show(view, fromView: fakeNav.rightButton)
    }

}

extension ChatViewController: JXSegmentedViewDelegate {
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        currentPage = index
        updateContainerView()
    }
}


extension ChatViewController: LBXScanViewControllerDelegate {
    
    func scanFinished(scanResult: LBXScanResult, error: String?) {
        if let result = scanResult.strScanned {
            SS.log(result)
        }
    }
    
}
