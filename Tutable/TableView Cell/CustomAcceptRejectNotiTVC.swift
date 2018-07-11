//
//  CustomAcceptRejectNotiTVC.swift
//  Tutable
//
//  Created by Keyur on 09/04/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit

class CustomAcceptRejectNotiTVC: UITableViewCell {

    @IBOutlet weak var profilePicBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var subTitleLbl: UILabel!
    @IBOutlet weak var rejectBtn: UIButton!
    @IBOutlet weak var acceptBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        profilePicBtn.addCircularRadiusOfView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
