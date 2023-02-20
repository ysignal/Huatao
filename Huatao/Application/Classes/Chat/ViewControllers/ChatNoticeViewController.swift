//
//  ChatNoticeViewController.swift
//  Huatao
//
//  Created by lgvae on 2023/2/14.
//

import UIKit



class ChatNoticeViewController: BaseViewController{
    
    lazy var tableView: UITableView = {
        
        
        let tableView = UITableView(frame: CGRect(x: 0, y: SS.statusBarHeight + SS.navBarHeight, width: SS.w, height: view.ex_height - SS.statusBarHeight - SS.navBarHeight - SS.safeBottomHeight), style: .plain)
        
        tableView.delegate = self
        
        tableView.dataSource = self
        
        tableView.separatorStyle = .none

        return tableView
        
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func buildUI() {
        
        view.addSubview(tableView)
        
        fakeNav.title = "通知"
        
        
    }
    
}


extension ChatNoticeViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}


extension ChatNoticeViewController: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 62
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row % 2  == 0 {
            
            let cell = ChatNoticeCell(style: .default, reuseIdentifier: "UITableViewCell")
            
            cell.selectionStyle = .none
            
            return cell
            
        }else{
            
            let cell = ChatNoticeUnreadCell(style: .default, reuseIdentifier: "UITableViewCell")
            
            cell.selectionStyle = .none
            
            cell.fuseActionBlock = {
                
                print("拒绝:\(indexPath.row)")
                
            }
            
            cell.agreeActionBlock = {

                print("同意:\(indexPath.row)")
            }
            
            return cell
        }
    
    }
   
}
