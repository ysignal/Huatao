//
//  PasswordInputView.swift
//  Huatao
//
//  Created on 2023/3/3.
//  
	

import UIKit

protocol PasswordInputViewDelegate: NSObjectProtocol {
    
    /// 密码变动
    func passwordDidChanged(_ text: String)
    
    /// 密码输入结束
    func passwordDidEndedInput(_ text: String)
    
}

extension PasswordInputViewDelegate {
    func passwordDidChanged(_ text: String) {}
    func passwordDidEndedInput(_ text: String) {}
}

class PasswordInputView: UIView {
    
    enum SpacingType {
        case fill
        case equal
    }

    private lazy var tfStack: UIStackView = {
        let sk = UIStackView()
        sk.axis = .horizontal
        sk.distribution = .fillEqually
        return sk
    }()
    
    private var spacingType: SpacingType = .equal
    
    private var tfList: [SSTextField] = []
    
    private var viewPadding: CGFloat = 0
    
    private var tfCount: Int = 0
    
    weak var delegate: PasswordInputViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        buildUI()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        buildUI()
    }
    
    private func buildUI() {
        addSubview(tfStack)
        tfStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func config(count: Int = 6, spacing: CGFloat = 6, spacingType: SpacingType = .equal, delegate: PasswordInputViewDelegate?) {
        self.tfCount = count
        self.spacingType = spacingType
        switch spacingType {
        case .equal:
            tfStack.spacing = spacing
        case .fill:
            if count > 1 {
                tfStack.spacing = (frame.width - CGFloat(count) * frame.height)/CGFloat(count - 1)
            } else {
                tfStack.spacing = spacing
            }
        }
        
        tfStack.removeAllSubviews()
        tfList.removeAll()
        for i in 1...count {
            let tf = SSTextField()
            tf.ssDelegate = self
            tf.cornerRadius = 4
            tf.backgroundColor = .hex("eeeeee")
            tf.textColor = .hex("333333")
            tf.textAlignment = .center
            tf.font = UIFont.ss_semibold(size: 20)
            tf.maxLength = 1
            tf.keyboardType = .numberPad
            tf.returnKeyType = .done
            tf.tag = i
            tf.isSecureTextEntry = true
            tf.addTarget(self, action: #selector(textFieldDidEditingChanged(_:)), for: .editingChanged)
            
            tfList.append(tf)
            tfStack.addArrangedSubview(tf)
        }
    }
    
    @objc private func textFieldDidEditingChanged(_ sender: Any) {
        if let tf = sender as? UITextField, tf.markedTextRange == nil, let text = tf.text {
            if !text.isEmpty, tf.tag < tfCount {
                tfList.forEach { item in
                    if item.tag > tf.tag {
                        item.text = ""
                        if item.tag == tf.tag + 1 {
                            item.becomeFirstResponder()
                        }
                    }
                }
            }
            checkPassword()
        }
    }
    
    
    private func clearInput() {
        for tf in tfList {
            tf.text = ""
            if tf.tag == 1 {
                tf.becomeFirstResponder()
            }
        }
    }
    
    private func checkPassword() {
        let pwd = tfList.compactMap({ $0.text }).joined()
        delegate?.passwordDidChanged(pwd)
        if pwd.count >= tfCount {
            self.endEditing(true)
            delegate?.passwordDidEndedInput(pwd)
        }
    }
    
    func startInput() {
        tfList.first(where: { $0.tag == 1 })?.becomeFirstResponder()
    }
}


extension PasswordInputView: SSTextFieldDelegate {
    
    func textFieldDidDeleteBackward(_ textField: SSTextField) {
        // 删除字符
        if textField.tag > 1, let tf = viewWithTag(textField.tag - 1) as? UITextField {
            tf.becomeFirstResponder()
        }
        // 如果点击删除前面的密码，后面的输入框自动清空
        for tf in tfList {
            if tf.tag > textField.tag {
                tf.text = ""
            }
        }
        checkPassword()
    }
}
