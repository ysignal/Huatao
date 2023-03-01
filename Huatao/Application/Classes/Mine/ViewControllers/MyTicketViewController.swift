//
//  MyTicketViewController.swift
//  Huatao
//
//  Created on 2023/2/17.
//  
	

import UIKit

class MyTicketViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func buildUI() {
        fakeNav.title = "我的代金券"
        
        tableView.backgroundColor = .white
        tableView.showEmpty(true)
    }
    
    

}
