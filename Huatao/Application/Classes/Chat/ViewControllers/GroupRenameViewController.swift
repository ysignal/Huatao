//
//  GroupRenameViewController.swift
//  Huatao
//
//  Created on 2023/2/21.
//  
	

import UIKit

class GroupRenameViewController: BaseViewController {
    
    @IBOutlet weak var nameTF: UITextField!
    
    @IBOutlet weak var countLabel: UILabel!
    
    var name: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func buildUI() {
        fakeNav.title = "修改群名"
        
    }
    
    func toSave() {
        nameTF.resignFirstResponder()
        
    }
    
    @IBAction func textFieldChange(_ sender: UITextField) {
        if sender.markedTextRange == nil, let text = sender.text {
            name = text
            countLabel.text = "\(min(text.count, 8))/8"
        }
    }

}

extension GroupRenameViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        toSave()
        return true
    }
    
}
