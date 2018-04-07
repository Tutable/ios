//
//  CustomNotificationTVC.swift
//  Tutable
//
//  Created by Keyur on 05/04/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit

class CustomNotificationTVC: UITableViewCell {

    @IBOutlet weak var profilePicBtn: UIButton!
    @IBOutlet weak var titleName: UILabel!
    @IBOutlet weak var subTitleLbl: UILabel!
    @IBOutlet weak var dateTimeLbl: UILabel!
    
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
