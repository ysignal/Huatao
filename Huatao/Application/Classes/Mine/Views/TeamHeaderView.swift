//
//  TeamHeaderView.swift
//  Huatao
//
//  Created by minse on 2023/1/18.
//

import UIKit

class TeamHeaderView: UIView {
    
    @IBOutlet weak var directImage: UIImageView!
    @IBOutlet weak var directLabel: UILabel!
    @IBOutlet weak var indirectImage: UIImageView!
    @IBOutlet weak var indirectLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let edge = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 140)
        directImage.contentMode = .scaleToFill
        directImage.image = UIImage(named: "bg_team_orange")?.resizableImage(withCapInsets: edge, resizingMode: .stretch)
        indirectImage.contentMode = .scaleToFill
        indirectImage.image = UIImage(named: "bg_team_green")?.resizableImage(withCapInsets: edge, resizingMode: .stretch)
    }
    
    func config(model: MineTeamListModel) {
        directLabel.text = "\(model.promoteNum)"
        indirectLabel.text = "\(model.nextNum)"
    }

}
