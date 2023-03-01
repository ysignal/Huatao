//
//  CardDescriptionViewController.swift
//  Huatao
//
//  Created on 2023/3/1.
//  
	

import UIKit

class CardDescriptionViewController: BaseViewController {
    
    struct TextItem {
        
        /// 文字
        var text: String
        
        /// 类型，1-普通，2-下划线
        var type: Int = 1
    }
    
    @IBOutlet weak var desc1ViewHeight: NSLayoutConstraint!
    @IBOutlet weak var desc1: UILabel!
    
    @IBOutlet weak var desc2ViewHeight: NSLayoutConstraint!
    @IBOutlet weak var desc2: UILabel!
    
    @IBOutlet weak var desc3ViewHeight: NSLayoutConstraint!
    @IBOutlet weak var desc3: UILabel!
    
    @IBOutlet weak var desc4ViewHeight: NSLayoutConstraint!
    @IBOutlet weak var desc4: UILabel!
    
    @IBOutlet weak var desc5ViewHeight: NSLayoutConstraint!
    @IBOutlet weak var desc5: UILabel!
    
    @IBOutlet weak var bindBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func buildUI() {
        fakeNav.title = "绑卡说明"
        
        bindBtn.drawThemeGradient(CGSize(width: SS.w - 50, height: 44))
        
        attributedText(for: [TextItem(text: "存折、信用卡、虚拟银行卡账号不能绑定，"),
                             TextItem(text: "只能是借记卡", type: 2),
                             TextItem(text: "；")],
                       in: desc1,
                       with: desc1ViewHeight)
        attributedText(for: [TextItem(text: "信用卡号"),
                             TextItem(text: "只能是数字组成", type: 2),
                             TextItem(text: "，不能包含空格、“_”等非数字符号，输入时请仔细检查；")],
                       in: desc2,
                       with: desc2ViewHeight)
        attributedText(for: [TextItem(text: "持卡人名字必须与银行卡开卡名字保持一致，如果持卡人名字是拼音，请注意大小写必须和开户时一致；")],
                       in: desc3,
                       with: desc3ViewHeight)
        attributedText(for: [TextItem(text: "目前单创系统只支持国内大部分的银行卡绑定，不支持国外银行卡；")],
                       in: desc4,
                       with: desc4ViewHeight)
        attributedText(for: [TextItem(text: "无法完成绑定流程的客户，"),
                             TextItem(text: "请详细核对开卡信息", type: 2),
                             TextItem(text: "。若仍无法完成绑定，请联系客服；")],
                       in: desc5,
                       with: desc5ViewHeight)
        
    }
    
    func attributedText(for data: [TextItem], in lb: UILabel, with layout: NSLayoutConstraint) {
        let mulStr = NSMutableAttributedString()
        
        let font = UIFont.systemFont(ofSize: 14)
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 20 - font.lineHeight
        for item in data {
            switch item.type {
            case 1:
                mulStr.append(NSAttributedString(string: item.text, attributes: [.paragraphStyle: style, .font: font]))
            case 2:
                mulStr.append(NSAttributedString(string: item.text, attributes: [.paragraphStyle: style, .font: font]).bolded.underlined)
            default:
                break
            }
            
        }
        lb.attributedText = mulStr
        let height = mulStr.boundingRect(with: CGSize(width: SS.w - 40, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil).height
        layout.constant = height/font.lineHeight * 20
    }

    @IBAction func toBind(_ sender: Any) {
        let vc = BankCardViewController.from(sb: .mine)
        self.go(vc)
    }
    
}
