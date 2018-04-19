//
//  CustomClassesTVC.swift
//  Tutable
//
//  Created by Keyur on 27/03/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit

class CustomClassesTVC: UITableViewCell {

    @IBOutlet weak var imgBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var starBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        imgBtn.addCornerRadiusOfView(10.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
